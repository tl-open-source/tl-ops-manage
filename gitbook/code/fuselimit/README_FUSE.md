# 动态熔断策略

在进行熔断时，我们需要根据一个依据来判定当前节点/服务是否应该进行熔断降级，这个依据可以依赖于健康检查模块的自检结果，也可以依赖于负载均衡模块的负载比例，或其他自定义策略。

在tl-ops-manage中，我提供了两种熔断依赖策略，`实时健康检查节点状态`，`熔断周期内节点负载失败率`


## 实时健康检查节点状态

如果是依赖于实时健康状态策略，如果节点一直处于下线状态，那么熔断后的限流机制会呈献一个平滑缩容的状态。**因为节点在触发全熔断后，自动恢复策略不会干预健康检查的状态数据，周期结束后会将服务短暂升级，触发缩容。节点将会在全熔断后自我恢复到半熔断，随之反复**，也就是一个单位周期触发缩容一次。直到缩为单个单位大小。


## 熔断周期内节点负载失败率

如果是依赖于熔断周期内节点负载失败率，那么熔断后的限流机制会呈献一个平滑缩容的状态。**因为节点在触发全熔断后，自动恢复策略会干预清除周期内的有效路由数据。节点将会在全熔断后自我恢复到半熔断，随之反复**，也就是一个单位周期触发缩容一次。直到缩为单个单位大小。


# 自动化熔断

假设某个服务在内存溢出时，不断返回504（请求超时），那这个时候如果其他服务存在rpc一直调用此服务，会导致整个系统被拖垮。所以这个时候应该将此服务降级，让其处理更少的请求或不处理请求。

下面我们看回tl-ops-manage实现自动化熔断代码，依然还是用定时任务来实现，主入口如下

```lua
# 代码位置 : conf/tl_ops_manage.conf

init_worker_by_lua_block {
	tlops:tl_ops_process_init_worker();
}

# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init_worker()
	...

	-- 启动限流熔断
	m_limit_fuse:init();

	...
end
```

进入主入口后，我们可以看到代码和健康检查实现类似，都是启动相应定时器，以及服务配置版本初始化，配置版本号的初始化主要是用于加载最新配置到定时任务中。也用于动态同步配置到worker中

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse.lua

function _M:init(  )
    -- 给定配置启动限流熔断检查，支持动态加载已有服务变更配置
    local limit_fuse = tl_ops_limit_fuse_check:new( 
        tl_ops_constant_limit.fuse.options,  tl_ops_constant_limit.fuse.service
    );
    limit_fuse:tl_ops_limit_fuse_start();

    -- 启动动态新增配置检测
    tl_ops_limit_fuse_check_dynamic_conf.dynamic_conf_add_start()

    -- 默认初始化一次version, 启动时读取最新数据
    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    -- 启动动态检测配置版本
    tl_ops_limit_fuse_check_version.incr_service_option_version()
end
```

接着我们看回主逻辑 `tl_ops_limit_fuse_start`，这里的主逻辑前部分和健康检查类似，这里直接讲解定时器中的核心逻辑 `tl_ops_limit_fuse_main`，可以看到在锁内执行了两段逻辑，除了对服务进行降级升级操作外，多了一个自动恢复逻辑块 `tl_ops_limit_fuse_auto_recover`，也就是靠这个逻辑来做到自动化熔断恢复的。


```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_check.lua

tl_ops_limit_fuse_main = function( conf )
	--同步配置
	tl_ops_limit_fuse_check_dynamic_conf.dynamic_conf_change_start( conf )

	-- 自动熔断/恢复
	if tl_ops_limit_fuse_get_lock( conf ) then
		tl_ops_limit_fuse_auto_recover( conf )
		tl_ops_limit_fuse_check_nodes( conf )
	end
end
```

我们先看主要的自检逻辑`tl_ops_limit_fuse_check_nodes`，和健康检查自检不同，对于熔断的自检我默认用的是`熔断周期内节点负载失败率`来衡量节点处于何种状态。

## 节点熔断

我们可以看到在自检时，是轮询所有节点，获取每个节点的成功负载次数，负载失败次数，并根据得出的失败率和用户设定的节点失败率作对比，如果超过这个阈值，进行节点降级
，代码里面写的是状态升级，也就是从 0 [正常节点] -> 1 [节点半熔断] -> 2 [节点全熔断]。


```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_check.lua

tl_ops_limit_fuse_check_nodes = function ( conf )

	...

	-- node层级
	for i = 1, #nodes do
		local node_id = i-1
		local upgrade = false

		-- 路由失败率策略
		if mode == tl_ops_constant_limit.mode.balance_fail then
			local success_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, service_name, node_id)
			local success_count = shared:get(success_count_key)
			if not success_count then
				success_count = 0
			end
	
			local failed_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail, service_name, node_id)
			local failed_count = shared:get(failed_count_key)
			if not failed_count then
				failed_count = 0
			end

			local total_count = success_count + failed_count
			if total_count == 0 then
				total_count = -1 	-- can not be 0
			end

			-- 超过阈值
			if failed_count / total_count >= node_threshold then
				upgrade = true
			end
		end

		-- 健康状态策略
		if mode == tl_ops_constant_limit.mode.health_state then
			local health_state_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, service_name, node_id)
			local health_state = shared:get(health_state_key)

			-- 节点下线
			if not health_state then
				upgrade = true
			end
		end
		
		if upgrade then
			upgrade_count = upgrade_count + 1
			tl_ops_limit_fuse_node_upgrade( conf, node_id )
		else
			degrade_count = degrade_count + 1
			tl_ops_limit_fuse_node_degrade( conf, node_id )
		end
	end

	...

	tlog:dbg("tl_ops_limit_fuse_check_nodes done")
end
```

## 服务熔断

在轮询完所有节点后，得出每个节点的状态，如果降级节点超过设定的服务阈值，那么进行服务降级
，代码里面写的是状态升级，也就是从 0 [正常服务] -> 1 [服务半熔断] -> 2 [服务全熔断]。


```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_check.lua

tl_ops_limit_fuse_check_nodes = function ( conf )

	...

	-- service层级
	local service_total_count = upgrade_count + degrade_count
	if service_total_count == 0 then
		service_total_count = -1 	-- can not be 0
	end
	-- 节点状态升级比率超过阈值，对服务进行状态升级
	if upgrade_count / service_total_count >= service_threshold then

		tl_ops_limit_fuse_service_upgrade( conf )
	else

		tl_ops_limit_fuse_service_degrade( conf )
	end

	tlog:dbg("tl_ops_limit_fuse_check_nodes done")
end
```

# 自动化恢复

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse.lua

-- 全熔断自动恢复
tl_ops_limit_fuse_auto_recover = function( conf )
	local nodes = conf.nodes
	local service_state = conf.state
	local mode = conf.mode
	local service_name = conf.service_name

	-- 服务熔断自动恢复
	if service_state == _STATE.LIMIT_FUSE_OPEN then
		tl_ops_limit_fuse_service_degrade( conf )
		tlog:dbg("tl_ops_limit_fuse_auto_recover service done : service=", service_name, ",state=",service_state)
	end

	if nodes == nil then
		tlog:err("tl_ops_limit_fuse_auto_recover nodes nil")
		return
	end

	-- 节点熔断自动恢复
	for i = 1, #nodes do
		local node_id = i-1
		local node_state = nodes[i].state
		if node_state == _STATE.LIMIT_FUSE_OPEN then
			
			-- 路由失败率熔断模式下 : 单个周期内请求次数统计，周期结束清除全熔断的统计值
			if mode == tl_ops_constant_limit.mode.balance_fail then
				local success_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, service_name, node_id)
				shared:set(success_count_key, 0)

				local failed_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail, service_name, node_id)
				shared:set(failed_count_key, 0)

				tlog:dbg("tl_ops_limit_fuse_auto_recover reset count done service_name=",service_name,",node_id=",node_id)
			end

			-- 健康状态模式下 : 自动状态降级
			if mode == tl_ops_constant_limit.mode.health_state then
				tl_ops_limit_fuse_node_degrade( conf , node_id )
			end
		end

		tlog:dbg("tl_ops_limit_fuse_auto_recover node done : node=", nodes[i].name, ",state=",node_state)
	end
end
```






