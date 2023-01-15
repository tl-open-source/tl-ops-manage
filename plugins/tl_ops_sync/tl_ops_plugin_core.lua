-- tl_ops_sync
-- en : sync  
-- zn : 同步器插件
-- @author iamtsm
-- @email 1905333456@qq.com

local sync                  = require("plugins.tl_ops_sync.sync");
local self_sync             = require("plugins.tl_ops_sync.self_sync");


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
    sync:tl_ops_sync_timer_start()

    return true, "ok"
end

function _M:tl_ops_process_before_init_rewrite(ctx)
    
    
    return true, "ok"
end

-- 插件数据同步
function _M:sync_data()
    return self_sync.sync_data()
end


-- 插件数据字段同步
function _M:sync_fields()
    return self_sync.sync_fields()
end


return _M
