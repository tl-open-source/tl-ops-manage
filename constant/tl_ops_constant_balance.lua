local tl_ops_constant_balance_api       = require("constant.tl_ops_constant_balance_api");
local tl_ops_constant_balance_body      = require("constant.tl_ops_constant_balance_body");
local tl_ops_constant_balance_cookie    = require("constant.tl_ops_constant_balance_cookie");
local tl_ops_constant_balance_header    = require("constant.tl_ops_constant_balance_header");
local tl_ops_constant_balance_param     = require("constant.tl_ops_constant_balance_param");


-- 基础路由功能定义
-- 路由类型 : api > param > cookie > header > body

local tl_ops_constant_balance = {
    cache_key = {
        -- 持久化字段
        service_empty = "tl_ops_balance_service_empty_err",
        mode_empty = "tl_ops_balance_mode_empty_err",
        host_empty = "tl_ops_balance_host_empty_err",
        host_pass = "tl_ops_balance_host_pass_err",
        token_limit = "tl_ops_balance_token_limit_err",
        leak_limit = "tl_ops_balance_leak_limit_err",
        offline = "tl_ops_balance_offline_err",
    },
    proxy_server = "Tl-Proxy-Server",   -- 请求头标记
    proxy_state = "Tl-Proxy-State",
    proxy_mode = "Tl-Proxy-Mode",
    proxy_prefix = "Tl-Proxy-Prefix",
    api = {
        list = {
            point = tl_ops_constant_balance_api.point,
            random = tl_ops_constant_balance_api.random
        },
        rule = tl_ops_constant_balance_api.rule.point,
        rule_match_mode = tl_ops_constant_balance_api.mode.host
    },
    body = {
        list = {
            point = tl_ops_constant_balance_body.point,
            random = tl_ops_constant_balance_body.random
        },
        rule = tl_ops_constant_balance_body.rule.point,
        rule_match_mode = tl_ops_constant_balance_body.mode.host
    },
    cookie = {
        list = {
            point = tl_ops_constant_balance_cookie.point,
            random = tl_ops_constant_balance_cookie.random
        },
        rule = tl_ops_constant_balance_cookie.rule.point,
        rule_match_mode = tl_ops_constant_balance_cookie.mode.host
    },
    header = {
        list = {
            point = tl_ops_constant_balance_header.point,
            random = tl_ops_constant_balance_header.random
        },
        rule = tl_ops_constant_balance_header.rule.point,
        rule_match_mode = tl_ops_constant_balance_header.mode.host
    },
    param = {
        list = {
            point = tl_ops_constant_balance_param.point,
            random = tl_ops_constant_balance_param.random
        },
        rule = tl_ops_constant_balance_param.rule.point,
        rule_match_mode = tl_ops_constant_balance_param.mode.host
    },
    service_empty = {
        
    },
    mode_empty = {
        
    },
    host_empty = {
        
    },
    host_pass = {
        
    },
    token_limit = {
        
    },
    leak_limit = {
        
    },
    offline = {
        
    },
    demo = {
        service_empty = {   -- 路由服务空错误码
            zname = '路由服务为空',
            code = 503,
            content_type = "text/html",
            content = "<p> service_empty err </p>"
        },
        mode_empty = {   -- 路由匹配空错误码
            zname = '路由匹配为空',
            code = 503,
            content_type = "text/html",
            content = "<p> mode_empty err </p>"
        },
        host_empty = {   -- 路由域名空错误码
            zname = '路由域名为空',
            code = 503,
            content_type = "text/html",
            content = "<p> host_empty err </p>"
        },
        host_pass = {   -- 路由服务不匹配错误码
            zname = '路由服务不匹配',
            code = 503,
            content_type = "text/html",
            content = "<p> host_pass err </p>"
        },
        token_limit = {   -- 路由令牌桶限流错误码
            zname = '路由令牌桶限流',
            code = 503,
            content_type = "text/html",
            content = "<p> token_limit err </p>"
        },
        leak_limit = {   -- 路由漏桶限流错误码
            zname = '路由漏桶限流',
            code = 503,
            content_type = "text/html",
            content = "<p> leak_limit err </p>"
        },
        offline = {   -- 路由服务下线错误码
            zname = '路由服务下线',
            code = 503,
            content_type = "text/html",
            content = "<p> offline err </p>"
        },
    }
}

return tl_ops_constant_balance