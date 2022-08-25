# 插件加载器

前面说到了在init阶段会加载所有插件，并将插件都缓存在一个全局变量 `tlops` 中，我们看回插件加载器 `tl_ops_process_load_plugins`，其核心逻辑是通过 `tl_ops_manage_env.lua`中配置的插件名称进行以此 require，并放入table的过程。

流程比较简单，代码如下。

```lua
# 代码位置 : plugins/tl_ops_plugin.lua


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

```