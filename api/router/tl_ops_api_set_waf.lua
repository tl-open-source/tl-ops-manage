-- tl_ops_api 
-- en : set waf config
-- zn : 更新waf配置
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-waf");
local tl_ops_constant_waf = require("constant.tl_ops_constant_waf");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local Router = function() 
    local ip, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf.cache_key.ip, 1);
    if not ip or ip == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err1", _);
        return;
    end
    
    local api, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf.cache_key.api, 1);
    if not api or api == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err2", _);
        return;
    end
    
    local cc, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf.cache_key.cc, 1);
    if not cc or cc == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err3", _);
        return;
    end
    
    local header, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf.cache_key.header, 1);
    if not header or header == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err4", _);
        return;
    end
    
    local cookie, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf.cache_key.cookie, 1);
    if not cookie or cookie == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err5", _);
        return;
    end
    
    local param, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf.cache_key.param, 1);
    if not param or param == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err6", _);
        return;
    end
    
    ip = tonumber(ip)
    if ip < 200 or ip >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err8", _);
        return;
    end
    
    api = tonumber(api)
    if api < 200 or api >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err9", _);
        return;
    end
    
    param = tonumber(param)
    if param < 200 or param >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err10", _);
        return;
    end
    
    cookie = tonumber(cookie)
    if cookie < 200 or cookie >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err11", _);
        return;
    end
    
    header = tonumber(header)
    if header < 200 or header >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err12", _);
        return;
    end
    
    cc = tonumber(cc)
    if cc < 200 or cc >= 600 then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"w args err13", _);
        return;
    end
    
    local waf_data = { }
    waf_data[tl_ops_constant_waf.cache_key.ip] = ip;
    waf_data[tl_ops_constant_waf.cache_key.api] = api;
    waf_data[tl_ops_constant_waf.cache_key.param] = param;
    waf_data[tl_ops_constant_waf.cache_key.cookie] = cookie;
    waf_data[tl_ops_constant_waf.cache_key.header] = header;
    waf_data[tl_ops_constant_waf.cache_key.cc] = cc;
    
    local res, _ = cache:set(tl_ops_constant_waf.cache_key.options, cjson.encode(waf_data));
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set err_code err ", _)
        return;
    end
    
    
    local res_data = {}
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data)
 end
 
return Router

 

 