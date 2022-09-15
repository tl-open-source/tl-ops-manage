-- tl_ops_plugin_auth
-- en : login auth 
-- zn : 登录权限认证插件
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_auth")
local constant_auth     = require("plugins.tl_ops_auth.tl_ops_plugin_constant")
local login_router      = require("plugins.tl_ops_auth.login_auth")
local get_router        = require("plugins.tl_ops_auth.get_auth")
local set_router        = require("plugins.tl_ops_auth.set_auth")
local sync              = require("plugins.tl_ops_auth.sync");
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
    
     -- 对外管理接口
    ctx.tlops_api[constant_auth.tlops_api.login] = login_router

    ctx.tlops_api[constant_auth.tlops_api.get] = get_router

    ctx.tlops_api[constant_auth.tlops_api.set] = set_router
    
    -- 登录态校验
    auth:auth_core(ctx)
    
    return true, "ok"
end



-- 插件数据同步
function _M:sync_data()
    sync.sync_data()
end


-- 插件数据字段同步
function _M:sync_fields()
    sync.sync_fields()
end



return _M
