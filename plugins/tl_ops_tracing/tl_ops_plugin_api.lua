-- tl_ops_plugin_tracing_api
-- en : tracing api
-- zn : 插件api接口
-- @author iamtsm
-- @email 1905333456@qq.com

local constant                  = require("plugins.tl_ops_tracing.tl_ops_plugin_constant")
local export_get_router         = require("plugins.tl_ops_tracing.export_get_router")
local export_set_router         = require("plugins.tl_ops_tracing.export_set_router")


-- 插件管理对外管理接口
return function(ctx)

    ctx.tlops_api[constant.export.tlops_api.get] = export_get_router

    ctx.tlops_api[constant.export.tlops_api.set] = export_set_router
    
end
