-- tl_ops_balance_core_cookie
-- en : balance core cookie impl
-- zn : 根据cookie匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local cache_cookie = require("cache.tl_ops_cache"):new("tl-ops-balance-cookie");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local tl_ops_constant_balance_cookie = require("constant.tl_ops_constant_balance_cookie");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local shared = ngx.shared.tlopsbalance


-- 获取命中的cookie路由项
local tl_ops_balance_cookie_get_matcher_cookie = function(cookie_list_table, rule)
    local cookie_utils = require("lib.cookie"):new();
    
    local matcher_list = cookie_list_table[rule]

    if not matcher_list then
        return nil
    end

    for index, obj in pairs(matcher_list) do
        if obj and obj.key then
            local key = obj.key
            local values = obj.value
            local req_cookie_value, _ = cookie_utils:get(key);
            if req_cookie_value ~= nil then
                for _, value in pairs(values) do
                    if req_cookie_value == value then
                        return obj
                    end
                end
            end
        end
    end

    return nil
end


local tl_ops_balance_cookie_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- cookie路由策略
    local cookie_rule, _ = cache_cookie:get(tl_ops_constant_balance_cookie.cache_key.rule);
    if not cookie_rule then
        return nil
    end
    
    -- cookie配置列表
    local cookie_list, _ = cache_cookie:get(tl_ops_constant_balance_cookie.cache_key.list);
    if not cookie_list then
        return nil, nil, nil, nil
    end

    local cookie_list_table = cjson.decode(cookie_list);
    if not cookie_list_table then
        return nil, nil, nil, nil
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的cookie
    if cookie_rule == tl_ops_constant_balance_cookie.rule.point then
        matcher = tl_ops_balance_cookie_get_matcher_cookie(
            cookie_list_table, tl_ops_constant_balance_cookie.rule.point
        );
    elseif cookie_rule == tl_ops_constant_balance_cookie.rule.random then
        matcher = tl_ops_balance_cookie_get_matcher_cookie(
            cookie_list_table, tl_ops_constant_balance_cookie.rule.random
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
    tl_ops_balance_cookie_service_matcher = tl_ops_balance_cookie_service_matcher
}