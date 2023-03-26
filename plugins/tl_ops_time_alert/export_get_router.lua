-- tl_ops_time_alert_get_export
-- en : get export time_alert config
-- zn : 获取time_alert插件配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-time-alert");
local constant                  = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local str, _ = cache:get(constant.export.cache_key.time_alert);
    if not str or str == nil then
        return tl_ops_rt.not_found, "not found time_alert", _
    end

    local res_data = {}
    res_data[constant.export.cache_key.time_alert] = cjson.decode(str)

    return tl_ops_rt.ok, "success", res_data
end

local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}