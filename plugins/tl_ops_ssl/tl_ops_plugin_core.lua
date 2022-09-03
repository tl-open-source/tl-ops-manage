-- tl_ops_plugin_ssl
-- en : ssl  
-- zn : ssl插件
-- @author iamtsm
-- @email 1905333456@qq.com

local ssl               = require("plugins.tl_ops_ssl.ssl");
local sync              = require("plugins.tl_ops_ssl.sync");
local ssl_set_router    = require("plugins.tl_ops_ssl.set_ssl");
local ssl_get_router    = require("plugins.tl_ops_ssl.get_ssl");
local ssl_set_router    = require("plugins.tl_ops_ssl.set_ssl");
local constant_ssl      = require("plugins.tl_ops_ssl.tl_ops_plugin_constant")

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

    ctx.tlops_api[constant_ssl.tlops_api.get] = ssl_get_router

    ctx.tlops_api[constant_ssl.tlops_api.set] = ssl_set_router
    
    return true, "ok"
end


-- 插件数据同步
function _M:sync_data()
    sync.sync_data()
end


-- 插件数据字段同步
function _M:sync_fields()
    sync.sync_fields()
end



return _M
