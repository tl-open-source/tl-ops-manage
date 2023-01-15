-- tl_ops_plugin_template
-- en : template  
-- zn : 插件示例
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_template");
local uitls                     = tlops.utils
local sync                      = require("plugins.tl_ops_template.sync");


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

function _M:tl_ops_process_before_init_rewrite(ctx)


    return true, "ok"
end

function _M:tl_ops_process_after_init_rewrite(ctx)


    return true, "ok"
end

function _M:tl_ops_process_before_init_access(ctx)
    

    return true, "ok"
end

function _M:tl_ops_process_after_init_access(ctx)
    

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

-- 插件数据同步
function _M:sync_data()
    return sync.sync_data()
end


-- 插件数据字段同步
function _M:sync_fields()
    return sync.sync_fields()
end


return _M
