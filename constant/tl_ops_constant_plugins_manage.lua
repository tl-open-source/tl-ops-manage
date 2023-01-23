-- 插件列表
local tl_ops_constant_plugins_manage = {
    cache_key = {
        list = "tl_ops_plugins_list"
    },
    list = {
        {
            id = 0,
            name = "sync"
        },
        {
            id = 1,
            name = "sync_cluster"
        },
        {
            id = 2,
            name = "template"
        },
        {
            id = 3,
            name = "auth"
        },
        {
            id = 4,
            name = "ssl"
        },
        {
            id = 5,
            name = "page_proxy"
        },
        {
            id = 6,
            name = "time_alert"
        },
        {
            id = 7,
            name = "tracing"
        },
        {
            id = 8,
            name = "log_analyze"
        },
        {
            id = 9,
            name = "health_check_debug"
        },
        {
            id = 10,
            name = "cors"
        },
    },
    demo = {
        id = 1,         -- 插件id
        name = ""       -- 插件名称
    }
}


return tl_ops_constant_plugins_manage