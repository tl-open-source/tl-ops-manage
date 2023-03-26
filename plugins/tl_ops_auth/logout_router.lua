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

    local login_str, _ = cache:get(constant.cache_key.login)
    if not login_str then
        return tl_ops_rt.args_error ,"auth logout_str err1", _
    end

    local login, _ = cjson.decode(login_str)
    if not login then
        return tl_ops_rt.args_error ,"auth logout err2", _
    end

    local cookie_utils = require("lib.cookie"):new();
    local auth_cid = cookie_utils:get(login.auth_cid)
    if not auth_cid then
        return tl_ops_rt.args_error ,"auth cid err3", _
    end

    -- del cookie
    cookie_utils:set({
        key = login.auth_cid,
        value = "",
        path = "/",
        domain = ngx.var.host,
        httponly = true,
        max_age = login.auth_time,
    })

    cookie_utils:set({
        key = "_u_name",
        value = "",
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

    -- del session
    auth:auth_del_session(auth_cid);

    return tl_ops_rt.ok, "success", nil
end

local Router = function ()
    utils:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}
