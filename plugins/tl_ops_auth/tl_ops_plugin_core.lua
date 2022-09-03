-- tl_ops_plugin_auth
-- en : login auth 
-- zn : 登录权限认证插件
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_auth")
local auth_constant     = require("plugins.tl_ops_auth.tl_ops_plugin_constant")
local login_router      = require("plugins.tl_ops_auth.login")
local auth              = require("plugins.tl_ops_auth.auth")
local shared            = tlops.plugin_shared
local utils             = tlops.utils

local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }


function _M:new(options)
    if not options then
        options = {}
    end
    return setmetatable(options, mt)
end


function _M:tl_ops_process_before_init_rewrite(ctx)
    
    -- 对外login接口
    ctx.tlops_api[auth_constant.tlops_api.login] = login_router
    
    -- 登录态校验
    auth:auth_core(ctx)
    
    return true, "ok"
end


return _M
