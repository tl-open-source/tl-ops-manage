-- tl_ops_balance_core_body
-- en : balance core body impl
-- zn : 根据请求参数匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                         = require("cjson.safe");
local cache_body                    = require("cache.tl_ops_cache_core"):new("tl-ops-balance-body");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_body  = require("constant.tl_ops_constant_balance_body");
local tl_ops_constant_service       = require("constant.tl_ops_constant_service");
local tl_ops_constant_health        = require("constant.tl_ops_constant_health")
local shared                        = ngx.shared.tlopsbalance
local find                          = ngx.re.find

-- 获取命中的body路由项
local tl_ops_balance_body_get_matcher_body = function(body_list_table, rule)
    local matcher_list = body_list_table[rule]

    if not matcher_list then
        return nil
    end 

    ngx.req.read_body()

    local body = ngx.req.get_body_data()

    for i, obj in pairs(matcher_list) do
        local from, to , _ = find(body , obj.body , 'joi');
        if from and to then
            return obj
        end
    end

    return nil
end


local tl_ops_balance_body_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- body路由策略
    local body_rule, _ = cache_body:get(tl_ops_constant_balance_body.cache_key.rule);
    if not body_rule then
        return nil
    end
    
    -- body配置列表
    local body_list, _ = cache_body:get(tl_ops_constant_balance_body.cache_key.list);
    if not body_list then
        return nil, nil, nil, nil
    end

    local body_list_table = cjson.decode(body_list);
    if not body_list_table then
        return nil, nil, nil, nil
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的body
    if body_rule == tl_ops_constant_balance_body.rule.point then
        matcher = tl_ops_balance_body_get_matcher_body(
            body_list_table, tl_ops_constant_balance_body.rule.point
        );
    elseif body_rule == tl_ops_constant_balance_body.rule.random then
        matcher = tl_ops_balance_body_get_matcher_body(
            body_list_table, tl_ops_constant_balance_body.rule.random
        );
    end

    if not matcher or type(matcher) ~= 'table' then
        return nil, nil, nil, nil
    end

    local service_list = service_list_table[matcher.service]
    local node_id = matcher.node  -- lua index start 1

    local host = matcher.host
    if not host or host == nil then
        host = ""
    end

    -- 指定节点
    if body_rule == tl_ops_constant_balance_body.rule.point then
        if node_id ~= nil then
            node = service_list[tonumber(node_id) + 1]            
        else
            return nil, nil, nil, host
        end
    -- 服务内随机
    elseif body_rule == tl_ops_constant_balance_body.rule.random then
        math.randomseed(#request_uri)
        node_id = tonumber(math.random(0,1) % #service_list_table[matcher.service]) + 1
        node = service_list[node_id]
    end

    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, matcher.service, node_id)
    local node_state , _ = shared:get(key)
    
    return node, node_state, node_id, host
end


return {
    tl_ops_balance_body_service_matcher = tl_ops_balance_body_service_matcher
}