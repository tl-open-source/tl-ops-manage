-- tl_ops_plugin
-- en : plugin 
-- zn : 插件模块
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_manage_env = require("tl_ops_manage_env");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin");
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


-- 插件加载器
local tl_ops_process_load_plugins = function()
    local plugin = new_tab(0, 50)

    local open = tl_ops_manage_env.plugin.open
    if not open then
        tlog:dbg("tl_ops_process_load_plugins close")
        return
    end

    local module = tl_ops_manage_env.plugin.module
    if not module then
        tlog:dbg("tl_ops_process_load_plugins no module")
        return
    end

    for i = 1, #module do
        local name = module[i]
        local plug = require("plugins.tl_ops_" .. name .. ".tl_ops_plugin_core")
        table.insert(plugin, {
            name = name,
            func = plug
        })
    end

    tlog:dbg("tl_ops_process_load_plugins , module=",module,",plugin=",plugin)

    return plugin
end


-- init_worker阶段执行
function _M:tl_ops_process_init_worker()
    local lock_key = "tl_ops_plugin_process_worker_lock"
    local lock_time = 5
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_worker()
            if not ok then
                tlog:dbg("tl_ops_process_init_worker process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_worker process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_worker not func err , name=",plugin.name, ", ",_)
        end
    end
end


-- rewrite阶段执行
function _M:tl_ops_process_init_rewrite()

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_rewrite()
            if not ok then
                tlog:dbg("tl_ops_process_init_rewrite process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_rewrite process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_rewrite not func err , name=",plugin.name, ", ",_)
        end
    end
end


-- access阶段执行
function _M:tl_ops_process_init_access()

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_access()
            if not ok then
                tlog:dbg("tl_ops_process_init_access process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_access process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_access not func err , name=",plugin.name, ", ",_)
        end
    end
end


-- content阶段执行
function _M:tl_ops_process_init_content()

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_content()
            if not ok then
                tlog:dbg("tl_ops_process_init_content process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_content process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_content not func err , name=",plugin.name, ", ",_)
        end
    end
end


-- header阶段执行
function _M:tl_ops_process_init_header()

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_header()
            if not ok then
                tlog:dbg("tl_ops_process_init_header process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_header process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_header not func err , name=",plugin.name, ", ",_)
        end
    end
end


-- body阶段执行
function _M:tl_ops_process_init_body()

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_body()
            if not ok then
                tlog:dbg("tl_ops_process_init_body process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_body process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_body not func err , name=",plugin.name, ", ",_)
        end
    end
end


-- log阶段执行
function _M:tl_ops_process_init_log()

    local plugins = tl_ops_process_load_plugins()

    for i = 1, #plugins do
        local plugin = plugins[i]
        if type(plugin.func) == 'table' then
            local ok, _ = plugin.func:new():tl_ops_process_init_log()
            if not ok then
                tlog:dbg("tl_ops_process_init_log process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_log process ok , name=",plugin.name, ", ",_)
            end
        else
            tlog:dbg("tl_ops_process_init_log not func err , name=",plugin.name, ", ",_)
        end
    end
end


return _M
