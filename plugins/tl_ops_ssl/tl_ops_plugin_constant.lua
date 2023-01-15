-- ssl默认列表
-- ps : 可以优化为k-v结构, list结构会影响性能，当前只是简单处理了

local tl_ops_constant_ssl = {
    cache_key = {
        list = "tl_ops_ssl_list"
    },
    tlops_api = {                       -- 对外API
        get = "/tlops/ssl/list",
        set = "/tlops/ssl/set"
    },
    list = {

    },
    demo = {
        id = 1,
        host = "tlops.com",             -- 当前生效的域名
        pem = "",                       -- pem证书内容
        key = "",                       -- key证书内容
    },
    export = {
        cache_key = {
            ssl = "tl_ops_plugins_export_ssl",
        },
        tlops_api = {
            get = "/tlops/ssl/manage/get",      -- 获取插件配置数据的接口
            set = "/tlops/ssl/manage/set",      -- 修改插件配置数据的接口
        },
        ssl = {
            zname = 'SSL证书插件',
            page = "ssl/tl_ops_web_ssl.html",
            name = 'ssl',
            open = true,
            scope = "tl_ops_process_after_init_ssl,tl_ops_process_before_init_rewrite",
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

return tl_ops_constant_ssl