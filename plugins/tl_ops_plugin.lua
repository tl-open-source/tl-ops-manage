-- tl_ops_plugin
-- en : plugin 
-- zn : 插件模块
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_plugin")
local require           = require
local tl_ops_manage_env = require("tl_ops_manage_env")
local tl_ops_utils_func = require("utils.tl_ops_utils_func")


local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }


function _M:new()
    local plugins = tl_ops_utils_func:new_tab(0, 50)
    return setmetatable({plugins = plugins}, mt)
end


-- 获取所有插件
function _M:tl_ops_process_get_plugins()
    return self.plugins
end

-- 插件加载器
function _M:tl_ops_process_load_plugins()
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
        local status, plugin = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_core")
        if status then
            if plugin and type(plugin) == 'table' then
                if type(plugin.new) == 'function' then
                    table.insert(self.plugins, {
                        name = name,
                        func = plugin:new()
                    })
                else
                    tlog:dbg("tl_ops_process_load_plugins plugin no new func err, name=",name,",plugin=",plugin)
                end
            else
                tlog:dbg("tl_ops_process_load_plugins plugin err, name=",name,",plugin=",plugin)
            end
        else 
            tlog:dbg("tl_ops_process_load_plugins status err, name=",name,",status=",status)
        end
    end

    tlog:dbg("tl_ops_process_load_plugins , module=",module,",plugin=",self.plugins)
end


-- init_worker阶段执行
function _M:tl_ops_process_init_worker()
    local lock_key = "tl_ops_plugin_process_worker_lock"
    local lock_time = 5
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_worker) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_worker()
            if not ok then
                tlog:err("tl_ops_process_init_worker process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_worker process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- rewrite阶段执行
function _M:tl_ops_process_init_rewrite()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_rewrite) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_rewrite()
            if not ok then
                tlog:err("tl_ops_process_init_rewrite process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_rewrite process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- access阶段执行
function _M:tl_ops_process_init_access()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_access) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_access()
            if not ok then
                tlog:err("tl_ops_process_init_access process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_access process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- content阶段执行
function _M:tl_ops_process_init_content()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_content) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_content()
            if not ok then
                tlog:err("tl_ops_process_init_content process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_content process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- header阶段执行
function _M:tl_ops_process_init_header()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_header) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_header()
            if not ok then
                tlog:err("tl_ops_process_init_header process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_header process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- body阶段执行
function _M:tl_ops_process_init_body()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_body) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_body()
            if not ok then
                tlog:err("tl_ops_process_init_body process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_body process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- log阶段执行
function _M:tl_ops_process_init_log()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_log) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_log()
            if not ok then
                tlog:err("tl_ops_process_init_log process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_log process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


return _M
