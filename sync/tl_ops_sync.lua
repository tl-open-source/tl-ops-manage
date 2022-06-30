-- tl_ops_sync
-- en : sync data/fields
-- zn : 同步数据接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_sync_core = require("sync.tl_ops_sync_core");

local _M = {}


function _M:init( )
    -- 启动同步器
    local sync = tl_ops_sync_core:new()
    sync:tl_ops_sync_timer_start()
end


return _M
