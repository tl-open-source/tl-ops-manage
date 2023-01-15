-- tl_ops_plugin_ssl
-- en : ssl  
-- zn : ssl插件
-- @author iamtsm
-- @email 1905333456@qq.com

local ssl                   = require("plugins.tl_ops_ssl.ssl");
local sync                  = require("plugins.tl_ops_ssl.sync");


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


function _M:tl_ops_process_after_init_ssl()
    return ssl:ssl_core()
end


function _M:tl_ops_process_before_init_rewrite(ctx)

    
    return true, "ok"
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
