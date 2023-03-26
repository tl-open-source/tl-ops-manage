-- tl_ops_get_time_alert
-- en : get time_alert config list
-- zn : 获取耗时告警配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-time-alert");
local constant_alert            = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local options_str, _ = cache:get(constant_alert.cache_key.options);
    if not options_str or options_str == nil then
        return tl_ops_rt.not_found, "not found options", _
    end

    local res_data = {}
    res_data[constant_alert.cache_key.options] = cjson.decode(options_str)

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}