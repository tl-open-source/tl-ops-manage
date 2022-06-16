-- tl_ops_api 
-- en : reset service node ,api config list
-- zn : 重置路由路由节点，api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_cookie = require("constant.tl_ops_constant_cookie");
local tl_ops_constant_header = require("constant.tl_ops_constant_header");
local tl_ops_constant_param = require("constant.tl_ops_constant_param");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


-- init balance
local function rest_init_balance()
    local cache_balance = require("cache.tl_ops_cache"):new("tl-ops-balance");

    local balance_data = { }
    balance_data[tl_ops_constant_balance.cache_key.service_empty] = tl_ops_constant_balance.code.service_empty;
    balance_data[tl_ops_constant_balance.cache_key.mode_empty] = tl_ops_constant_balance.code.mode_empty;
    balance_data[tl_ops_constant_balance.cache_key.host_empty] = tl_ops_constant_balance.code.host_empty;
    balance_data[tl_ops_constant_balance.cache_key.host_pass] = tl_ops_constant_balance.code.host_pass;
    balance_data[tl_ops_constant_balance.cache_key.token_limit] = tl_ops_constant_balance.code.token_limit;
    balance_data[tl_ops_constant_balance.cache_key.leak_limit] = tl_ops_constant_balance.code.leak_limit;
    balance_data[tl_ops_constant_balance.cache_key.offline] = tl_ops_constant_balance.code.offline;

    local err_code, _ = cache_balance:set(tl_ops_constant_balance.cache_key.err_code, cjson.encode(balance_data));
    if not err_code then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "err_code init err", _ )
        return;
    end
end

-- init balance api
local function rest_init_api()
    local cache_api = require("cache.tl_ops_cache"):new("tl-ops-api");

    local cache_api_rule, _ = cache_api:set(tl_ops_constant_api.cache_key.rule, tl_ops_constant_balance.api.rule);
    if not cache_api_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "api init err", _)
        return;
    end
    
    local cache_api_list, _ = cache_api:set(tl_ops_constant_api.cache_key.list, cjson.encode(
        tl_ops_constant_balance.api.list
    ));
    if not cache_api_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "api list init err", _)
        return;
    end    
end


-- init balance cookie
local function rest_init_cookie()
    local cache_cookie = require("cache.tl_ops_cache"):new("tl-ops-cookie");

    local cache_cookie_rule, _ = cache_cookie:set(tl_ops_constant_cookie.cache_key.rule, tl_ops_constant_balance.cookie.rule);
    if not cache_cookie_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "cookie init err", _)
        return;
    end
    
    local cache_cookie_list, _ = cache_cookie:set(tl_ops_constant_cookie.cache_key.list, cjson.encode(
        tl_ops_constant_balance.cookie.list
    ));
    if not cache_cookie_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "cookie list init err", _)
        return;
    end    
end


-- init balance header
local function rest_init_header()
    local cache_header = require("cache.tl_ops_cache"):new("tl-ops-header");

    local cache_header_rule, _ = cache_header:set(tl_ops_constant_header.cache_key.rule, tl_ops_constant_balance.header.rule);
    if not cache_header_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "header init err", _)
        return;
    end
    
    local cache_header_list, _ = cache_header:set(tl_ops_constant_header.cache_key.list, cjson.encode(
        tl_ops_constant_balance.header.list
    ));
    if not cache_header_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "header list init err", _)
        return;
    end    
end


-- init balance param
local function rest_init_param()
    local cache_param = require("cache.tl_ops_cache"):new("tl-ops-param");

    local cache_param_rule, _ = cache_param:set(tl_ops_constant_param.cache_key.rule, tl_ops_constant_balance.param.rule);
    if not cache_param_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "param init err", _)
        return;
    end
    
    local cache_param_list, _ = cache_param:set(tl_ops_constant_param.cache_key.list, cjson.encode(
        tl_ops_constant_balance.param.list
    ));
    if not cache_param_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "param list init err", _)
        return;
    end    
end


-- init service
local function rest_init_service()
    local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");

    local cache_service_rule, _ = cache_service:set(tl_ops_constant_service.cache_key.service_rule, tl_ops_constant_service.rule.auto_load);
    if not cache_service_rule then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "servie init err", _)
        return;
    end
    
    local cache_service_list, _ = cache_service:set(tl_ops_constant_service.cache_key.service_list, cjson.encode(
        tl_ops_constant_service.list
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

    local tl_ops_health_check_version = require("health.tl_ops_health_check_version")
    --默认初始化一次version
    for i = 1, #tl_ops_constant_health.options do
        local option = tl_ops_constant_health.options[i]
        local service_name = option.check_service_name
        if service_name then
            tl_ops_health_check_version.incr_service_version(service_name)
        end
    end
end

-- init limit fuse
local function rest_init_limit_fuse()
    local cache_limit = require("cache.tl_ops_cache"):new("tl-ops-limit");

    local options_list, _ = cache_limit:set(tl_ops_constant_limit.fuse.cache_key.options_list, cjson.encode(
        tl_ops_constant_limit.fuse.options
    ));
    if not options_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "limit options init err", _)
        return;
    end

    local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")
    -- 默认初始化一次version
    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    local token_options_list, _ = cache_limit:set(tl_ops_constant_limit.token.cache_key.options_list, cjson.encode(
        tl_ops_constant_limit.token.options
    ));
    if not token_options_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "token options init err", _)
        return;
    end

    local leak_options_list, _ = cache_limit:set(tl_ops_constant_limit.leak.cache_key.options_list, cjson.encode(
        tl_ops_constant_limit.leak.options
    ));
    if not leak_options_list then
        tl_ops_utils_func:get_str_json_by_return_arg(tl_ops_rt.error, "leak options init err", _)
        return;
    end
end


rest_init_balance()

rest_init_api()

rest_init_cookie()

rest_init_header()

rest_init_param()

rest_init_service()

rest_init_health()

rest_init_limit_fuse()

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", "");