-- tl_ops_set_auth
-- en : set auth config/list
-- zn : 更新auth插件配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local snowflake                 = require("lib.snowflake");
local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-auth");
local constant                  = require("plugins.tl_ops_auth.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 

    local change = "success"

    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.cache_key.list, 1);
    if list then
        -- 更新生成id
        for _, user in ipairs(list) do
            if not user.id or user.id == nil or user.id == '' then
                user.id = snowflake.generate_id( 100 )
            end
            if not user.updatetime or user.updatetime == nil or user.updatetime == '' then
                user.updatetime = ngx.localtime()
            end
            if user.change and user.change == true then
                user.updatetime = ngx.localtime()
                user.change = nil
            end
        end

        local res, _ = cache:set(constant.cache_key.list, cjson.encode(list));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
            return;
        end

        change = "list"
    end

    local login, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.cache_key.login, 1);
    if login then
        local res, _ = cache:set(constant.cache_key.login, cjson.encode(login));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set login err ", _)
            return;
        end

        change = "login"
    end
    
    local res_data = {}
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, change, res_data)
 end
 
return Router
