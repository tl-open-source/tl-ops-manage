-- tl_ops_balance_core_header
-- en : balance core header impl
-- zn : 根据请求头匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local cache_header = require("cache.tl_ops_cache"):new("tl-ops-header");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local tl_ops_constant_header = require("constant.tl_ops_constant_header");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local shared = ngx.shared.tlopsbalance


-- 获取命中的header路由项
local tl_ops_balance_header_get_matcher_header = function(header_list_table, rule)
    local matcher_list = header_list_table[rule]

    if not matcher_list then
        return nil
    end 

    local headers = ngx.req.get_headers()

    for index, obj in pairs(matcher_list) do
        if obj and obj.key then
            local key = obj.key
            local value = obj.value
            for header_k ,header_v in pairs(headers) do
                if header_k and header_k == key and header_v == value then
                    return obj
                end
            end
        end
    end

    return nil
end


local tl_ops_balance_header_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- header路由策略
    local header_rule, _ = cache_header:get(tl_ops_constant_header.cache_key.rule);
    if not header_rule then
        return nil
    end
    
    -- header配置列表
    local header_list, _ = cache_header:get(tl_ops_constant_header.cache_key.list);
    if not header_list then
        return nil, nil, nil, nil
    end

    local header_list_table = cjson.decode(header_list);
    if not header_list_table then
        return nil, nil, nil, nil
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的header
    if header_rule == tl_ops_constant_header.rule.point then
        matcher = tl_ops_balance_header_get_matcher_header(
            header_list_table, tl_ops_constant_header.rule.point
        );
    elseif header_rule == tl_ops_constant_header.rule.random then
        matcher = tl_ops_balance_header_get_matcher_header(
            header_list_table, tl_ops_constant_header.rule.random
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
    tl_ops_balance_header_service_matcher = tl_ops_balance_header_service_matcher
}