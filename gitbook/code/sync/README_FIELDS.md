# 字段同步器

对于字段同步器的实现，我将字段同步器做成配置形式，通过配置不同模块名称，来达到自定义同步部分模块的字段的目的

### 执行时机

字段同步器在整个nginx生命周期中，只会执行一次，也就是在 `init_worker` 阶段执行，在此阶段会读取配置的模块的中的静态数据文件，也就是 `tl_ops_constant_xxx.lua` 文件中的demo字段，将demo字段与各模块的store文件的最新配置进行对比，对增量字段进行补充到store文件中

注意 : 由于是需要依赖各模块的demo字段来做判断依据，所以demo字段对于同步插件来说必不可少。


### 实现代码


```lua
# 代码位置 : plugins/tl_ops_sync/sync_fields.lua


-- 服务节点数据同步
local sync_fields_service = function ()

    local cache_key = constant_service.cache_key.service_list
    local cache_rule_key = constant_service.cache_key.service_rule
    local demo = constant_service.demo

    local data_str, _ = cache_service:get(cache_key);
    if not data_str then
        local res, _ = cache_service:set(cache_key, cjson.encode(constant_service.list))
        if not res then
            tlog:err("sync_fields_service new store list err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_service:get(cache_key);
    end

    local data_rule_str, _ = cache_service:get(cache_rule_key);
    if not data_rule_str then
        local res, _ = cache_service:set(cache_rule_key, constant_service.rule.auto_load)
        if not res then
            tlog:err("sync_fields_service new store rule err, res=",res)
            return tl_ops_rt.error
        end
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_service err, old=",data)
        return tl_ops_rt.error
    end

    local add_keys = {}

    for service , _ in pairs(data) do
        local nodes = data[service]
        if nodes then
            -- demo fileds check
            for key , _ in pairs(demo) do
                -- data fileds check
                for i = 1, #nodes do
                    -- add keys
                    if nodes[i][key] == nil then
                        nodes[i][key] = demo[key]
                        table.insert(add_keys , key)
                    end
                end
            end
        end
    end

    local res = cache_service:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_service err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    return tl_ops_rt.ok
end

-- 同步字段主逻辑
function _M:sync_fields_module( module )

    if module == 'service' then
        return sync_fields_service()
    elseif module == 'health' then
        return sync_fields_health()
    elseif module == 'limit' then
        sync_fields_limit_token()
        sync_fields_limit_leak()
        return sync_fields_limit()
    elseif module == 'balance' then
        return sync_fields_balance()
    elseif module == 'balance_api' then
        return sync_fields_balance_api()
    elseif module == 'balance_cookie' then
        return sync_fields_balance_cookie()
    elseif module == 'balance_header' then
        return sync_fields_balance_header()
    elseif module == 'balance_param' then
        return sync_fields_balance_param()
    elseif module == 'waf' then
        return sync_fields_waf()
    elseif module == 'waf_api' then
        return sync_fields_waf_api()
    elseif module == 'waf_ip' then
        return sync_fields_waf_ip()
    elseif module == 'waf_header' then
        return sync_fields_waf_header()
    elseif module == 'waf_cookie' then
        return sync_fields_waf_cookie()
    elseif module == 'waf_param' then
        return sync_fields_waf_param()
    elseif module == 'waf_cc' then
        return sync_fields_waf_cc()
    else 
        -- plugin
        return sync_fields_plugin(module)
    end
end
```


### 支持插件

考虑到插件也会存在静态数据的变化，同步器插件提供了外部接口来支持其他插件的字段同步， `sync_fields`，同步器插件不负责插件的字段同步，只负责外部接口的调用，所以各个插件的字段同步需要自行实现 `sync_fields` 逻辑代码。


```lua
# 代码位置 : plugins/tl_ops_sync/sync_fields.lua

-- 获取某个插件
local sync_fields_get_plugin = function(name)
    for i = 1, #tlops.plugins do
        local plugin = tlops.plugins[i]
        if plugin.name == name then
            return plugin
        end
    end
    return nil
end
-- 插件静态配置数据
local sync_fields_plugin = function (module)
    local plugin = sync_fields_get_plugin(module)
    if not plugin then
        tlog:err("sync_fields_plugin not plugin, module=",module)
        return tl_ops_rt.error
    end

    if type(plugin.func.sync_fields) == 'function' then
        local ok, _ = plugin.func:sync_fields()
        if not ok then
            tlog:err("sync_fields_plugin sync_fields err, module=",module,",err=",_)
            return tl_ops_rt.error
        end
    end

    tlog:dbg("sync_fields_plugin done, module=",module)

    return tl_ops_rt.ok
end
```

