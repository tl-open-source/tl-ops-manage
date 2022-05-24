local snowflake = require("lib.snowflake");
---- api 默认列表
local tl_ops_constant_api_list = {
    cache_key = {
        api_list = "tl_ops_api_list",
        api_rule = "tl_ops_api_rule"
    },
    url = {

    },
    random = {

    },
    demo = {
        {
            id = snowflake.generate_id( 100 ),  ---- default snow id
            url = "/*",                         ---- 当前url匹配规则
            service = "tlops-demo",             ---- 当前url路由到的service
            node = 0,                           ---- 当前url路由到的service下的node的索引
            host = "tlops1.com",                ---- 当前url处理的域名范围
        }
    },
    rule = {---- api rule 策略
        url = "url",            ---- url路由可指定到具体节点
        random = "random"       ---- 随机路由可指定到具体服务
    },
}

return tl_ops_constant_api_list