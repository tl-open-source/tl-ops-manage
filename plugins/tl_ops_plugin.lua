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


-- 插件数据加载器
local tl_ops_process_load_plugins_constant = function(name)

    local status, constant = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_constant")
    if status then
        if plugin and type(constant) == 'table' then
            return constant
        else
            tlog:dbg("tl_ops_process_load_plugins_constant constant err, name=",name,",constant=",constant)
        end
    else 
        tlog:dbg("tl_ops_process_load_plugins_constant status err, name=",name,",status=",status)
    end

    return nil
end


-- 插件启动加载器
local tl_ops_process_load_plugins_func = function(name)

    local status, func = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_core")
    if status then
        if func and type(func) == 'table' then
            if type(func.new) == 'function' then
                return func
            else
                tlog:dbg("tl_ops_process_load_plugins_func func no new func err, name=",name,",func=",func)
            end
        else
            tlog:dbg("tl_ops_process_load_plugins_func func err, name=",name,",func=",func)
        end
    else 
        tlog:dbg("tl_ops_process_load_plugins_func status err, name=",name,",status=",status)
    end

    return nil
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

        -- 先load数据
        local constant = tl_ops_process_load_plugins_constant(name)
        
        -- 在load启动器
        local func = tl_ops_process_load_plugins_func(name)

        table.insert(self.plugins, {
            name = name,
            func = func:new(),
            constant = constant
        })
    end

    tlog:dbg("tl_ops_process_load_plugins , module=",module,",plugin=",self.plugins)
end


-- init_worker前置阶段执行
function _M:tl_ops_process_before_init_worker(ctx)
    local lock_key = "tl_ops_plugin_process_before_worker_lock"
    local lock_time = 5
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_worker) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_worker(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_worker process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_worker process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end

-- init_worker后置阶段执行
function _M:tl_ops_process_after_init_worker(ctx)
    local lock_key = "tl_ops_plugin_process_after_worker_lock"
    local lock_time = 5
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_worker) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_worker(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_worker process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_worker process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- ssl前置阶段执行
function _M:tl_ops_process_before_init_ssl(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_ssl) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_ssl(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_ssl process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_ssl process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end

-- ssl后置阶段执行
function _M:tl_ops_process_after_init_ssl(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_ssl) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_ssl(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_ssl process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_ssl process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- rewrite前置阶段执行
function _M:tl_ops_process_before_init_rewrite(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_rewrite) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_rewrite(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_rewrite process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_rewrite process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- rewrite后置阶段执行
function _M:tl_ops_process_after_init_rewrite(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_rewrite) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_rewrite(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_rewrite process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_rewrite process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- access前置阶段执行
function _M:tl_ops_process_before_init_access(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_access) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_access(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_access process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_access process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- access后置阶段执行
function _M:tl_ops_process_after_init_access(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_access) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_access(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_access process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_access process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- content前置阶段执行
function _M:tl_ops_process_before_init_content(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_content) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_content(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_content process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_content process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- content后置阶段执行
function _M:tl_ops_process_after_init_content(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_content) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_content(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_content process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_content process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- header前置阶段执行
function _M:tl_ops_process_before_init_header(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_header) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_header(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_header process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_header process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- header后置阶段执行
function _M:tl_ops_process_after_init_header(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_header) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_header(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_header process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_header process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- body前置阶段执行
function _M:tl_ops_process_before_init_body(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_body) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_body(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_body process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_body process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- body后置阶段执行
function _M:tl_ops_process_after_init_body(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_body) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_body(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_body process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_body process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- log前置阶段执行
function _M:tl_ops_process_before_init_log(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_before_init_log) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_before_init_log(ctx)
            if not ok then
                tlog:err("tl_ops_process_before_init_log process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_before_init_log process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end


-- log后置阶段执行
function _M:tl_ops_process_after_init_log(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_after_init_log) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_after_init_log(ctx)
            if not ok then
                tlog:err("tl_ops_process_after_init_log process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_after_init_log process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end

return _M
