local snowflake = require("lib.snowflake");
local scope = require("constant.tl_ops_constant_waf_scope");

-- cookie waf默认列表
local tl_ops_constant_waf_cookie = {
    cache_key = {
        list = "tl_ops_waf_cookie_list",
        open = "tl_ops_waf_cookie_open",
        scope = "tl_ops_waf_cookie_scope"
    },
    list = {

    },
    open = true,
    scope = scope.global,
    demo = {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        value = "select.",                  -- 当前匹配的正则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        white = true,                       -- 是否为白名单
    },
}

return tl_ops_constant_waf_cookie