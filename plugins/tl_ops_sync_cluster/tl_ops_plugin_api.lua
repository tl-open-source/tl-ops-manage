-- tl_ops_plugin_sync_cluster_api
-- en : sync_cluster api
-- zn : 插件api接口
-- @author iamtsm
-- @email 1905333456@qq.com

local constant                  = require("plugins.tl_ops_sync_cluster.tl_ops_plugin_constant")
local export_get_router         = require("plugins.tl_ops_sync_cluster.export_get_router")
local export_set_router         = require("plugins.tl_ops_sync_cluster.export_set_router")
local get_router                = require("plugins.tl_ops_sync_cluster.get_cluster_router")

-- 插件管理对外管理接口
return function(ctx)

    -- 集群节点对外API
    ctx.tlops_api[constant.tlops_api.get] = get_router

    -- 插件管理对外管理接口
    ctx.tlops_api[constant.export.tlops_api.get] = export_get_router

    ctx.tlops_api[constant.export.tlops_api.set] = export_set_router
    
end
