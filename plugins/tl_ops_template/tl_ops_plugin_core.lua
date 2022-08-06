-- tl_ops_plugin_template
-- en : template  
-- zn : 插件示例
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_template");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

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


    return true, "ok"
end

function _M:tl_ops_process_after_init_worker()


    return true, "ok"
end

function _M:tl_ops_process_before_init_ssl()


    return true, "ok"
end

function _M:tl_ops_process_after_init_ssl()


    return true, "ok"
end

function _M:tl_ops_process_before_init_rewrite()


    return true, "ok"
end

function _M:tl_ops_process_after_init_rewrite()


    return true, "ok"
end

function _M:tl_ops_process_before_init_access(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_access(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_before_init_content(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_content(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_before_init_balancer(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_balancer(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_before_init_header(ctx)
   

    return true, "ok"
end

function _M:tl_ops_process_after_init_header(ctx)
   

    return true, "ok"
end

function _M:tl_ops_process_before_init_body(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_body(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_before_init_log(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_log(ctx)
    

    return true, "ok"
end


return _M
