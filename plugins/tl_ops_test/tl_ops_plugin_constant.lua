local tl_ops_plugin_constant_test = {
    cache_key = {

    },
    export = {
        cache_key = {
            test = "tl_ops_plugins_export_test",
        },
        tlops_api = {
            get = "/tlops/test/manage/get",           -- 获取插件配置数据的接口
            set = "/tlops/test/manage/set",           -- 修改插件配置数据的接口
        },
        test ={
            zname = '插件默认模板',
            page = "",
            name = 'test',
            open = false,
            scope = [[
                tl_ops_process_before_init_worker,tl_ops_process_after_init_worker,
                tl_ops_process_before_init_ssl,tl_ops_process_after_init_ssl,
                tl_ops_process_before_init_rewrite, tl_ops_process_after_init_rewrite,
                tl_ops_process_before_init_access, tl_ops_process_after_init_access,
                tl_ops_process_before_init_balancer,tl_ops_process_after_init_balancer,
                tl_ops_process_before_init_header, tl_ops_process_after_init_header,
                tl_ops_process_before_init_body, tl_ops_process_after_init_body,
                tl_ops_process_before_init_log, tl_ops_process_after_init_log
            ]],
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

return tl_ops_plugin_constant_test;