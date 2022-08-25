# 静态数据同步/预热器

对于静态数据同步的实现，我将静态数据同步做成配置形式，通过配置不同模块名称，来达到自定义同步部分模块的静态数据的目的

### 执行时机

静态数据同步器在整个nginx生命周期中，只会执行一次，也就是在 `init_worker` 阶段执行，在此阶段会读取配置的模块的中的静态数据文件，也就是 `tl_ops_constant_xxx.lua` 文件中的静态配置字段，将静态配置字段与各模块的store文件的最新配置的id进行对比，对增量静态配置进行补充到store文件中

注意 : 由于是需要依赖各模块的静态配置的id来做判断依据，所以静态配置的id对于同步插件来说必不可少且必须唯一。


### 实现代码


```lua
# 代码位置 : plugins/tl_ops_sync/sync_data.lua


-- api策略静态配置数据
local sync_data_balance_api = function () 
    local cache_key_list = constant_balance_api.cache_key.list

    local data_str, _ = cache_balance_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_api:set(cache_key_list, cjson.encode(constant_balance.api.list))
        if not res then
            tlog:err("sync_data_balance_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_data_balance_api new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_data_balance_api err, old=",data)
        return tl_ops_rt.error
    end

    -- 静态配置
    local constant_data = constant_balance.api.list

    -- 获取需要同步的配置
    local add_point = sync_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = sync_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_data_balance_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_data_balance_api done, new=",data)

    return tl_ops_rt.ok
end


-- 同步静态数据主逻辑
function _M:sync_data_module( module )

    if module == 'balance_api' then
        return sync_data_balance_api()
    elseif module == 'balance_cookie' then
        return sync_data_balance_cookie()
    elseif module == 'balance_header' then
        return sync_data_balance_header()
    elseif module == 'balance_param' then
        return sync_data_balance_param()
    elseif module == 'waf_api' then
        return sync_data_waf_api()
    elseif module == 'waf_ip' then
        return sync_data_waf_ip()
    elseif module == 'waf_header' then
        return sync_data_waf_header()
    elseif module == 'waf_cookie' then
        return sync_data_waf_cookie()
    elseif module == 'waf_param' then
        return sync_data_waf_param()
    elseif module == 'waf_cc' then
        return sync_data_waf_cc()
    else 
        -- plugin
        return sync_data_plugin(module)
    end

end
```


### 支持插件

考虑到插件也会存在静态数据的变化，同步器插件提供了外部接口来支持其他插件的静态数据同步， `sync_data`，同步器插件不负责插件的静态数据同步，只负责外部接口的调用，所以各个插件的静态数据同步需要自行实现 `sync_data` 逻辑代码。


```lua
# 代码位置 : plugins/tl_ops_sync/sync_data.lua

-- 获取某个插件
local sync_data_get_plugin = function(name)
    for i = 1, #tlops.plugins do
        local plugin = tlops.plugins[i]
        if plugin.name == name then
            return plugin
        end
    end
    return nil
end
-- 插件静态配置数据
local sync_data_plugin = function (module)
    local plugin = sync_data_get_plugin(module)
    if not plugin then
        tlog:err("sync_data_plugin not plugin, module=",module)
        return tl_ops_rt.error
    end

    if type(plugin.func.sync_data) == 'function' then
        local ok, _ = plugin.func:sync_data()
        if not ok then
            tlog:err("sync_data_plugin sync_data err, module=",module,",err=",_)
            return tl_ops_rt.error
        end
    end

    tlog:dbg("sync_data_plugin done, module=",module)

    return tl_ops_rt.ok
end

```

