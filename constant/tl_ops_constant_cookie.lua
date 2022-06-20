local snowflake = require("lib.snowflake");

-- cookie 默认列表
local tl_ops_constant_cookie = {
    cache_key = {
        list = "tl_ops_cookie_list",
        rule = "tl_ops_cookie_rule"
    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = snowflake.generate_id( 100 ),  -- default snow id
            key = "_tl_session_id",             -- 当前cookie匹配名称
            value = {                           -- 当前cookie名称对应值列表  
                "ok","ok1","ok2"
            },                                        
            service = "tlops-demo",             -- 当前cookie路由到的service
            node = 0,                           -- 当前cookie路由到的service下的node的索引
            host = "tlops1.com",                -- 当前cookie处理的域名范围
        },
        random = {
            id = snowflake.generate_id( 100 ),  -- default snow id
            key = "_tl_session_id",             -- 当前cookie匹配名称
            value = {                           -- 当前cookie名称对应值列表  
                "ok","ok1","ok2"
            },                                        
            service = "tlops-demo",             -- 当前cookie路由到的service
            host = "tlops1.com",                -- 当前cookie处理的域名范围
        }
    },
    rule = {                    -- cookie rule 策略
        point = "point",        -- cookie路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_cookie