-- tl_ops_plugin_time_alert_api
-- en : time_alert api
-- zn : 插件api接口
-- @author iamtsm
-- @email 1905333456@qq.com

local constant                  = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant")
local export_get_router         = require("plugins.tl_ops_time_alert.export_get_router")
local export_set_router         = require("plugins.tl_ops_time_alert.export_set_router")
local set_router                = require("plugins.tl_ops_time_alert.set_router");
local get_router                = require("plugins.tl_ops_time_alert.get_router");


-- 插件管理对外管理接口
return function(ctx)

    -- 对外管理接口
    ctx.tlops_api[constant.tlops_api.get] = get_router

    ctx.tlops_api[constant.tlops_api.set] = set_router
    
    -- 插件管理对外管理接口
    ctx.tlops_api[constant.export.tlops_api.get] = export_get_router

    ctx.tlops_api[constant.export.tlops_api.set] = export_set_router
    
end
