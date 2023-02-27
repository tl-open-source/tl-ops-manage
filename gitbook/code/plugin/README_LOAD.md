# 插件加载器

前面说到了在init阶段会加载所有插件，并将插件都缓存在一个全局变量 `tlops` 中，我们看回插件加载器 `tl_ops_process_load_plugins`，其核心逻辑是通过 cache.get101("tl_ops_plugins_list") 获取到的配置的插件名称进行以此 require，并放入table的过程。

流程比较简单，代码如下。

```lua
# 代码位置 : plugins/tl_ops_plugin.lua


-- 插件加载器
function _M:tl_ops_process_load_plugins()
    local module_str, _ = cache_plugins_manage:get101(constant_plugins_manage.cache_key.list);
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

```

### 备注

可能大家会对get101有点疑惑，这里我解释一下，plugin的加载我放在 `tl_ops_process_init` 阶段，在这个阶段，部分内置api和函数调用是不可用的，因此为了避免这种问题，plugin的加载默认从 store 文件中取值，就不走自定义数据源了