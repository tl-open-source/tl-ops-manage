local snowflake = require("lib.snowflake");

-- param 默认列表
local tl_ops_constant_param = {
    cache_key = {
        list = "tl_ops_param_list",
        rule = "tl_ops_param_rule"
    },
    point = {

    },
    random = {

    },
    demo = {
        {
            id = snowflake.generate_id( 100 ),  -- default snow id
            key = "_tl_id",                     -- 当前请求参数匹配名称
            value = "0",                        -- 当前请求参数名称对应值                      
            service = "tlops-demo",             -- 当前请求参数路由到的service
            node = 0,                           -- 当前请求参数路由到的service下的node的索引
            host = "tlops1.com",                -- 当前请求参数处理的域名范围
        }
    },
    rule = {                    -- cookie rule 策略
        point = "point",        -- cookie路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_param