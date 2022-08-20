-- tl_ops_plugin_time_alert
-- en : time_alert  
-- zn : 请求耗时告警统计插件
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_time_alert");
local utils                 = require("utils.tl_ops_utils_func");
local plugin_time_alert     = require("plugins.tl_ops_time_alert.time_alert");

local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }


function _M:new(options)
    if not options then
        options = {}
    end
    return setmetatable(options, mt)
end

function _M:tl_ops_process_after_init_worker()

    -- 启动统计器
    plugin_time_alert:tl_ops_time_alert_timer_start()

    return true, "ok"
end


function _M:tl_ops_process_after_init_log(ctx)

    -- 统计
    plugin_time_alert:tl_ops_time_alert_log(ctx)

    return true, "ok"
end


return _M
