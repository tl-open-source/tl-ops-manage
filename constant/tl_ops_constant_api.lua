local snowflake = require("lib.snowflake");
---- api 默认列表
local tl_ops_constant_api_list = {
    url = {
        {
            id = snowflake.generate_id( 100 ),  ---- default snow id
            url = "/*",                         ---- 当前url匹配规则
            service = "service1",               ---- 当前url路由到的service
            node = 0                           ---- 当前url路由到的service下的node的索引
        },
        {
            id = snowflake.generate_id( 100 ),
            url = "/api/public/*",
            service = "service1",
            node = 1
        },
        {
            id = snowflake.generate_id( 100 ),
            url = "/api/admin/*",
            service = "service2",
            node = 0
        },
        {
            id = snowflake.generate_id( 100 ),
            url = "/api/v1/*",
            service = "service2",
            node = 1
        }
    },
    random = {
        {
            id = snowflake.generate_id( 100 ),  ---- default snow id
            url = "/*",                         ---- 当前url匹配规则
            service = "service1"                ---- 当前url路由到的service
        }, 
        {
            id = snowflake.generate_id( 100 ),
            url = "/api/*",
            service = "service2"
        },
    },
    rule = {---- api rule 策略
        url = "url",        ---- url路由可指定到具体节点
        random = "random"       ---- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_api_list