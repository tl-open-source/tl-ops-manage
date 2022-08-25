
# 健康检查

健康检查的主要逻辑是 `定时检查器` 的实现。

定时检查器根据配置启动相应定时器执行检查逻辑。配置加载器根据管理端新增或修改的配置动态同步到定时检查器中。实现方式都是通过`ngx.timer`

首先，我们先了解下健康检查对应的配置，还是以product服务为例

```lua
{---- product服务自检配置
	check_failed_max_count = 5,         #自检时心跳包最大失败次数，达到这个次数会将在线节点置为下线。
	check_success_max_count = 2,        #自检时心跳包最大成功次数，达到这个次数会将下线节点置为上线。
	check_interval = 5 * 1000,          #自检周期， 默认单位/ms
	check_timeout = 1000,               #自检心跳包接收超时时间，默认单位/ms
	check_content = "GET / HTTP/1.0",   #自检心跳包内容，可自定义，但是需要被检方处理兼容。
	check_service_name = "product"      #自检服务名称
}
```

在项目启动时，会首先执行到 `conf/tl_ops_manage.conf` 中的 `init_worker_by_lua_block`逻辑，启动相应的定时任务

```lua
# 代码位置 : conf/tl_ops_manage.conf

init_worker_by_lua_block {
	tlops:tl_ops_process_init_worker();
}

# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init_worker()
	...

    -- 启动健康检查
	m_health:init();

	...
end
```

进入 `require("health.tl_ops_health"):init();` 方法后，我们可以看到一系列的启动器，如根据配置启动相应的health-check-timer, 还有配置加载器的启动，以及服务的版本初始化，以及服务健康检查配置版本的初始化


```lua
# 代码位置 : health/tl_ops_health.lua

function _M:init(  )

    --动态加载新增配置
    tl_ops_health_check_dynamic_conf.dynamic_conf_add_start()

    --默认初始化一次version
    for i = 1, #tl_ops_constant_health.options do
        local option = tl_ops_constant_health.options[i]
        local service_name = option.check_service_name
        if service_name then
            tl_ops_health_check_version.incr_service_version(service_name)
        end
    end

	tl_ops_health_check_version.incr_service_option_version()

end

```

我们先从健康检查主逻辑开始，可以看到先执行了一段配置初始化逻辑 `tl_ops_health_check_default_confs`, 初始化配置中，会检查配置的合法性，以及对服务状态，节点状态的初始值进行定义。

紧接着可以看到根据confs的数量，用ngx.timer.at去启动相应的定时器去执行 `tl_ops_health_check` 逻辑，而 `tl_ops_health_check` 也就是执行相应的 `tl_ops_health_check_main`逻辑，  `conf` 就是每个定时器所需的健康检查配置

```lua
# 代码位置 : health/tl_ops_health_check.lua

-- 创建健康检查启动器
function _M:tl_ops_health_check_start()
	if not self.options or not self.services then
		tlog:err("tl_ops_health_check_start no default args ")
		return nil
	end

	local confs, _ = tl_ops_health_check_default_confs(self.options, self.services)
	if not confs then
		tlog:err("tl_ops_health_check_start failed to start , confs nil ", _)
		return nil
	end

	...

	for index, conf in ipairs(confs) do
		local ok, _ = ngx.timer.at(0, tl_ops_health_check, conf)
		if not ok then
			tlog:err("tl_ops_health_check_start failed to run check , create timer failed " , _)
			return nil
		end
		...
	end

	...

	tlog:dbg("tl_ops_health_check_start check end , timer_list=",timer_list)

	return true
end
```

接下来进入核心逻辑`tl_ops_health_check`，`tl_ops_health_check` 对应的核心逻辑是 `tl_ops_health_check_main`， 可以看到`tl_ops_health_check_main`逻辑主要由两部分组成，也就是 `dynamic_conf_change_start`（同步配置），`tl_ops_health_check_nodes`（心跳包），接下来将对这两个方法进行详细解析，同步配置逻辑已整合到 “动态配置” 文档中


```lua
# 代码位置 : health/tl_ops_health_check.lua

-- 健康检查主逻辑
tl_ops_health_check_main = function (conf)
	tlog:dbg("tl_ops_health_check_main start")

	--同步配置
	tl_ops_health_check_dynamic_conf.dynamic_conf_change_start( conf )

	-- 心跳包
	if tl_ops_health_check_get_lock(conf) then

		-- 是否主动关闭自检
		local uncheck_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.uncheck, conf.check_service_name)
		local uncheck, _ = shared:get(uncheck_key)
		if uncheck and uncheck == true then
			tlog:dbg("tl_ops_health_check_main is uncheck check_service_name=",conf.check_service_name)
			return
		end

		tl_ops_health_check_nodes(conf)
	end

	tlog:dbg("tl_ops_health_check_main end")
end
```

