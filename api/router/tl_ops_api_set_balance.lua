-- tl_ops_api 
-- en : set balance config
-- zn : 更新路由负载配置
-- @author iamtsm
-- @email 1905333456@qq.com


local snowflake                 = require("lib.snowflake");
local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-balance");
local tl_ops_constant_balance   = require("constant.tl_ops_constant_balance");
local tl_ops_rt                 = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 
    local service_empty, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.service_empty, 1);
    if not service_empty or service_empty == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err1", _);
        return;
    end
    
    local mode_empty, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.mode_empty, 1);
    if not mode_empty or mode_empty == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err2", _);
        return;
    end
    
    local host_empty, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.host_empty, 1);
    if not host_empty or host_empty == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err3", _);
        return;
    end
    
    local host_pass, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.host_pass, 1);
    if not host_pass or host_pass == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err4", _);
        return;
    end
    
    local token_limit, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.token_limit, 1);
    if not token_limit or token_limit == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err5", _);
        return;
    end
    
    local leak_limit, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.leak_limit, 1);
    if not leak_limit or leak_limit == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err6", _);
        return;
    end
    
    local offline, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.offline, 1);
    if not offline or offline == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err7", _);
        return;
    end
    
    
    service_empty = tonumber(service_empty)
    if service_empty < 200 or service_empty >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err8", _);
        return;
    end
    
    mode_empty = tonumber(mode_empty)
    if mode_empty < 200 or mode_empty >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err9", _);
        return;
    end
    
    host_empty = tonumber(host_empty)
    if host_empty < 200 or host_empty >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err10", _);
        return;
    end
    
    host_pass = tonumber(host_pass)
    if host_pass < 200 or host_pass >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err11", _);
        return;
    end
    
    token_limit = tonumber(token_limit)
    if token_limit < 200 or token_limit >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err12", _);
        return;
    end
    
    leak_limit = tonumber(leak_limit)
    if leak_limit < 200 or leak_limit >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err13", _);
        return;
    end
    
    offline = tonumber(offline)
    if offline < 200 or offline >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"b args err14", _);
        return;
    end
    
    local balance_data = { }
    balance_data[tl_ops_constant_balance.cache_key.service_empty] = service_empty;
    balance_data[tl_ops_constant_balance.cache_key.mode_empty] = mode_empty;
    balance_data[tl_ops_constant_balance.cache_key.host_empty] = host_empty;
    balance_data[tl_ops_constant_balance.cache_key.host_pass] = host_pass;
    balance_data[tl_ops_constant_balance.cache_key.token_limit] = token_limit;
    balance_data[tl_ops_constant_balance.cache_key.leak_limit] = leak_limit;
    balance_data[tl_ops_constant_balance.cache_key.offline] = offline;
    
    local res, _ = cache:set(tl_ops_constant_balance.cache_key.options, cjson.encode(balance_data));
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set err_code err ", _)
        return;
    end
    
    
    local res_data = {}
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data)
 end
 
return Router

 

 