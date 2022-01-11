-- tl_ops_balance
-- en : balance impl
-- zn : 负载的具体实现，根据用户自定义的service , 自动检查服务节点状态，
--      根据自定义的url，以及选中的负载策略，负载到合适的服务节点。
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local cache_api = require("cache.tl_ops_cache"):new("tl-ops-api");
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local shared = ngx.shared.tlopsbalance

local api_rule_key = tl_ops_constant_balance.api.rule.cache_key;
local api_list_key = tl_ops_constant_balance.api.list.cache_key;
local service_rule_key = tl_ops_constant_balance.service.rule.cache_key;
local service_list_key = tl_ops_constant_balance.service.list.cache_key;


local tl_ops_api_constant_rule = tl_ops_constant_api.rule;
local tl_ops_service_rule = tl_ops_constant_service.rule;

-- 获取当前url
local request_uri = tl_ops_utils_func:get_req_uri();

-- api负载策略
local api_rule, err = cache_api:get(api_rule_key);
if not api_rule then
    api_rule = tl_ops_api_constant_rule.url;
end

-- api配置列表
local api_list, err = cache_api:get(api_list_key);
if not api_list then
    api_list = "{}";
end
local api_list_table = cjson.decode(api_list);


-- 根据负载当前策略进行负载, 返回正则命中的api
local matcher = nil
if api_rule == tl_ops_api_constant_rule.url then
    matcher = tl_ops_utils_func:get_table_matcher_longer_str_for_api_list(
        api_list_table, tl_ops_api_constant_rule.url, request_uri
    );
elseif api_rule == tl_ops_api_constant_rule.random then
    matcher = tl_ops_utils_func:get_table_matcher_longer_str_for_api_list(
        api_list_table, tl_ops_api_constant_rule.random, request_uri
    );
end


if matcher and type(matcher) == 'table' then
    -- 服务节点策略
    local service_rule, err = cache_service:get(service_rule_key);
    if not service_rule then
        service_rule = tl_ops_service_rule.auto_load;
    end

    -- 服务节点配置列表
    local service_list, err = cache_service:get(service_list_key);
    if not service_list then
        service_list = "{}";
    end
    local service_list_table = cjson.decode(service_list);

    ---- 进行负载
    if service_list_table and type(service_list_table) == 'table' then
        local check_service_name = matcher['service']
        local check_service_node = matcher['node']  ---- lua index start 1

        -- 获取当前节点健康状态
        local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, check_service_name, check_service_node)
        local state , err = shared:get(key)

        if check_service_node then
            check_service_node = tonumber(check_service_node) + 1
        else
            math.randomseed(#request_uri)
            check_service_node = tonumber(math.random(0,1) % #service_list_table[check_service_name]) + 1
        end
        local service_list = service_list_table[check_service_name]
        local service = service_list[check_service_node]

        if service then
            -- offline
            if not state or state == false then
                ngx.var.node = service['protocol'] .. service["ip"] .. "/502";
                ngx.header['Tl-Proxy'] = service['protocol'] .. service["ip"] .. "/502";
            else
                ngx.var.node = service['protocol'] .. service["ip"] .. ':' .. service["port"];
                ngx.header['Tl-Proxy'] = service['name'];
            end
        end
    end
end
