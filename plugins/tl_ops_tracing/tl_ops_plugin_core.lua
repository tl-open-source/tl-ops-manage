-- tl_ops_plugin_tracing
-- en : tracing  
-- zn : 请求追踪插件
-- @author iamtsm
-- @email 1905333456@qq.com

local uuid = require("lib.jit-uuid")
local utils = tlops.utils

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


function _M:tl_ops_process_before_init_access(ctx)
    local req = ngx.req
    local headers = req.get_headers()

    local trace_id = headers["Tl-Tracing-Id"]
    if not trace_id then
        req.set_header("Tl-Tracing-Id", uuid())
    end

    return true, "ok"
end

function _M:tl_ops_process_after_init_access(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_before_init_header(ctx)
   

    return true, "ok"
end

function _M:tl_ops_process_after_init_header(ctx)
   

    return true, "ok"
end

function _M:tl_ops_process_before_init_log(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_log(ctx)
    

    return true, "ok"
end


return _M
