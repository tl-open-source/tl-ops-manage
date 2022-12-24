local snowflake = require("lib.snowflake");

-- body 默认列表
local tl_ops_constant_balance_body = {
    cache_key = {
        list = "tl_ops_balance_body_list",
        rule = "tl_ops_balance_body_rule"
    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = 1,
            body = "iamtsm",                    -- 当前url匹配规则
            service = "tlops-demo",             -- 当前url路由到的service
            node = 0,                           -- 当前url路由到的service下的node的索引
            host = "tlops1.com",                -- 当前url处理的域名范围
        },
        random = {
            id = 1,
            body = "iamtsm",                    -- 当前url匹配规则
            service = "tlops-demo",             -- 当前url路由到的service
            host = "tlops1.com",                -- 当前url处理的域名范围
        }
    },
    rule = {-- body rule 策略
        point = "point",        -- url路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_balance_body