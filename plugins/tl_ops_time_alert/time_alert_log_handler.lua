-- tl_ops_time_alert_log_handler
-- en : request long time alert log handler
-- zn : 请求耗时告警日志记录
-- @author iamtsm
-- @email 1905333456@qq.com

local time_alert_constant   = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant")
local time_alert_content    = require("plugins.tl_ops_time_alert.time_alert_content")
local cjson                 = require("cjson.safe")
local utils                 = tlops.utils

local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 日志记录类型
function _M:handler(option, content)

    local target = option.target

    local alert_log = require("utils.tl_ops_utils_log"):new(target)

    alert_log:dbg(content)

end


return _M
