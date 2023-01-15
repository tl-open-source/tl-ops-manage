-- tl_ops_ssl_set
-- en : set ssl config list
-- zn : 更新ssl配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local snowflake                 = require("lib.snowflake");
local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-ssl");
local constant_ssl              = require("plugins.tl_ops_ssl.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 

    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(constant_ssl.cache_key.list, 1);
    if not list or list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"ssl args err1", _);
        return;
    end
    
    -- 更新生成id
    for _, ssl in ipairs(list) do
        if not ssl.id or ssl.id == nil or ssl.id == '' then
            ssl.id = snowflake.generate_id( 100 )
        end
        if not ssl.updatetime or ssl.updatetime == nil or ssl.updatetime == '' then
            ssl.updatetime = ngx.localtime()
        end
        if ssl.change and ssl.change == true then
            ssl.updatetime = ngx.localtime()
            ssl.change = nil
        end
    end
    
    local cache_list, _ = cache:set(constant_ssl.cache_key.list, cjson.encode(list));
    if not cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
        return;
    end
    
    local res_data = {}
    res_data[constant_ssl.cache_key.list] = list
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", res_data)
 end
 
return Router
