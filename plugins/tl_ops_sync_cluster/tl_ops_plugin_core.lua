-- tl_ops_plugin_sync_cluster
-- en : sync_cluster
-- zn : 集群同步器插件
-- @author iamtsm
-- @email 1905333456@qq.com

local plugin_sync_cluster       = require("plugins.tl_ops_sync_cluster.sync_cluster");
local plugin_sync_cluster_timer = require("plugins.tl_ops_sync_cluster.sync_cluster_timer");

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


function _M:tl_ops_process_after_init_worker()

    -- 启动同步器
    plugin_sync_cluster:tl_ops_sync_cluster_timer_start()

    -- 启动心跳检查同步
    plugin_sync_cluster_timer:tl_ops_sync_cluster_timer_start()

    return true, "ok"
end

return _M
