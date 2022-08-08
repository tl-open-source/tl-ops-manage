-- 集群节点数据同步配置

local tl_ops_constant_sync_cluster = {
    cache_key = {
        options = "tl_ops_sync_cluster_options",         -- 主从节点列表 (暂不支持动态配置，只能在文件配置)
        interval = "tl_ops_sync_cluster_interval"       -- 主从心跳周期/单位/s  (暂不支持动态配置，只能在文件配置)
    },
    options = {
        {
            id = 1,
            ip = "127.0.0.1",
            port = 80,
        },
        {
            id = 2,
            ip = "127.0.0.1",
            port = 81,
        }
    },
    demo = {
        id = 1,                         -- 主节点默认放第一个，且只能有一个主节点，否则插件不执行
        ip = "127.0.0.1",               -- 节点ip
        port = 80,                      -- 节点端口
    },
    interval = 5
}

return tl_ops_constant_sync_cluster