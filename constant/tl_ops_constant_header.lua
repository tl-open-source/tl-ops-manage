local snowflake = require("lib.snowflake");

-- header 默认列表
local tl_ops_constant_header = {
    cache_key = {
        list = "tl_ops_header_list",
        rule = "tl_ops_header_rule"
    },
    point = {

    },
    random = {

    },
    demo = {
        {
            id = snowflake.generate_id( 100 ),  -- default snow id
            key = "content-type",               -- 当前header匹配名称
            value = "text/fragment+html",       -- 当前header名称对应值                      
            service = "tlops-demo",             -- 当前header路由到的service
            node = 0,                           -- 当前header路由到的service下的node的索引
            host = "tlops1.com",                -- 当前header处理的域名范围
        }
    },
    rule = {                    -- header rule 策略
        point = "point",        -- header路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_header