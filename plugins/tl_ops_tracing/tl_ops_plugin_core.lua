-- tl_ops_plugin_tracing
-- en : tracing  
-- zn : 请求追踪插件
-- @author iamtsm
-- @email 1905333456@qq.com

local uuid                      = require("lib.jit-uuid")
local utils                     = tlops.utils
local sync                      = require("plugins.tl_ops_tracing.sync");
local constant                  = require("plugins.tl_ops_tracing.tl_ops_plugin_constant")

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

function _M:tl_ops_process_before_init_worker()

    uuid.seed()

    return true, "ok"
end


function _M:tl_ops_process_before_init_rewrite(ctx)

    local headers = ngx.req.get_headers()

    local tracing_rid = headers[constant.tracing_rid]
    if not tracing_rid then
        local new_tracing_rid = uuid()
        ngx.req.set_header(constant.tracing_rid, new_tracing_rid)
    end

    return true, "ok"
end


function _M:tl_ops_process_before_init_header(ctx)

    local tracing_rid = ngx.header[constant.tracing_rid]
    if not tracing_rid then
        local headers = ngx.req.get_headers()
        ngx.header[constant.tracing_rid] = headers[constant.tracing_rid]
    end
    
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
