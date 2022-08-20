-- tl_ops_time_alert_email_handler
-- en : request long time alert email handler
-- zn : 请求耗时告警邮件统计
-- @author iamtsm
-- @email 1905333456@qq.com

local time_alert_constant   = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant")
local cjson                 = require("cjson.safe");
local utils                 = tlops.utils
local shared                = tlops.plugin_shared


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 日志记录类型
function _M:handler(option, content)

    
end


return _M
