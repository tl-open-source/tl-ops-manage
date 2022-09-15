-- 集群节点数据同步配置

local tl_ops_plugin_constant_sync_cluster = {
    cache_key = {
        current = "tl_ops_plugin_sync_cluster_current",         -- 当前节点信息 (暂不支持动态配置，只能在文件配置)
        other = "tl_ops_plugin_sync_cluster_other",             -- 其他节点信息 (暂不支持动态配置，只能在文件配置)
        interval = "tl_ops_plugin_sync_cluster_interval"        -- 主从心跳周期/单位/s  (暂不支持动态配置，只能在文件配置)
    },
    open = false,                                               -- 是否开启
    module = {                                                  -- 同步数据器需要同步的模块，如果新增需要持久化的模块，需要在此定义
        "service", "health", "limit", "balance", "waf",
        "balance_api", "balance_cookie", "balance_header", "balance_param",
        "waf_ip", "waf_api", "waf_cc", "waf_header", "waf_cookie", "waf_param"
    },
    interval = 5,                                               -- 心跳包同步周期
    timeout = 1000,                                             -- 心跳连接超时时间 单位/ms
    tlops_api = {
        heartbeta = "/tlops/cluster/sync",                      -- 主从同步心跳的api地址，不对外
        get =  "/tlops/cluster/get"                             -- 集群节点对外api
    },
    salve_api = "Tl-Slave-Api",                                 -- 请求头标记
    current = {
        ip = "127.0.0.1",
        port = 80,
        master = true
    },
    other = {
        {
            id = 1,
            ip = "127.0.0.1",
            port = 81,
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
            id = 1,
            ip = "127.0.0.1",
            port = 81,
            master = false
        }
    },
}

return tl_ops_plugin_constant_sync_cluster