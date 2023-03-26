-- tl_ops_health_check_debug_get_export
-- en : get export health_check_debug config
-- zn : 获取health_check_debug插件配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-health-check-debug");
local constant                  = require("plugins.tl_ops_health_check_debug.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local str, _ = cache:get(constant.export.cache_key.health_check_debug);
    if not str or str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found health_check_debug", _);
        return;
    end

    local res_data = {}
    res_data[constant.export.cache_key.health_check_debug] = cjson.decode(str)

    return tl_ops_rt.ok, "success", res_data
end

local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}
