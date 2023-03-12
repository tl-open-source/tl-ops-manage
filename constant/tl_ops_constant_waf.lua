local tl_ops_constant_waf_ip        = require("constant.tl_ops_constant_waf_ip");
local tl_ops_constant_waf_api       = require("constant.tl_ops_constant_waf_api");
local tl_ops_constant_waf_cookie    = require("constant.tl_ops_constant_waf_cookie");
local tl_ops_constant_waf_header    = require("constant.tl_ops_constant_waf_header");
local tl_ops_constant_waf_param     = require("constant.tl_ops_constant_waf_param");
local tl_ops_constant_waf_cc        = require("constant.tl_ops_constant_waf_cc");

-- waf规则配置

local tl_ops_constant_waf = {
    cache_key = {
        -- 持久化字段
        waf_ip = "tl_ops_waf_ip_err",
        waf_api = "tl_ops_waf_api_err",
        waf_cc = "tl_ops_waf_cc_err",
        waf_header = "tl_ops_waf_header_err",
        waf_cookie = "tl_ops_waf_cookie_err",
        waf_param = "tl_ops_waf_param_err",
    },
    waf_mode = "Tl-Waf-Mode",
    ip = {
        list = tl_ops_constant_waf_ip.list,
        scope = tl_ops_constant_waf_ip.scope,
        open = tl_ops_constant_waf_ip.open,
    },
    api = {
        list = tl_ops_constant_waf_api.list,
        scope = tl_ops_constant_waf_api.scope,
        open = tl_ops_constant_waf_api.open,
    },
    param = {
        list = tl_ops_constant_waf_param.list,
        scope = tl_ops_constant_waf_api.scope,
        open = tl_ops_constant_waf_param.open,
    },
    cookie = {
        list = tl_ops_constant_waf_cookie.list,
        scope = tl_ops_constant_waf_api.scope,
        open = tl_ops_constant_waf_cookie.open,
    },
    header = {
        list = tl_ops_constant_waf_header.list,
        scope = tl_ops_constant_waf_api.scope,
        open = tl_ops_constant_waf_header.open,
    },
    cc = {
        list = tl_ops_constant_waf_cc.list,
        scope = tl_ops_constant_waf_api.scope,
        open = tl_ops_constant_waf_cc.open,
    },
    count = {
        interval = 10       -- 统计周期 单位/s
    },
    waf_ip = {
        
    },
    waf_api = {
        
    },
    waf_cc = {
        
    },
    waf_header = {
        
    },
    waf_cookie = {
        
    },
    waf_param = {
        
    },
    demo = {
        waf_ip = {   -- waf拦截ip返回错误码
            zname = "请求IP拦截",
            code = 503,
            content_type = "text/html",
            content = "<p> waf_ip err </p>"
        },
        waf_api = {   -- waf拦截api返回错误码
            zname = "请求API拦截",
            code = 503,
            content_type = "text/html",
            content = "<p> waf_api err </p>"
        },
        waf_cc = {   -- waf拦截cc返回错误码
            zname = "CC攻击拦截",
            code = 503,
            content_type = "text/html",
            content = "<p> waf_cc err </p>"
        },
        waf_header = {   -- waf拦截header返回错误码
            zname = "请求头拦截",
            code = 503,
            content_type = "text/html",
            content = "<p> waf_header err </p>"
        },
        waf_cookie = {   -- waf拦截cookie返回错误码
            zname = "请求Cookie拦截",
            code = 503,
            content_type = "text/html",
            content = "<p> waf_cookie err </p>"
        },
        waf_param = {   -- waf拦截args返回错误码
            zname = "请求参数拦截",
            code = 503,
            content_type = "text/html",
            content = "<p> waf_param err </p>"
        }
    }
}

return tl_ops_constant_waf