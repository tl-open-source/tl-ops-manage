-- tl_ops_alert_set
-- en : set alert config list
-- zn : 更新alert配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local snowflake                 = require("lib.snowflake");
local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-time-alert");
local constant_alert            = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local options, _ = tl_ops_utils_func:get_req_post_args_by_name(constant_alert.cache_key.options, 1);
    if not options or options == nil then
        return tl_ops_rt.args_error ,"alert args err1", _
    end

    -- 更新生成id
    for _, alert in ipairs(options) do
        if not alert.id or alert.id == nil or alert.id == '' then
            alert.id = snowflake.generate_id( 100 )
        end
        if not alert.updatetime or alert.updatetime == nil or alert.updatetime == '' then
            alert.updatetime = ngx.localtime()
        end
        if alert.change and alert.change == true then
            alert.updatetime = ngx.localtime()
            alert.change = nil
        end
    end

    local res, _ = cache:set(constant_alert.cache_key.options, cjson.encode(options));
    if not res then
        return tl_ops_rt.error, "set options err ", _
    end

    local res_data = {}
    res_data[constant_alert.cache_key.options] = options

    return tl_ops_rt.ok, "ok", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}