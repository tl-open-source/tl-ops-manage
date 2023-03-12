-- param 默认列表
local tl_ops_constant_balance_param = {
    cache_key = {
        -- 持久化字段
        list = "tl_ops_balance_param_list",
        rule = "tl_ops_balance_param_rule",
        rule_match_mode = "tl_ops_balance_param_rule_match_mode"

    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = 1,
            key = "_tl_id",                     -- 当前请求参数匹配名称
            value = {                           -- 当前请求参数名称对应值列表  
                "text/fragment+html","text/plain"
            },                      
            service = "tlops-demo",             -- 当前请求参数路由到的service
            node = 0,                           -- 当前请求参数路由到的service下的node的索引
            host = "tlops1.com",                -- 当前请求参数处理的域名范围
        },
        random = {
            id = 1,
            key = "_tl_id",                     -- 当前请求参数匹配名称
            value = {                           -- 当前请求参数名称对应值列表  
                "text/fragment+html","text/plain"
            },                      
            service = "tlops-demo",             -- 当前请求参数路由到的service
            host = "tlops1.com",                -- 当前请求参数处理的域名范围
        }
    },
    rule = {                    -- rule 策略
        point = "point",        -- 路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
    mode = {-- 规则匹配模式
        host = "host",          -- host优先
        param = "param",        -- param优先
    }
}

return tl_ops_constant_balance_param