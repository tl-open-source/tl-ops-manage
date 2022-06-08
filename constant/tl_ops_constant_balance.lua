local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_cookie = require("constant.tl_ops_constant_cookie");
local tl_ops_constant_header = require("constant.tl_ops_constant_header");
local tl_ops_constant_param = require("constant.tl_ops_constant_param");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");


-- 基础路由功能定义
-- 路由类型 : api > param > cookie

local tl_ops_constant_balance = {
    cache_key = {
        lock = "tl_ops_balance_lock",
        req_succ = "tl_ops_balance_req_succ",                   -- 以服务节点为单位路由请求成功次数记录 (区间)  int
        req_fail = "tl_ops_balance_req_fail",                   -- 以服务节点为单位路由请求失败次数记录 (总量) int
        balance_5min_success = "tl_ops_balance_5min_success",   -- 以服务节点为单位，5min为周期成功次数集合 list
    },
    api = {
        list = {
            point = tl_ops_constant_api.point,
            random = tl_ops_constant_api.random
        },
        rule = tl_ops_constant_api.rule.point
    },
    cookie = {
        list = {
            point = tl_ops_constant_cookie.point,
            random = tl_ops_constant_cookie.random
        },
        rule = tl_ops_constant_cookie.rule.point
    },
    header = {
        list = {
            point = tl_ops_constant_header.point,
            random = tl_ops_constant_header.random
        },
        rule = tl_ops_constant_header.rule.point
    },
    param = {
        list = {
            point = tl_ops_constant_param.point,
            random = tl_ops_constant_param.random
        },
        rule = tl_ops_constant_param.rule.point
    },
    count = {
        interval = 5 * 60       -- 统计周期 单位/s, 默认:5min
    }
}

return tl_ops_constant_balance