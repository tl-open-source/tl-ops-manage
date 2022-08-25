
# 任务配置

在tl-ops-manage中。动态配置是一大特性，支持动态更新定时任务中的配置，无需重启nginx或定时任务即可修改规则策略等， 如 “健康检查配置”，“熔断限流配置”，“服务节点配置” 这些需要依赖定时任务的都属于定时任务配置。

	依靠shared共享内存实现，多个worker中依赖一个公共的配置版本号，若有某个worker检测到配置的新增或变动，自增版本号，其他worker执行定时任务前，与共享版本号对比自身配置版本号，若存在新增或变动，同步最新配置到worker内即可


### 例子

以健康检查配置同步为例，我们可以看到代码如下，该文件提供两个接口， `tl_ops_health_check_version_incr_service_version`，`tl_ops_health_check_version_incr_service_option_version`，一个用于控制服务节点的配置数据版本号，一个用于控制服务配置数据版本号。

`服务节点配置数据版本号` ：例如，某服务下新增一个节点，那么此节点应该被自检定时器所识别，并加入自检列表中，这样才能达到动态节点注册的效果。

`服务配置数据版本号` ： 例如，健康检查配置的某一项变动，如，心跳包状态码新增 `203` 也为成功，那么这个改动应该同步到自检中的定时器中，以达到动态修改的目的。

`健康检查周期时间` ： 例如，在某些情况下，需要调整健康检查的定时器周期时间，在调整后动态变更定时器的运行时间间隔。


```lua
# 代码位置 : health/tl_ops_health_check_version.lua

-- 更新当前service的状态版本，用于通知其他worker进程同步最新conf
local tl_ops_health_check_version_incr_service_version = function( service_name )
    if not service_name then
        tlog:err(" service_name nil ")
        return
    end
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, service_name)
    local service_version, _ = cache_dict:get(key)

    if not service_version then
        service_version, _ = cache_dict:add(key, 1);
        if not service_version then 
            tlog:err(" failed to publish new service_version:" , _)
        end
    else 
        service_version, _ = cache_dict:incr(key, 1);
        if not service_version then 
            tlog:err(" failed to publish new service_version:" , _)
        end
    end

    return service_version
end


-- 对service_options_version更新，通知timer检查是否有新增service
local tl_ops_health_check_version_incr_service_option_version = function(  )
    local res, _ = cache_dict:set(tl_ops_constant_health.cache_key.service_options_version, true)

    if not res then
        tlog:err(" set service_options_version err " , _)
    end
end
```


目前支持的配置同步为两种，`增量配置同步`，`修改配置同步`。即将支持 `删除配置同步`。对于增量配置同步和修改配置同步所用的定时器逻辑是不同的。因为增量配置同步需要启动新的定时器，而修改配置是在定时器的基础上去同步配置即可，无需新增定时器。

## 增量配置同步

```lua
代码位置 : health/tl_ops_health_check_dynamic_conf.lua

- 获取当前健康检查的所有service，并对新增的service启动定时器
local tl_ops_health_check_dynamic_conf_add_core = function(options, services)

	-- 暂时还有service的option未同步对应的，先不执行，等到option准备完毕再执行后续逻辑
	local all_service_option_asynced = tl_ops_health_check_dynamic_conf_all_service_option_asynced(options, services)
	if not all_service_option_asynced then
		return
	end

	-- 查看现在已有的service timer，如果没有，说明首次启动，为所有service启动timer
	local timers_str = shared:get(tl_ops_constant_health.cache_key.timers)
	if not timers_str then

		require("health.tl_ops_health_check"):new(options, services):tl_ops_health_check_start();
		shared:set(tl_ops_constant_health.cache_key.service_options_version, nil)
		return
	end

	-- 如果有，查看cache service中的所有服务是否都已启动timer，如果没有, 补充启动相应service timer
	local timers_list = cjson.decode(timers_str)
	for service_name, nodes in pairs(services) do
		local service_name_exist = false
		for i = 1, #timers_list do
			if service_name == timers_list[i] then
				service_name_exist = true;
			end
		end
		if service_name_exist == true then
			tlog:dbg("[add-check] timer exist , service_name=",service_name)
		else
			local matcher_options = tl_ops_health_check_dynamic_conf_get_option( options, service_name)

			require("health.tl_ops_health_check"):new(matcher_options, services):tl_ops_health_check_start();
			shared:set(tl_ops_constant_health.cache_key.service_options_version, nil)
		end
	end
end

-- 同步新增的service option
local tl_ops_health_check_dynamic_conf_add_check = function()

	local version, _ = shared:get(tl_ops_constant_health.cache_key.service_options_version)
	if not version then
		return
	end

	local options_str, _ = cache_health:get(tl_ops_constant_health.cache_key.options_list)
	if not options_str then
		tlog:dbg("[add-check] load dynamic options failed , options_str=",options_str)
		return
	end
	local dynamic_options = cjson.decode(options_str)

	local cache_service = require("cache.tl_ops_cache_core"):new("tl-ops-service");
	local service_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list)
	if not service_str then
		tlog:dbg("[add-check] load dynamic service failed , service_str=",service_str)
		return
	end
	local dynamic_service = cjson.decode(service_str)

	if dynamic_options and dynamic_service then
		tl_ops_health_check_dynamic_conf_add_core(dynamic_options, dynamic_service)
		tlog:dbg("[add-check] async dynamic conf done")
	end
end
```

## 修改配置同步

```lua
代码位置 : health/tl_ops_health_check_dynamic_conf.lua

-- 同步变更的service信息
local tl_ops_health_check_dynamic_conf_change_core = function( conf, service_version )

	-- 保证更新顺序，service/options > service.nodes > node.state 
    tl_ops_health_check_dynamic_conf_change_service_options_async(conf)
    tl_ops_health_check_dynamic_conf_change_service_node_async(conf)
    tl_ops_health_check_dynamic_conf_change_state_async(conf)
	conf.service_version = service_version

end

-- 校验是否需要同步conf变更
local tl_ops_health_check_dynamic_conf_change_check = function( conf )
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, conf.check_service_name)
	local service_version, _ = shared:get(key)

	if not service_version then
		local ok ,_ = shared:add(key, 1)
		if not ok then
			tlog:err("[change-check] failed to init service_version key, " , _)
		end
		return
	end

	if service_version > conf.service_version then

		tl_ops_health_check_dynamic_conf_change_core( conf, service_version )
    end
end

```
