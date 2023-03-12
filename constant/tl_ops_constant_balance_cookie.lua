-- cookie 默认列表
local tl_ops_constant_balance_cookie = {
    cache_key = {
        -- 持久化字段
        list = "tl_ops_balance_cookie_list",
        rule = "tl_ops_balance_cookie_rule",
        rule_match_mode = "tl_ops_balance_cookie_rule_match_mode"
    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = 1,
            key = "_tl_session_id",             -- 当前cookie匹配名称
            value = {                           -- 当前cookie名称对应值列表  
                "ok","ok1","ok2"
            },
            service = "tlops-demo",             -- 当前cookie路由到的service
            node = 0,                           -- 当前cookie路由到的service下的node的索引
            host = "tlops1.com",                -- 当前cookie处理的域名范围
        },
        random = {
            id = 1,
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
    mode = {-- 规则匹配模式
        host = "host",          -- host优先
        cookie = "cookie",      -- cookie优先
    }
}

return tl_ops_constant_balance_cookie