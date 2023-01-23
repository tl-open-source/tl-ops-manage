-- tl_ops_body
-- en : get balance post body config list
-- zn : 获取路由post body配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local snowflake                     = require("lib.snowflake");
local cache                         = require("cache.tl_ops_cache_core"):new("tl-ops-balance-body");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_body  = require("constant.tl_ops_constant_balance_body")
local cjson                         = require("cjson.safe"); 
cjson.encode_empty_table_as_object(false)

local Router = function() 
    local rule, _ = cache:get(tl_ops_constant_balance_body.cache_key.rule);
    if not rule or rule == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found rule", _);
        return;
    end

    local rule_match_mode, _ = cache:get(tl_ops_constant_balance_body.cache_key.rule_match_mode);
    if not rule_match_mode or rule_match_mode == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found rule_match_mode", _);
        return;
    end

    local list_str, _ = cache:get(tl_ops_constant_balance_body.cache_key.list);
    if not list_str or list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
        return;
    end
    
    
    local res_data = {}
    res_data[tl_ops_constant_balance_body.cache_key.rule] = rule
    res_data[tl_ops_constant_balance_body.cache_key.rule_match_mode] = rule_match_mode
    res_data[tl_ops_constant_balance_body.cache_key.list] = cjson.decode(list_str)
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router