local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");

---- 基础路由功能定义
local tl_ops_constant_balance = {
    cache_key = {
        api_list = "tl_ops_balance_api_list",
        api_rule = "tl_ops_balance_api_rule",
        service_list = "tl_ops_balance_service_list",
        service_rule = "tl_ops_balance_service_rule",
        lock = "tl_ops_balance_service_lock",

        ---- 以服务节点为单位路由请求成功次数记录 (区间)  int
        req_succ = "tl_ops_balance_req_succ",
        ---- 以服务节点为单位，5min为周期成功次数集合 list
        balance_5min_success = "tl_ops_balance_5min_success",
        ---- 以服务节点为单位路由请求失败次数记录 (总量) int
        req_fail = "tl_ops_balance_req_fail", 
    },
    api = {
        list = {
            url = tl_ops_constant_api.url,
            random = tl_ops_constant_api.random
        },
        rule = tl_ops_constant_api.rule.url
    },
    service = {
        list = tl_ops_constant_service.list,
        rule = tl_ops_constant_service.rule.auto_load,
    },
    count = {
        ---- 统计周期 单位/s, 默认:5min
        interval = 60 * 5           
    }
}

return tl_ops_constant_balance