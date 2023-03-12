-- tl_ops_plugin_auth_api
-- en : auth api
-- zn : 插件api接口
-- @author iamtsm
-- @email 1905333456@qq.com

local constant                  = require("plugins.tl_ops_auth.tl_ops_plugin_constant")
local export_get_router         = require("plugins.tl_ops_auth.export_get_router")
local export_set_router         = require("plugins.tl_ops_auth.export_set_router")
local login_router              = require("plugins.tl_ops_auth.login_router")
local logout_router             = require("plugins.tl_ops_auth.logout_router")
local get_router                = require("plugins.tl_ops_auth.get_router")
local set_router                = require("plugins.tl_ops_auth.set_router")


-- 插件管理对外管理接口
return function(ctx)

    -- 对外管理接口
    ctx.tlops_api[constant.tlops_api.login] = login_router

    ctx.tlops_api[constant.tlops_api.logout] = logout_router

    ctx.tlops_api[constant.tlops_api.get] = get_router

    ctx.tlops_api[constant.tlops_api.set] = set_router

    -- 插件管理对外管理接口
    ctx.tlops_api[constant.export.tlops_api.get] = export_get_router

    ctx.tlops_api[constant.export.tlops_api.set] = export_set_router
    
end
