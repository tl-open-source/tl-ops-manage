local match_mode = require("constant.tl_ops_constant_comm").tl_ops_match_mode;

-- body 默认列表
local tl_ops_constant_balance_body = {
    cache_key = {
        list = "tl_ops_balance_body_list",
        rule = "tl_ops_balance_body_rule",
        rule_match_mode = "tl_ops_balance_body_rule_match_mode"
    },
    point = {

    },
    random = {

    },
    demo = {
        point = {
            id = 1,
            body = "iamtsm",                            -- 当前url匹配规则
            match_mode = match_mode.reg,                -- 正则匹配模式
            service = "tlops-demo",                     -- 当前url路由到的service
            node = 0,                                   -- 当前url路由到的service下的node的索引
            host = "tlops1.com",                        -- 当前url处理的域名范围
        },
        random = {
            id = 1,
            body = "iamtsm",                            -- 当前url匹配规则
            match_mode = match_mode.all,                -- 精准匹配模式
            service = "tlops-demo",                     -- 当前url路由到的service
            host = "tlops1.com",                        -- 当前url处理的域名范围
        }
    },
    rule = {-- body rule 策略
        point = "point",        -- url路由可指定到具体节点
        random = "random"       -- 随机路由可指定到具体服务
    },
    mode = {-- 规则匹配模式
        host = "host",          -- host优先
        body = "body",          -- body优先
    }
}

return tl_ops_constant_balance_body