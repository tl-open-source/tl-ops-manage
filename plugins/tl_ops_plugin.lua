-- tl_ops_plugin
-- en : plugin 
-- zn : 插件模块
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_plugin")
local cache_plugins_manage      = require("cache.tl_ops_cache_core"):new("tl-ops-plugins-manage")
local constant_plugins_manage   = require("constant.tl_ops_constant_plugins_manage")
local require                   = require
local tl_ops_manage_env         = require("tl_ops_manage_env")
local tl_ops_utils_func         = require("utils.tl_ops_utils_func")
local cjson                     = require("cjson.safe");
local plugin_load               = require("plugins.tl_ops_plugin_load"):new();


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
    local module_str, _ = cache_plugins_manage:get(constant_plugins_manage.cache_key.list);
    if not module_str or module_str == nil then
        tlog:dbg("tl_ops_process_load_plugins no module, use constant default, default=",constant_plugins_manage.list)
        module_str = cjson.encode(constant_plugins_manage.list)
    end

    local module = cjson.decode(module_str)
    if not module or module == nil then
        tlog:err("tl_ops_process_load_plugins module decode err")
        return;
    end

    for i = 1, #module do
        local name = module[i].name

        local plugin_data = plugin_load:tl_ops_plugin_load_by_name(name)

        table.insert(self.plugins, plugin_data)
    end

    tlog:dbg("tl_ops_process_load_plugins , module=",module,",plugins=",self.plugins)
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
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_worker) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_worker(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_worker process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_worker process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_worker process not open , name=",plugin.name)
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
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_worker) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_worker(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_worker process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_worker process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_worker process not open , name=",plugin.name)
        end
    end
end


-- ssl前置阶段执行
function _M:tl_ops_process_before_init_ssl(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_ssl) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_ssl(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_ssl process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_ssl process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_ssl process not open , name=",plugin.name)
        end
    end
end

-- ssl后置阶段执行
function _M:tl_ops_process_after_init_ssl(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_ssl) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_ssl(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_ssl process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_ssl process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_ssl process not open , name=",plugin.name)
        end
    end
end


-- rewrite前置阶段执行
function _M:tl_ops_process_before_init_rewrite(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        
        -- 插件api加载执行
        if plugin.api_func then
            plugin.api_func(ctx)
        end

        if open then
            if type(plugin.func.tl_ops_process_before_init_rewrite) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_rewrite(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_rewrite process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_rewrite process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_rewrite process not open , name=",plugin.name)
        end
    end
end


-- rewrite后置阶段执行
function _M:tl_ops_process_after_init_rewrite(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_rewrite) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_rewrite(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_rewrite process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_rewrite process ok , name=",plugin.name, ", ",_)
                end
            end
        else
            tlog:dbg("tl_ops_process_after_init_rewrite process not open , name=",plugin.name)
        end
    end
end


-- access前置阶段执行
function _M:tl_ops_process_before_init_access(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_access) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_access(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_access process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_access process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_access process not open , name=",plugin.name)
        end
    end
end


-- access后置阶段执行
function _M:tl_ops_process_after_init_access(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_access) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_access(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_access process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_access process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_access process not open , name=",plugin.name)
        end
    end
end


-- balance前置阶段执行
function _M:tl_ops_process_before_init_balancer(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_balancer) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_balancer(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_balancer process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_balancer process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_balancer process not open , name=",plugin.name)
        end
    end
end


-- balance后置阶段执行
function _M:tl_ops_process_after_init_balancer(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_balancer) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_balancer(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_balancer process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_balancer process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_balancer process not open , name=",plugin.name)
        end
    end
end


-- header前置阶段执行
function _M:tl_ops_process_before_init_header(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_header) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_header(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_header process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_header process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_header process not open , name=",plugin.name)
        end
    end
end


-- header后置阶段执行
function _M:tl_ops_process_after_init_header(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_header) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_header(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_header process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_header process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_header process not open , name=",plugin.name)
        end
    end
end


-- body前置阶段执行
function _M:tl_ops_process_before_init_body(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_body) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_body(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_body process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_body process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_body process not open , name=",plugin.name)
        end
    end
end


-- body后置阶段执行
function _M:tl_ops_process_after_init_body(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_body) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_body(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_body process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_body process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_body process not open , name=",plugin.name)
        end
    end
end


-- log前置阶段执行
function _M:tl_ops_process_before_init_log(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_before_init_log) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_before_init_log(ctx)
                if not ok then
                    tlog:err("tl_ops_process_before_init_log process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_before_init_log process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_before_init_log process not open , name=",plugin.name)
        end
    end
end


-- log后置阶段执行
function _M:tl_ops_process_after_init_log(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        local open = plugin.open_func and plugin.open_func()
        if open then
            if type(plugin.func.tl_ops_process_after_init_log) == 'function' then
                local ok, _ = plugin.func:tl_ops_process_after_init_log(ctx)
                if not ok then
                    tlog:err("tl_ops_process_after_init_log process err , name=",plugin.name, ", ",_)
                else
                    tlog:dbg("tl_ops_process_after_init_log process ok , name=",plugin.name, ", ",_)
                end
            end
        else 
            tlog:dbg("tl_ops_process_after_init_log process not open , name=",plugin.name)
        end
    end
end

return _M
