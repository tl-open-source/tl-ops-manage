local snowflake     = require("lib.snowflake");
local scope         = require("constant.tl_ops_constant_comm").tl_ops_waf_scope;

-- cc waf默认列表
local tl_ops_constant_waf_cc = {
    cache_key = {
        -- 临时字段
        prefix = "tl_ops_waf_cc_prefix",

        -- 持久化字段
        list = "tl_ops_waf_cc_list",
        open = "tl_ops_waf_cc_open",
        scope = "tl_ops_waf_cc_scope",
    },
    list = {

    },
    open = true,
    scope = scope.global,
    demo = {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        time = 60,                          -- cc记录过期时间
        count = 100,                        -- time内触发次数
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
    },
}

return tl_ops_constant_waf_cc