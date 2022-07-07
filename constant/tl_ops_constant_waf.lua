local tl_ops_constant_waf_ip        = require("constant.tl_ops_constant_waf_ip");
local tl_ops_constant_waf_api       = require("constant.tl_ops_constant_waf_api");
local tl_ops_constant_waf_cookie    = require("constant.tl_ops_constant_waf_cookie");
local tl_ops_constant_waf_header    = require("constant.tl_ops_constant_waf_header");
local tl_ops_constant_waf_param     = require("constant.tl_ops_constant_waf_param");
local tl_ops_constant_waf_cc        = require("constant.tl_ops_constant_waf_cc");
local tl_ops_constant_service       = require("constant.tl_ops_constant_service");

-- waf规则配置

local tl_ops_constant_waf = {
    cache_key = {
        lock = "tl_ops_waf_lock",
        options = "tl_ops_waf_options",
        ip = "tl_ops_waf_ip_err_code",
        api = "tl_ops_waf_api_err_code",
        cc = "tl_ops_waf_cc_err_code",
        header = "tl_ops_waf_header_err_code",
        cookie = "tl_ops_waf_cookie_err_code",
        param = "tl_ops_waf_param_err_code",

        req_ip = "tl_ops_waf_req_ip",           -- waf统计, waf-ip命中次数
        req_api = "tl_ops_waf_req_api",
        req_cc = "tl_ops_waf_req_cc",
        req_header = "tl_ops_waf_req_header",
        req_cookie = "tl_ops_waf_req_cookie",
        req_param = "tl_ops_waf_req_param",
        waf_interval_success = "tl_ops_waf_interval_success",   -- 以服务节点为单位，周期内拦截成功次数集合 list
    },
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
    options = {
        
    },
    demo = {
        tl_ops_waf_ip_err_code = 503,           -- waf拦截ip返回错误码
        tl_ops_waf_api_err_code = 503,          -- waf拦截api返回错误码
        tl_ops_waf_cc_err_code = 503,           -- waf拦截cc返回错误码
        tl_ops_waf_header_err_code = 503,       -- waf拦截header返回错误码
        tl_ops_waf_cookie_err_code = 503,       -- waf拦截cookie返回错误码
        tl_ops_waf_param_err_code = 503,        -- waf拦截args返回错误码
    }
}

return tl_ops_constant_waf