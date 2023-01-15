local tl_ops_plugin_constant_cors = {
    cache_key = {

    },
    export = {
        cache_key = {
            cors = "tl_ops_plugins_export_cors",
        },
        tlops_api = {
            get = "/tlops/cors/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/cors/manage/set",           -- 修改插件配置数据的接口
        },
        cors = {
            zname = '跨域插件',
            page = "",
            name = 'cors',
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

return tl_ops_plugin_constant_cors;