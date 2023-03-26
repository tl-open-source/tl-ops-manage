-- tl_ops_waf_api 
-- en : get waf api config list
-- zn : 获取waf api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-waf-api");
local tl_ops_constant_waf_api   = require("constant.tl_ops_constant_waf_api");
local tl_ops_rt                 = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()
    local scope, _ = cache:get(tl_ops_constant_waf_api.cache_key.scope);
    if not scope or scope == nil then
        return tl_ops_rt.not_found, "not found scope", _
    end

    local open, _ = cache:get(tl_ops_constant_waf_api.cache_key.open);
    if open == nil then
        return tl_ops_rt.not_found, "not found open", _
    end
    if open == 'true' then
        open = true
    end
    if open == 'false' then
        open = false
    end

    local list_str, _ = cache:get(tl_ops_constant_waf_api.cache_key.list);
    if not list_str or list_str == nil then
        return tl_ops_rt.not_found, "not found list", _
    end

    local res_data = {}
    res_data[tl_ops_constant_waf_api.cache_key.scope] = scope
    res_data[tl_ops_constant_waf_api.cache_key.open] = open
    res_data[tl_ops_constant_waf_api.cache_key.list] = cjson.decode(list_str)

    return tl_ops_rt.ok, "success", res_data
end

local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}