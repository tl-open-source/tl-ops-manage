-- tl_ops_plugin_load
-- en : plugin load
-- zn : 插件加载模块
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_load")
local require                   = require
local tl_ops_utils_func         = require("utils.tl_ops_utils_func")


local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }


function _M:new()
    local plugins = tl_ops_utils_func:new_tab(0, 50)
    return setmetatable({plugins = plugins}, mt)
end


-- 插件api加载器
local tl_ops_plugin_load_api_func = function(name)

    local status, func = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_api")
    if status then
        if func and type(func) == 'function' then
            return func
        else
            tlog:dbg("tl_ops_plugin_load_api_func func err, name=",name,",func=",func)
        end
    else 
        tlog:dbg("tl_ops_plugin_load_api_func status err, name=",name,",status=",status,",err=",func)
    end

    return nil
end


-- 插件数据加载器
local tl_ops_plugin_load_constant = function(name)

    local status, constant = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_constant")
    if status then
        if constant and type(constant) == 'table' then
            return constant
        else
            tlog:dbg("tl_ops_plugin_load_constant constant err, name=",name,",constant=",constant)
        end
    else 
        tlog:dbg("tl_ops_plugin_load_constant status err, name=",name,",status=",status,",err=",constant)
    end

    return nil
end


-- 插件启动加载器
local tl_ops_plugin_load_func = function(name)

    local status, func = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_core")
    if status then
        if func and type(func) == 'table' then
            if type(func.new) == 'function' then
                return func
            else
                tlog:dbg("tl_ops_plugin_load_func func no new func err, name=",name,",func=",func)
            end
        else
            tlog:dbg("tl_ops_plugin_load_func func err, name=",name,",func=",func)
        end
    else 
        tlog:dbg("tl_ops_plugin_load_func status err, name=",name,",status=",status,",err=",func)
    end

    return nil
end


-- 插件开关获取器
local tl_ops_plugin_load_open_func = function(name)

    local status, func = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_open")
    if status then
        if func and type(func) == 'function' then
            return func
        else
            tlog:dbg("tl_ops_plugin_load_open_func func err, name=",name,",func=",func)
        end
    else 
        tlog:dbg("tl_ops_plugin_load_open_func status err, name=",name,",status=",status,",err=",func)
    end

    return nil
end


-- 插件加载器
function _M:tl_ops_plugin_load_by_name( name )

    -- 先load数据
    local constant = tl_ops_plugin_load_constant(name)

    -- 在load启动器
    local func = tl_ops_plugin_load_func(name)

    -- 是否启动
    local open_func = tl_ops_plugin_load_open_func(name)

    -- 对外接口
    local api_func = tl_ops_plugin_load_api_func(name)

    return {
        name = name,
        func = func:new(),
        constant = constant,
        open_func = open_func,
        api_func = api_func,
    }
end


-- 插件卸载器
function _M:tl_ops_plugin_unload_by_name( plugins, name )

    local remove_index = 0;

    for index, plugin in ipairs(plugins) do
        if name == plugin.name then
            remove_index = index;
            break;
        end
    end

    table.remove(plugins, remove_index)

    return plugins
end


return _M