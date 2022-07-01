local snowflake = require("lib.snowflake");

-- header 默认列表
local tl_ops_constant_balance_header = {
    cache_key = {
        list = "tl_ops_balance_header_list",
        rule = "tl_ops_balance_header_rule"
    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = 1,
            key = "content-type",               -- 当前请求头匹配名称
            value = {                           -- 当前请求头名称对应值列表  
                "text/fragment+html","text/plain"
            },
            service = "tlops-demo",             -- 当前请求头路由到的service
            node = 0,                           -- 当前请求头路由到的service下的node的索引
            host = "tlops1.com",                -- 当前请求头处理的域名范围
        },
        random = {
            id = 1,
            key = "content-type",               -- 当前请求头匹配名称
            value = {                           -- 当前请求头名称对应值列表  
                "text/fragment+html","text/plain"
            },
            service = "tlops-demo",             -- 当前请求头路由到的service
            host = "tlops1.com",                -- 当前请求头处理的域名范围
        }
    },
    rule = {                    -- header rule 策略
        point = "point",        -- header路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_balance_header