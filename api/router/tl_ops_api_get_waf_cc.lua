-- tl_ops_waf_cc 
-- en : get waf cc config list
-- zn : 获取waf cc配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-waf-cc");
local tl_ops_constant_waf_cc = require("constant.tl_ops_constant_waf_cc");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local Router = function()
    local scope, _ = cache:get(tl_ops_constant_waf_cc.cache_key.scope);
    if not scope or scope == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found scope", _);
        return;
    end

    local open, _ = cache:get(tl_ops_constant_waf_cc.cache_key.open);
    if open == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found open", _);
        return;
    end
    
    local list_str, _ = cache:get(tl_ops_constant_waf_cc.cache_key.list);
    if not list_str or list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
        return;
    end
    
    
    local res_data = {}
    res_data[tl_ops_constant_waf_cc.cache_key.scope] = scope
    res_data[tl_ops_constant_waf_cc.cache_key.open] = open
    res_data[tl_ops_constant_waf_cc.cache_key.list] = cjson.decode(list_str)
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router