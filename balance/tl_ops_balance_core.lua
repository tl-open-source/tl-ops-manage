-- tl_ops_balance
-- en : balance core impl
-- zn : 路由的具体实现，根据用户自定义的service , 自动检查服务节点状态，
--      根据自定义的url，以及选中的路由策略，路由到合适的服务节点。
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local cache_api = require("cache.tl_ops_cache"):new("tl-ops-api");
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local shared = ngx.shared.tlopsbalance

local _M = {
	_VERSION = '0.01'
}
local mt = { __index = _M }


local tl_ops_balance_api_reg_matcher = function()
    local matcher = nil

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();
    
    -- api路由策略
    local api_rule, _ = cache_api:get(tl_ops_constant_balance.cache_key.api_rule);
    if not api_rule then
        return nil
    end
    
    -- api配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_balance.cache_key.api_list);
    if not api_list then
        return nil
    end
    local api_list_table = cjson.decode(api_list);
    
    -- 根据路由当前策略进行路由, 返回正则命中的api
    if api_rule == tl_ops_constant_api.rule.url then
        matcher = tl_ops_utils_func:get_table_matcher_longer_str_for_api_list(
            api_list_table, tl_ops_constant_api.rule.url, request_uri
        );
    elseif api_rule == tl_ops_constant_api.rule.random then
        matcher = tl_ops_utils_func:get_table_matcher_longer_str_for_api_list(
            api_list_table, tl_ops_constant_api.rule.random, request_uri
        );
    end

    return matcher
end


local tl_ops_balance_api_service_matcher = function()
    local service = nil
    
    local api_matcher = tl_ops_balance_api_reg_matcher()
    if not api_matcher or type(api_matcher) ~= 'table' then
        return nil, nil
    end

    -- 服务节点配置列表
    local service_list_str, _ = cache_service:get(tl_ops_constant_balance.cache_key.service_list);
    if not service_list_str then
        return nil, nil
    end
    local service_list_table = cjson.decode(service_list_str);
    if not service_list_table and type(service_list_table) ~= 'table' then
        return nil, nil
    end
    local service_list = service_list_table[api_matcher.service]

    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, api_matcher.service, api_matcher.node)
    local node_state , _ = shared:get(key)

    -- node balance
    local check_service_node = api_matcher.node  ---- lua index start 1
    if check_service_node then
        service = service_list[tonumber(check_service_node) + 1]
    else
        -- random balance
        math.randomseed(#request_uri)
        check_service_node = tonumber(math.random(0,1) % #service_list_table[api_matcher.service]) + 1
        service = service_list[check_service_node]
    end

    return service, node_state, check_service_node
end


---- 流控介入
local tl_ops_balance_token = function()
    
end


function _M:tl_ops_balance_api_balance()

    local node, node_state, check_service_node = tl_ops_balance_api_service_matcher()

    if not node then
        ngx.header['Tl-Proxy-Server'] = "nil";
        ngx.exit(503)
    end

    -- offline
    if not node_state or node_state == false then 
        -- incr failed balance count
        local balance_req_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_fail, node['service'], check_service_node)
        shared:incr(balance_req_fail_count_key, 1)

        local limit_req_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail, node['service'], check_service_node)
        shared:incr(limit_req_fail_count_key, 1)

        ngx.header['Tl-Proxy-Server'] = node['service'];
        ngx.header['Tl-Proxy-Node'] = node['name'];
        ngx.header['Tl-Proxy-State'] = "offline"
        ngx.exit(503)
    else
        -- incr success balance count
        local balance_req_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_succ, node['service'], check_service_node)
        shared:incr(balance_req_succ_count_key, 1)

        local limit_req_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, node['service'], check_service_node)
        shared:incr(limit_req_succ_count_key, 1)

        ngx.var.node = node['protocol'] .. node["ip"] .. ':' .. node["port"];
        ngx.header['Tl-Proxy-Server'] = node['service'];
        ngx.header['Tl-Proxy-Node'] = node['name'];
        ngx.header['Tl-Proxy-State'] = "online"
    end
    
end


function _M:new()
	return setmetatable({}, mt)
end


return _M

