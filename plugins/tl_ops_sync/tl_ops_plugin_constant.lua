
local tl_ops_plugin_sync_constant = {
    fields = {
        -- 同步字段器，开启此选项后，将在每次启动nginx时，会执行一次同步字段。
        open = true,

        -- 同步模块定义，同步字段器需要同步的模块，如果新增需要持久化的模块，需要在此定义
        module = {
            -- 内置模块
            "service", "health", "limit", 
            "balance", "balance_api", "balance_body", "balance_cookie", "balance_header", "balance_param",
            "waf", "waf_ip", "waf_api", "waf_cc", "waf_header", "waf_cookie", "waf_param", "plugins_manage",

            -- 插件模块
            "ssl", "auth", "time_alert",  "page_proxy", "tracing", "cors", "log_analyze", 
            "health_check_debug", "template", "sync", "sync_cluster"
        }
    },
    data = {
        -- 同步数据器，开启此选项后，将在每次启动nginx时，会执行一次同步数据。
        open = true,

        -- 同步模块定义，同步数据器需要同步的模块，如果新增需要持久化的模块，需要在此定义，
        -- 注意：之所以这里的模块不包含 ‘health模块’，‘service模块’，‘limit模块’
        -- 是因为这些模块的数据是在定时器中，而定时器中的数据同步是由其各自的动态配置器处理。
        -- 注意：不支持 ‘balance模块’，‘waf模块’
        module = {
            -- 内置模块
            "balance_api", "balance_body", "balance_cookie", "balance_header", "balance_param",
            "waf_ip", "waf_api", "waf_cc", "waf_header", "waf_cookie", "waf_param", "plugins_manage",
            
            -- 插件模块
            "ssl", "auth", "time_alert",  "page_proxy", "tracing", "cors", "log_analyze", 
            "health_check_debug", "template", "sync", "sync_cluster"
        }
    },
    export = {
        cache_key = {
            sync = "tl_ops_plugins_export_sync",
        },
        tlops_api = {
            get = "/tlops/sync/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/sync/manage/set",           -- 修改插件配置数据的接口
        },
        sync = {
            zname = '数据字段同步预热插件',
            page = "",
            name = 'sync',
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

return tl_ops_plugin_sync_constant