-- tl_ops_auth
-- en : login
-- zn : 登录
-- @author iamtsm
-- @email 1905333456@qq.com

local cache             = require("cache.tl_ops_cache_core"):new("tl-ops-auth");
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_auth")
local constant          = require("plugins.tl_ops_auth.tl_ops_plugin_constant")
local auth              = require("plugins.tl_ops_auth.auth")
local uuid              = require("lib.jit-uuid")
local utils             = tlops.utils
local shared            = tlops.plugin_shared
local tl_ops_rt         = tlops.constant.comm.tl_ops_rt
local cjson             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)

local Handler = function()

    local username, _ = utils:get_req_post_args_by_name("username", 1);
    if not username or username == nil then
        return tl_ops_rt.args_error ,"auth args err1", _
    end

    local password, _ = utils:get_req_post_args_by_name("password", 1);
    if not password or password == nil then
        return tl_ops_rt.args_error ,"auth args err2", _
    end

    local login_str, _ = cache:get(constant.cache_key.login)
    if not login_str then
        return tl_ops_rt.args_error ,"auth login_str err3", _
    end

    local login, _ = cjson.decode(login_str)
    if not login then
        return tl_ops_rt.args_error ,"auth login err4", _
    end

    local list_str, _ = cache:get(constant.cache_key.list)
    if not list_str then
        return tl_ops_rt.args_error ,"auth list_str err5", _
    end

    local list, _ = cjson.decode(list_str)
    if not list then
        return tl_ops_rt.args_error ,"auth list err6", _
    end

    for i, user in ipairs(list) do
        if user.username == username and user.password == password then
            -- add cookie
            local cookie_utils = require("lib.cookie"):new();
            local auth_cid = uuid()
            cookie_utils:set({
                key = login.auth_cid,
                value = auth_cid,
                path = "/",
                domain = ngx.var.host,
                httponly = true,
                max_age = login.auth_time,
            })

            cookie_utils:set({
                key = "_u_name",
                value = user.username,
                path = "/",
                domain = ngx.var.host,
                max_age = login.auth_time,
            })

            cookie_utils:set({
                key = "_u_key",
                value = login.auth_cid,
                path = "/",
                domain = ngx.var.host,
                max_age = login.auth_time,
            })

            -- add session
            auth:auth_add_session(auth_cid, user);

            return tl_ops_rt.ok, "success", nil
        end
    end

    return tl_ops_rt.ok, "failed", nil
end


local Router = function ()
    utils:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}
