-- tl_ops_waf_header 
-- en : get waf header config list
-- zn : 获取waf header配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local snowflake                     = require("lib.snowflake");
local cache                         = require("cache.tl_ops_cache_core"):new("tl-ops-waf-header");
local tl_ops_constant_waf_header    = require("constant.tl_ops_constant_waf_header");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local cjson                         = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function()
    local scope, _ = cache:get(tl_ops_constant_waf_header.cache_key.scope);
    if not scope or scope == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found scope", _);
        return;
    end

    local open, _ = cache:get(tl_ops_constant_waf_header.cache_key.open);
    if open == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found open", _);
        return;
    end
    
    local list_str, _ = cache:get(tl_ops_constant_waf_header.cache_key.list);
    if not list_str or list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
        return;
    end
    
    
    local res_data = {}
    res_data[tl_ops_constant_waf_header.cache_key.scope] = scope
    res_data[tl_ops_constant_waf_header.cache_key.open] = open
    res_data[tl_ops_constant_waf_header.cache_key.list] = cjson.decode(list_str)
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router