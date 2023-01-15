local tl_ops_plugin_constant_health_check_debug = {
    cache_key = {

    },
    export = {
        cache_key = {
            health_check_debug = "tl_ops_plugins_export_health_check_debug",
        },
        tlops_api = {
            get = "/tlops/health-check-debug/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/health-check-debug/manage/set",           -- 修改插件配置数据的接口
        },
        health_check_debug = {
            zname = '健康检查调试插件',
            page = "",
            name = 'health_check_debug',
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

return tl_ops_plugin_constant_health_check_debug;