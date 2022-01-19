local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");

---- 基础路由功能定义
local tl_ops_constant_balance = {
    api = {
        list = {
            cache_key = "tl_ops_balance_api_list",
            default = {
                url = tl_ops_constant_api.url,
                random = tl_ops_constant_api.random
            }
        },
        rule = {
            cache_key = "tl_ops_balance_api_rule",
            default = tl_ops_constant_api.rule.url
        }
    },
    service = {
        list = {
            cache_key = "tl_ops_balance_service_list",
            default = tl_ops_constant_service.list
        },
        rule = {
            cache_key = "tl_ops_balance_service_rule",
            default = tl_ops_constant_service.rule.auto_load
        },
    }
}

return tl_ops_constant_balance