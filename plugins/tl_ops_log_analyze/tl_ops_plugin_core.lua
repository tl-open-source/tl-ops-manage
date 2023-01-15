-- tl_ops_plugin_log_analyze
-- en : log_analyze  
-- zn : 日志分析插件
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_log_analyze");
local sync                  = require("plugins.tl_ops_log_analyze.sync");

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


-- 插件数据同步
function _M:sync_data()
    return sync.sync_data()
end


-- 插件数据字段同步
function _M:sync_fields()
    return sync.sync_fields()
end



return _M
