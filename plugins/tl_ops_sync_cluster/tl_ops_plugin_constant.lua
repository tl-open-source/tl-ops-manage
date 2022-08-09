-- 集群节点数据同步配置

local tl_ops_constant_sync_cluster = {
    cache_key = {
        current = "tl_ops_sync_cluster_current",        -- 当前节点信息 (暂不支持动态配置，只能在文件配置)
        other = "tl_ops_sync_cluster_other",            -- 其他节点信息 (暂不支持动态配置，只能在文件配置)
        interval = "tl_ops_sync_cluster_interval"       -- 主从心跳周期/单位/s  (暂不支持动态配置，只能在文件配置)
    },
    current = {
        ip = "127.0.0.1",
        port = 80,
        master = true
    },
    other = {
        {
            ip = "192.168.123.1",
            port = 80,
            master = false
        }
    },
    demo = {
        current = {
            ip = "127.0.0.1",               -- 节点ip
            port = 80,                      -- 节点端口
            master = true,                  -- 当前节点是主节点
        },
        other = {
            ip = "127.0.0.1",
            port = 81,
            master = false
        }
    },
    interval = 5,                       -- 心跳包同步周期
    timeout = 1000,                     -- 心跳连接超时时间 单位/ms
}

return tl_ops_constant_sync_cluster