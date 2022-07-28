local snowflake = require("lib.snowflake");

-- api 默认列表
local tl_ops_constant_balance_api = {
    cache_key = {
        list = "tl_ops_balance_api_list",
        rule = "tl_ops_balance_api_rule"
    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = 1,
            url = "/*",                         -- 当前url匹配规则
            service = "tlops-demo",             -- 当前url路由到的service
            node = 0,                           -- 当前url路由到的service下的node的索引
            host = "tlops1.com",                -- 当前url处理的域名范围
            rewrite_url = "",                   -- 当前url重写后的url
        },
        random = {
            id = 1,
            url = "/*",                         -- 当前url匹配规则
            service = "tlops-demo",             -- 当前url路由到的service
            host = "tlops1.com",                -- 当前url处理的域名范围
            rewrite_url = "",                   -- 当前url重写后的url
        }
    },
    rule = {-- api rule 策略
        point = "point",        -- url路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_balance_api