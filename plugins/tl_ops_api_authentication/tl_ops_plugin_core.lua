-- tl_ops_api_authentication
-- en : api_authentication  
-- zn : 管理台权限身份认证插件
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_api_authentication");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end


local _M = {}

_M._VERSION = '0.01'
_M.plugin = new_tab(0, 50)


local mt = { __index = _M }


function _M:new()	
    return setmetatable({}, mt)
end


-- init_worker阶段执行plugin
function _M:tl_ops_process_init_worker()

    tlog:dbg("api_authentication plugin tl_ops_process_init_worker")


    return true, "ok"
end

-- rewrite阶段执行plugin
function _M:tl_ops_process_init_rewrite()

    tlog:dbg("api_authentication plugin tl_ops_process_init_rewrite")

    return true, "ok"
end

-- access阶段执行plugin
function _M:tl_ops_process_init_access()
    
    tlog:dbg("api_authentication plugin tl_ops_process_init_access")

    return true, "ok"
end

-- content阶段执行plugin
function _M:tl_ops_process_init_content()
    
    tlog:dbg("api_authentication plugin tl_ops_process_init_content")

    return true, "ok"
end

-- header阶段执行plugin
function _M:tl_ops_process_init_header()
   
    tlog:dbg("api_authentication plugin tl_ops_process_init_header")

    return true, "ok"
end

-- body阶段执行plugin
function _M:tl_ops_process_init_body()
    
    tlog:dbg("api_authentication plugin tl_ops_process_init_body")

    return true, "ok"
end

-- log阶段执行plugin
function _M:tl_ops_process_init_log()
    
    tlog:dbg("api_authentication plugin tl_ops_process_init_log")

    return true, "ok"
end


return _M
