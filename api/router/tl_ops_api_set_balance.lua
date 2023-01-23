-- tl_ops_api 
-- en : set balance config
-- zn : 更新路由负载配置
-- @author iamtsm
-- @email 1905333456@qq.com


local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-balance");
local tl_ops_constant_balance   = require("constant.tl_ops_constant_balance");
local tl_ops_rt                 = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 

    local change = "success"

    local service_empty, _ = tl_ops_utils_func:get_req_post_args_by_name("service_empty", 1);
    if service_empty then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.service_empty, cjson.encode(service_empty));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set service_empty err ", _)
            return;
        end
        change = "service_empty succeess"
    end
    
    local mode_empty, _ = tl_ops_utils_func:get_req_post_args_by_name("mode_empty", 1);
    if mode_empty then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.mode_empty, cjson.encode(mode_empty));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set mode_empty err ", _)
            return;
        end
        change = "mode_empty succeess"
    end
    
    local host_empty, _ = tl_ops_utils_func:get_req_post_args_by_name("host_empty", 1);
    if host_empty then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.host_empty, cjson.encode(host_empty));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set host_empty err ", _)
            return;
        end
        change = "host_empty succeess"
    end
    
    local host_pass, _ = tl_ops_utils_func:get_req_post_args_by_name("host_pass", 1);
    if host_pass then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.host_pass, cjson.encode(host_pass));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set host_pass err ", _)
            return;
        end
        change = "host_pass succeess"
    end
    
    local token_limit, _ = tl_ops_utils_func:get_req_post_args_by_name("token_limit", 1);
    if token_limit then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.token_limit, cjson.encode(token_limit));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set token_limit err ", _)
            return;
        end
        change = "token_limit succeess"
    end
    
    local leak_limit, _ = tl_ops_utils_func:get_req_post_args_by_name("leak_limit", 1);
    if leak_limit then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.leak_limit, cjson.encode(leak_limit));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set leak_limit err ", _)
            return;
        end
        change = "leak_limit succeess"
    end
    
    local offline, _ = tl_ops_utils_func:get_req_post_args_by_name("offline", 1);
    if offline then
        local res, _ = cache:set(tl_ops_constant_balance.cache_key.offline, cjson.encode(offline));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set offline err ", _)
            return;
        end
        change = "offline succeess"
    end
    
    local res_data = {}
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, change, res_data)
 end
 
return Router

 

 