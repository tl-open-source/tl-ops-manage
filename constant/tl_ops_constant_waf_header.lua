local snowflake     = require("lib.snowflake");
local scope         = require("constant.tl_ops_constant_comm").tl_ops_waf_scope;

-- header waf默认列表
local tl_ops_constant_waf_header = {
    cache_key = {
        -- 持久化字段
        list = "tl_ops_waf_header_list",
        open = "tl_ops_waf_header_open",
        scope = "tl_ops_waf_header_scope"
    },
    list = {

    },
    open = true,
    scope = scope.global,
    demo = {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        keys = {                            -- 拦截的请求头名称列表
            "User-Agent","Accept"
        },      
        value = "Mozilla/5.0",              -- 当前匹配的规则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        white = true,                       -- 是否为白名单
    },
}

return tl_ops_constant_waf_header