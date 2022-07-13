-- tl_ops_plugin_sync
-- en : sync  
-- zn : 同步器插件
-- @author iamtsm
-- @email 1905333456@qq.com

local plugin_sync = require("plugins.tl_ops_sync.sync");

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

    -- 启动同步器
    plugin_sync:tl_ops_sync_timer_start()

    return true, "ok"
end

return _M
