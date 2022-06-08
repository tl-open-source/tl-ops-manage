-- tl_ops_balance_core_param
-- en : balance core param impl
-- zn : 根据请求参数匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local cache_param = require("cache.tl_ops_cache"):new("tl-ops-param");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local tl_ops_constant_param = require("constant.tl_ops_constant_param");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local shared = ngx.shared.tlopsbalance


-- 获取命中的param路由项
local tl_ops_balance_param_get_matcher_param = function(param_list_table, rule)
    local matcher_list = param_list_table[rule]

    if not matcher_list then
        return nil
    end 

    local args = ngx.req.get_uri_args()

    for index, obj in pairs(matcher_list) do
        if obj and obj.key then
            local key = obj.key
            local value = obj.value
            for arg_k ,arg_v in pairs(args) do
                if arg_k and arg_k == key and arg_v == value then
                    return obj
                end
            end
        end
    end

    return nil
end


local tl_ops_balance_param_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- param路由策略
    local param_rule, _ = cache_param:get(tl_ops_constant_param.cache_key.rule);
    if not param_rule then
        return nil
    end
    
    -- param配置列表
    local param_list, _ = cache_param:get(tl_ops_constant_param.cache_key.list);
    if not param_list then
        return nil, nil, nil, nil
    end

    local param_list_table = cjson.decode(param_list);
    if not param_list_table then
        return nil, nil, nil, nil
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的param
    if param_rule == tl_ops_constant_param.rule.point then
        matcher = tl_ops_balance_param_get_matcher_param(
            param_list_table, tl_ops_constant_param.rule.point
        );
    elseif param_rule == tl_ops_constant_param.rule.random then
        matcher = tl_ops_balance_param_get_matcher_param(
            param_list_table, tl_ops_constant_param.rule.random
        );
    end

    if not matcher or type(matcher) ~= 'table' then
        return nil, nil, nil, nil
    end

    local service_list = service_list_table[matcher.service]

    -- node balance
    local node_id = matcher.node  -- lua index start 1
    if node_id then
        node = service_list[tonumber(node_id) + 1]
    else
        -- random balance
        math.randomseed(#matcher.key)
        node_id = tonumber(math.random(0,1) % #service_list_table[matcher.service]) + 1
        node = service_list[node_id]
    end

    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, matcher.service, node_id)
    local node_state , _ = shared:get(key)
    

    local host = matcher.host
    if not host or host == nil then
        host = ""
    end

    
    return node, node_state, node_id, host
end


return {
    tl_ops_balance_param_service_matcher = tl_ops_balance_param_service_matcher
}