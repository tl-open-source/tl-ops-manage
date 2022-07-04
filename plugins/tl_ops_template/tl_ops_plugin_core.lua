-- tl_ops_plugin_template
-- en : template  
-- zn : 插件示例
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_template");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end

local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }


function _M:new(options)
    local plugin = {}
    return setmetatable(plugin, mt)
end


-- init_worker阶段执行plugin
function _M:tl_ops_process_init_worker()

    tlog:dbg("template plugin tl_ops_process_init_worker")


    return true, "ok"
end

-- rewrite阶段执行plugin
function _M:tl_ops_process_init_rewrite()

    tlog:dbg("template plugin tl_ops_process_init_rewrite")

    return true, "ok"
end

-- access阶段执行plugin
function _M:tl_ops_process_init_access()
    
    tlog:dbg("template plugin tl_ops_process_init_access")

    return true, "ok"
end

-- content阶段执行plugin
function _M:tl_ops_process_init_content()
    
    tlog:dbg("template plugin tl_ops_process_init_content")

    return true, "ok"
end

-- header阶段执行plugin
function _M:tl_ops_process_init_header()
   
    tlog:dbg("template plugin tl_ops_process_init_header")

    return true, "ok"
end

-- body阶段执行plugin
function _M:tl_ops_process_init_body()
    
    tlog:dbg("template plugin tl_ops_process_init_body")

    return true, "ok"
end

-- log阶段执行plugin
function _M:tl_ops_process_init_log()
    
    tlog:dbg("template plugin tl_ops_process_init_log")

    return true, "ok"
end


return _M
