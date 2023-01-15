local tl_ops_plugin_constant_tracing = {
    tracing_rid = "Tl-Tracing-Rid",
    export = {
        cache_key = {
            tracing = "tl_ops_plugins_export_tracing",
        },
        tracing = {
            zname = '请求链路追踪插件',
            page = "",
            name = 'tracing',
            open = true,
            scope = "tl_ops_process_before_init_worker,tl_ops_process_before_init_rewrite,tl_ops_process_before_init_header",
        },
        tlops_api = {
            get = "/tlops/tracing/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/tracing/manage/set",           -- 修改插件配置数据的接口
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

return tl_ops_plugin_constant_tracing