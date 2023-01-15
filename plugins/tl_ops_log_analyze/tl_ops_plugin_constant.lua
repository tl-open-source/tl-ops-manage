local tl_ops_plugin_constant_log_analyze = {
    cache_key = {

    },
    export = {
        cache_key = {
            log_analyze = "tl_ops_plugins_export_log_analyze",
        },
        tlops_api = {
            get = "/tlops/log-analyze/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/log-analyze/manage/set",           -- 修改插件配置数据的接口
        },
        log_analyze = {
            zname = '日志分析插件',
            page = "",
            name = 'log_analyze',
            open = true,
            scope = "tl_ops_process_before_init_rewrite",
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

return tl_ops_plugin_constant_log_analyze;