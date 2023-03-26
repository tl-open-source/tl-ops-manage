-- tl_ops_api 
-- en : get balance api config list
-- zn : 获取路由api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                         = require("cache.tl_ops_cache_core"):new("tl-ops-balance-api");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_api   = require("constant.tl_ops_constant_balance_api")
local cjson                         = require("cjson.safe"); 
cjson.encode_empty_table_as_object(false)

local Handler = function()
    local rule, _ = cache:get(tl_ops_constant_balance_api.cache_key.rule);
    if not rule or rule == nil then
        return tl_ops_rt.not_found, "not found rule", _
    end

    local rule_match_mode, _ = cache:get(tl_ops_constant_balance_api.cache_key.rule_match_mode);
    if not rule_match_mode or rule_match_mode == nil then
        return tl_ops_rt.not_found, "not found rule_match_mode", _
    end

    local list_str, _ = cache:get(tl_ops_constant_balance_api.cache_key.list);
    if not list_str or list_str == nil then
        return tl_ops_rt.not_found, "not found list", _
    end

    local res_data = {}
    res_data[tl_ops_constant_balance_api.cache_key.rule] = rule
    res_data[tl_ops_constant_balance_api.cache_key.rule_match_mode] = rule_match_mode
    res_data[tl_ops_constant_balance_api.cache_key.list] = cjson.decode(list_str)

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}