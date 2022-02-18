-- tl_ops_api 
-- en : reset service node ,api config list
-- zn : 重置路由路由节点，api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

-- init api
local function rest_init_api()
    local cache_api = require("cache.tl_ops_cache"):new("tl-ops-api");

    local cache_api_rule, _ = cache_api:set(tl_ops_constant_balance.cache_key.api_rule, tl_ops_constant_balance.api.rule);
    if not cache_api_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "api init err", _)
        return;
    end
    
    local cache_api_list, _ = cache_api:set(tl_ops_constant_balance.cache_key.api_list, cjson.encode(
        tl_ops_constant_balance.api.list
    ));
    if not cache_api_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "api list init err", _)
        return;
    end    
end

-- init service
local function rest_init_service()
    local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");

    local cache_service_rule, _ = cache_service:set(tl_ops_constant_balance.cache_key.service_rule, tl_ops_constant_balance.service.rule);
    if not cache_service_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "servie init err", _)
        return;
    end
    
    local cache_service_list, _ = cache_service:set(tl_ops_constant_balance.cache_key.service_list, cjson.encode(
        tl_ops_constant_balance.service.list
    ));
    if not cache_service_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "servie list init err", _)
        return;
    end
end

-- init health
local function rest_init_health()
    local cache_health = require("cache.tl_ops_cache"):new("tl-ops-health");

    local options_list, _ = cache_health:set(tl_ops_constant_health.cache_key.options_list, cjson.encode(
        tl_ops_constant_health.options
    ));
    if not options_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "health options init err", _)
        return;
    end

end

-- init limit fuse
local function rest_init_limit_fuse()
    local cache_limit = require("cache.tl_ops_cache"):new("tl-ops-limit");

    local options_list, _ = cache_limit:set(tl_ops_constant_limit.fuse.cache_key.options_list, cjson.encode(
        tl_ops_constant_limit.fuse.options
    ));
    if not options_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "health options init err", _)
        return;
    end

end



rest_init_api();

rest_init_service();

rest_init_health();

rest_init_limit_fuse()

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", "");