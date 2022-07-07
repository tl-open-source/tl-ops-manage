local tl_ops_constant_balance_api       = require("constant.tl_ops_constant_balance_api");
local tl_ops_constant_balance_cookie    = require("constant.tl_ops_constant_balance_cookie");
local tl_ops_constant_balance_header    = require("constant.tl_ops_constant_balance_header");
local tl_ops_constant_balance_param     = require("constant.tl_ops_constant_balance_param");
local tl_ops_constant_service           = require("constant.tl_ops_constant_service");


-- 基础路由功能定义
-- 路由类型 : api > param > cookie

local tl_ops_constant_balance = {
    cache_key = {
        lock = "tl_ops_balance_lock",
        options = "tl_ops_balance_options",
        service_empty = "tl_ops_balance_service_empty_err_code",
        mode_empty = "tl_ops_balance_mode_empty_err_code",
        host_empty = "tl_ops_balance_host_empty_err_code",
        host_pass = "tl_ops_balance_host_pass_err_code",
        token_limit = "tl_ops_balance_token_limit_err_code",
        leak_limit = "tl_ops_balance_leak_limit_err_code",
        offline = "tl_ops_balance_offline_err_code",
        req_succ = "tl_ops_balance_req_succ",                           -- 以服务节点为单位路由请求成功次数     int
        req_fail = "tl_ops_balance_req_fail",                           -- 以服务节点为单位路由请求失败次数     int
        balance_interval_success = "tl_ops_balance_interval_success",   -- 以服务节点为单位，周期内成功次数集合 list
    },
    api = {
        list = {
            point = tl_ops_constant_balance_api.point,
            random = tl_ops_constant_balance_api.random
        },
        rule = tl_ops_constant_balance_api.rule.point
    },
    cookie = {
        list = {
            point = tl_ops_constant_balance_cookie.point,
            random = tl_ops_constant_balance_cookie.random
        },
        rule = tl_ops_constant_balance_cookie.rule.point
    },
    header = {
        list = {
            point = tl_ops_constant_balance_header.point,
            random = tl_ops_constant_balance_header.random
        },
        rule = tl_ops_constant_balance_header.rule.point
    },
    param = {
        list = {
            point = tl_ops_constant_balance_param.point,
            random = tl_ops_constant_balance_param.random
        },
        rule = tl_ops_constant_balance_param.rule.point
    },
    count = {
        interval = 10       -- 统计周期 单位/s, 默认:5min
    },
    options = {
        
    },
    demo = {
        tl_ops_balance_service_empty_err_code = 503,    -- 路由服务空错误码
        tl_ops_balance_mode_empty_err_code = 503,       -- 路由匹配空错误码
        tl_ops_balance_host_empty_err_code = 503,       -- 路由域名空错误码
        tl_ops_balance_host_pass_err_code = 503,        -- 路由服务不匹配错误码
        tl_ops_balance_token_limit_err_code = 503,      -- 路由令牌桶限流错误码
        tl_ops_balance_leak_limit_err_code = 503,       -- 路由漏桶限流错误码
        tl_ops_balance_offline_err_code = 503,          -- 路由服务下线错误码
    }
}

return tl_ops_constant_balance