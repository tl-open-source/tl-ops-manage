-- 集群节点数据同步配置

local tl_ops_plugin_constant_sync_cluster = {
    cache_key = {
        current = "tl_ops_plugin_sync_cluster_current",         -- 当前节点信息 (暂不支持动态配置，只能在文件配置)
        other = "tl_ops_plugin_sync_cluster_other",             -- 其他节点信息 (暂不支持动态配置，只能在文件配置)
        interval = "tl_ops_plugin_sync_cluster_interval"        -- 主从心跳周期/单位/s  (暂不支持动态配置，只能在文件配置)
    },
    open = false,                                               -- 是否开启
    module = {                                                  -- 同步数据器需要同步的模块，如果新增需要持久化的模块，需要在此定义
        -- 内置模块
        "service", "health", "limit", "balance", "waf", "plugins_manage",
        "balance_api", "balance_body", "balance_cookie", "balance_header", "balance_param",
        "waf_ip", "waf_api", "waf_cc", "waf_header", "waf_cookie", "waf_param",
        
        -- 插件模块
        "ssl", "auth", "time_alert",  "page_proxy", "tracing", "cors", "log_analyze", 
        "health_check_debug", "template"
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
    export = {
        cache_key = {
            sync_cluster = "tl_ops_plugins_export_sync_cluster",
        },
        tlops_api = {
            get = "/tlops/sync-cluster/manage/get",     -- 获取插件配置数据的接口
            set = "/tlops/sync-cluster/manage/set",     -- 修改插件配置数据的接口
        },
        sync_cluster = {
            zname = '集群数据字段同步预热插件',
            page = "",
            name = 'sync_cluster',
            open = true,
            scope = "tl_ops_process_after_init_worker,tl_ops_process_before_init_rewrite",
        },
        demo = {
            zname = '',         -- 插件中文名称
            page = "",          -- 插件配置页面
            name = '',          -- 插件名称
            open = true,        -- 插件是否开启
            scope = "",         -- 插件生命周期阶段
        }
    }
}

return tl_ops_plugin_constant_sync_cluster