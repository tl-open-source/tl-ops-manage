-- tl_ops_plugin_sync_cluster
-- en : sync_cluster
-- zn : 集群同步器插件
-- @author iamtsm
-- @email 1905333456@qq.com

local plugin_sync_cluster = require("plugins.tl_ops_sync_cluster.sync_cluster");

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

    -- 启动心跳检查同步
    plugin_sync_cluster:tl_ops_sync_cluster_timer_start()

    return true, "ok"
end


function _M:tl_ops_process_before_init_rewrite(ctx)
    
    -- 集群节点请求过滤
    plugin_sync_cluster:tl_ops_sync_cluster_filter(ctx)

    return true, "ok"
end


return _M
