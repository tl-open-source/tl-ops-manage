-- tl_ops_time_alert_robot_handler
-- en : request long time alert robot handler
-- zn : 请求耗时告警企业微信机器人通知
-- @author iamtsm
-- @email 1905333456@qq.com

local time_alert_constant   = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant")
local cjson                 = require("cjson.safe");
local utils                 = tlops.utils


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 企业微信机器人通知类型
function _M:handler(option, content)

    
end


return _M
