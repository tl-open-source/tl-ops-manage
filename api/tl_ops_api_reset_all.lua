-- tl_ops_api 
-- en : reset service node ,api config list
-- zn : 重置负载负载节点，api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

-- init api
local function rest_init_api()
    local cache_api = require("cache.tl_ops_cache"):new("tl-ops-api");
    local api_rule_key = tl_ops_constant_balance.api.rule.cache_key;
    local api_list_key = tl_ops_constant_balance.api.list.cache_key;
    local api_rule_default = tl_ops_constant_balance.api.rule.default;
    local api_list_default = tl_ops_constant_balance.api.list.default;
    
    local cache_api_rule, err = cache_api:set(api_rule_key, api_rule_default);
    if not cache_api_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "api init err", err)
        return;
    end
    
    local cache_api_list, err = cache_api:set(api_list_key, cjson.encode(api_list_default));
    if not cache_api_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "api list init err", err)
        return;
    end    
end

-- init service
local function rest_init_service()
    local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
    local service_rule_key = tl_ops_constant_balance.service.rule.cache_key;
    local service_list_key = tl_ops_constant_balance.service.list.cache_key;
    local service_rule_default = tl_ops_constant_balance.service.rule.default;
    local service_list_default = tl_ops_constant_balance.service.list.default;
    
    local cache_service_rule, err = cache_service:set(service_rule_key, service_rule_default);
    if not cache_service_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "servie init err", err)
        return;
    end
    
    local cache_service_list, err = cache_service:set(service_list_key, cjson.encode(service_list_default));
    if not cache_service_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "servie list init err", err)
        return;
    end
end


rest_init_api();

rest_init_service();

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", "");