-- tl_ops_limit
-- en : flow fuse limit 
-- zn : 流控，限流熔断实现
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_utils_func						= require("utils.tl_ops_utils_func");
local tl_ops_limit_fuse_check_dynamic_conf	= require("limit.fuse.tl_ops_limit_fuse_check_dynamic_conf")
local tl_ops_limit_fuse_check_version		= require("limit.fuse.tl_ops_limit_fuse_check_version")
local tl_ops_limit_token_bucket				= require("limit.fuse.tl_ops_limit_fuse_token_bucket");
local tl_ops_limit_leak_bucket				= require("limit.fuse.tl_ops_limit_fuse_leak_bucket");
local tl_ops_constant_limit					= require("constant.tl_ops_constant_limit")
local tl_ops_constant_health				= require("constant.tl_ops_constant_health")
local tl_ops_constant_service				= require("constant.tl_ops_constant_service")
local shared								= ngx.shared.tlopsbalance
local cjson									= require("cjson.safe");
local tlog									= require("utils.tl_ops_utils_log"):new("tl_ops_limit_fuse");


local _STATE = {
	LIMIT_FUSE_CLOSE = 0,  -- 熔断器关闭
	LIMIT_FUSE_HALF = 1,	 -- 半熔断/限流
	LIMIT_FUSE_OPEN = 2,	 -- 全熔断开启
}

local _M = {
    _VERSION = '0.02'
}
local mt = { __index = _M }


local tl_ops_limit_fuse_default_confs,
tl_ops_limit_fuse,
tl_ops_limit_fuse_main,
tl_ops_limit_fuse_get_lock,
tl_ops_limit_fuse_check_nodes,
tl_ops_limit_fuse_node_upgrade,
tl_ops_limit_fuse_node_degrade,
tl_ops_limit_fuse_service_upgrade,
tl_ops_limit_fuse_service_degrade,
tl_ops_limit_fuse_reset_count;


function _M:new( options , services)
	return setmetatable({options = options, services = services}, mt)
end


-- 限流熔断检测启动器
function _M:tl_ops_limit_fuse_start()

    if not self.options or not self.services then
		tlog:err("tl_ops_limit_fuse_start no default args ")
		return nil
	end
	
	local confs, _ = tl_ops_limit_fuse_default_confs(self.options, self.services)
	if not confs then
		tlog:err("tl_ops_limit_fuse_start failed to start , confs nil ", _)
		return nil
	end

	local timer_list = {};
	local timers_str = shared:get(tl_ops_constant_limit.fuse.cache_key.timers)
	if timers_str then
		timer_list = cjson.decode(timers_str);
	end
	
	for index, conf in ipairs(confs) do
		local ok, _ = ngx.timer.at(0, tl_ops_limit_fuse, conf)
		if not ok then
			tlog:err("tl_ops_limit_fuse_start failed to run check , create timer failed " , _)
			return nil
		end

		table.insert(timer_list, conf.service_name)
	end

	shared:set(tl_ops_constant_limit.fuse.cache_key.timers, cjson.encode(timer_list))

	tlog:dbg("tl_ops_limit_fuse_start check end , timer_list=",timer_list)

	return true
end



tl_ops_limit_fuse_default_confs = function(options, services)
	local confs = tl_ops_utils_func:new_tab(#options, 0)
	
	tlog:dbg("tl_ops_limit_fuse_default_confs start")

	for _, opt in pairs(options) do
		local interval = opt.interval
		if not tonumber(interval) then
			tlog:dbg("tl_ops_limit_fuse_default_confs warp default interval")
			interval = 1000
		else -- 最小 2ms
			if interval < 2 then  
				interval = 2
			end
		end
		interval = interval / 1000; 	-- 配置是ms格式, 使用是s格式

		local node_threshold = opt.node_threshold
		if not tonumber(node_threshold) then
			tlog:dbg("tl_ops_limit_fuse_default_confs warp default node_threshold")
		    node_threshold = 0.3
		end

		local service_threshold = opt.service_threshold
		if not tonumber(service_threshold) then
			tlog:dbg("tl_ops_limit_fuse_default_confs warp default service_threshold")
		    service_threshold = 0.5
		end

		local recover = opt.recover
		if not tonumber(recover) then
			tlog:dbg("tl_ops_limit_fuse_default_confs warp default recover")
		    recover = 3000
		else
			if recover < 1000 then  
				recover = 1000
			end
		end
		recover = recover / 1000; 	-- 配置是ms格式, 使用是s格式

		local depend = opt.depend
		if not depend then
			tlog:err("tl_ops_limit_fuse_default_confs warp default depend nil")
			return nil
		end
		if not tl_ops_constant_limit.depend[depend] then
			tlog:err("tl_ops_limit_fuse_default_confs warp default depend illegal")
			return nil
		end

		local mode = opt.mode
		if not mode then
			tlog:err("tl_ops_limit_fuse_default_confs warp default mode nil")
			return nil
		end
		if not tl_ops_constant_limit.mode[mode] then
			tlog:err("tl_ops_limit_fuse_default_confs warp default mode illegal")
			return nil
		end

		local level = opt.level
		if not level then
			tlog:err("tl_ops_limit_fuse_default_confs warp default level nil")
			return nil
		end
		if not tl_ops_constant_limit.level[level] then
			tlog:err("tl_ops_limit_fuse_default_confs warp default level illegal")
			return nil
		end

		local service_name = opt.service_name
		if not service_name then
			tlog:err("tl_ops_limit_fuse_default_confs warp default service_name nil")
			return nil
		end

		local nodes = services[service_name]
		if not nodes then
			tlog:err("tl_ops_limit_fuse_default_confs warp default nodes nil ")
			return nil
		end

		table.insert(confs, {
	        service_version = 0,					-- 配置版本号
			nodes = nodes,							-- 服务节点信息
			service_name = service_name,			-- 服务名称
			interval = interval,					-- 服务单次循环周期时间
			node_threshold = node_threshold,		-- 节点限流/熔断阈值
			service_threshold = service_threshold,	-- 服务限流/熔断阈值
	        recover = recover,						-- 熔断后自动恢复时间
	        depend = depend,						-- 自检依赖的模式
			mode = mode,							-- 熔断策略
			level = level,							-- 自检层级 
			state = _STATE.LIMIT_FUSE_CLOSE,		-- 服务熔断/限流状态
		})
	end

	tlog:dbg("tl_ops_limit_fuse_default_confs end")

	return confs
end


tl_ops_limit_fuse = function(premature, conf)
    if premature then
		return
	end

	tlog:dbg("tl_ops_limit_fuse start ",ngx.timer.running_count(), ",",ngx.timer.pending_count())

	local ok, _ = pcall(tl_ops_limit_fuse_main, conf)
	if not ok then
		tlog:err("tl_ops_limit_fuse failed to pcall : " ,  _)
	end

	-- 全熔断周期结束
	if conf.state == _STATE.LIMIT_FUSE_OPEN then
		local ok, _ = ngx.timer.at(conf.recover, tl_ops_limit_fuse, conf)
		if not ok then
			tlog:err("tl_ops_limit_fuse failed to create timer recover: " , _)
		end
	else
	-- 半熔断/关闭 状态周期结束
		local ok, _ = ngx.timer.at(conf.interval, tl_ops_limit_fuse, conf)
		if not ok then
			tlog:err("tl_ops_limit_fuse failed to create timer interval: " , _)
		end
	end

	tlog:dbg("tl_ops_limit_fuse end, service_name=",conf.service_name,",state=",conf.state,",interval=",conf.interval,",recover=",conf.recover)

end


tl_ops_limit_fuse_main = function( conf )
	tlog:dbg("tl_ops_limit_fuse_main start")

	--同步配置
	tl_ops_limit_fuse_check_dynamic_conf.dynamic_conf_change_start( conf )

	-- 自动熔断/恢复
	local lock_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.lock,conf.service_name)
    local lock_time = conf.interval - 0.01
    if tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
		tl_ops_limit_fuse_auto_recover( conf )
		tl_ops_limit_fuse_check_nodes( conf )
	end

    tlog:dbg("tl_ops_limit_fuse_main end")
end


-- 对配置的机器节点依次检测负载失败比例，以此决定node/service限流或熔断
tl_ops_limit_fuse_check_nodes = function ( conf )
	local service_name = conf.service_name
	local node_threshold = conf.node_threshold
	local service_threshold = conf.service_threshold
	local mode = conf.mode
	local nodes = conf.nodes

	local degrade_count = 0
	local upgrade_count = 0

	tlog:dbg("tl_ops_limit_fuse_check_nodes start : service_name=", service_name)

	if nodes == nil then
		tlog:err("tl_ops_limit_fuse_check_nodes nodes nil")
		return
	end

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
			tlog:dbg("node state upgrade : service_name=",service_name, ",node_name=",nodes[i].name, ",mode=",mode, ",state=",state)
			tl_ops_limit_fuse_node_upgrade( conf, node_id )
		else
			degrade_count = degrade_count + 1
			tlog:dbg("node state degrade : service_name=",service_name, ",node_name=",nodes[i].name, ",mode=",mode, ",state=",state)
			tl_ops_limit_fuse_node_degrade( conf, node_id )
		end
	end

	-- service层级
	local service_total_count = upgrade_count + degrade_count
	if service_total_count == 0 then
		service_total_count = -1 	-- can not be 0
	end
	-- 节点状态升级比率超过阈值，对服务进行状态升级
	if upgrade_count / service_total_count >= service_threshold then
		tlog:dbg("service state upgrade : service_name=",service_name,",upgrade_count=",upgrade_count, ",service_total_count=",service_total_count,",service_threshold=",(upgrade_count / service_total_count),",state=",conf.state)

		tl_ops_limit_fuse_service_upgrade( conf )
	else
		tlog:dbg("service state degrade : service_name=",service_name,",upgrade_count=",upgrade_count, ",service_total_count=",service_total_count,",service_threshold=",(upgrade_count / service_total_count),",state=",conf.state)
		
		tl_ops_limit_fuse_service_degrade( conf )
	end

	tlog:dbg("tl_ops_limit_fuse_check_nodes done")
end


-- 节点state降级
tl_ops_limit_fuse_node_degrade = function ( conf, node_id )
	tlog:dbg("tl_ops_limit_fuse_node_degrade start")

	local node = conf.nodes[node_id + 1]
	local name = node.name
	local state = node.state
	local depend = conf.depend
	local service_name = conf.service_name

	-- node处于限流状态, 节点桶扩容
	if state == _STATE.LIMIT_FUSE_HALF then
		-- 令牌桶模式
		if depend == tl_ops_constant_limit.depend.token then
			local expand = tl_ops_limit_token_bucket.tl_ops_limit_token_expand(service_name, node_id)
			if not expand or expand == false then
				tlog:err("tl_ops_limit_fuse_node_degrade expand token err ,",expand)
				return
			end
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.capacity, service_name, node_id)
			local capacity, _ = shared:get(key)

			tlog:dbg("tl_ops_limit_fuse_node_degrade expand token ok, node=",name,", capacity=",capacity)
		end
		-- 漏桶模式
		if depend == tl_ops_constant_limit.depend.leak then
			local expand = tl_ops_limit_leak_bucket.tl_ops_limit_leak_expand(service_name, node_id)
			if not expand or expand == false then
				tlog:err("tl_ops_limit_fuse_node_degrade expand leak err ,",expand)
				return
			end
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.capacity, service_name, node_id)
			local capacity, _ = shared:get(key)

			tlog:dbg("tl_ops_limit_fuse_node_degrade expand leak ok, node=",name,", capacity=",capacity)
		end
		
	end

	-- 同步state, 通知worker更新
	if state > _STATE.LIMIT_FUSE_CLOSE then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name, node_id)
		local ok, _ = shared:get(key);
		if not ok then
			local res, _ = shared:set(key, _STATE.LIMIT_FUSE_OPEN);
			if not res then
				tlog:err("tl_ops_limit_fuse_node_degrade get state err ,key=",key)
			end
			
			tlog:dbg("tl_ops_limit_fuse_node_degrade first update state, key=",key)
		end
		ok, _ = shared:set(key , state - 1)
		if not ok then
			tlog:err("tl_ops_limit_fuse_node_degrade set state err ,key=",key)
		else
			node.state = state - 1
		end

		conf.service_version = tl_ops_limit_fuse_check_version.incr_service_version(service_name);
	end

	tlog:dbg("tl_ops_limit_fuse_node_degrade done")
end

-- 节点state升级
tl_ops_limit_fuse_node_upgrade = function ( conf, node_id )
	tlog:dbg("tl_ops_limit_fuse_node_upgrade start")

	local node = conf.nodes[node_id + 1]
	local name = node.name
	local state = node.state
	local depend = conf.depend
	local service_name = conf.service_name

	-- node处于限流状态, 节点桶缩容
	if state == _STATE.LIMIT_FUSE_HALF then
		-- 令牌桶模式
		if depend == tl_ops_constant_limit.depend.token then
			local shrink = tl_ops_limit_token_bucket.tl_ops_limit_token_shrink(service_name, node_id)
			if not shrink or shrink == false then
				tlog:err("tl_ops_limit_fuse_node_upgrade shrink token err, shrink=",shrink)
				return
			end
	
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.capacity, service_name, node_id)
			local capacity, _ = shared:get(key)
	
			tlog:dbg("tl_ops_limit_fuse_node_upgrade shrink token ok, node=",name,", capacity=",capacity,",key=",key)
		end

		-- 漏桶模式
		if depend == tl_ops_constant_limit.depend.leak then
			local shrink = tl_ops_limit_leak_bucket.tl_ops_limit_leak_shrink(service_name, node_id)
			if not shrink or shrink == false then
				tlog:err("tl_ops_limit_fuse_node_upgrade shrink leak err, shrink=",shrink)
				return
			end
	
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.capacity, service_name, node_id)
			local capacity, _ = shared:get(key)
	
			tlog:dbg("tl_ops_limit_fuse_node_upgrade shrink leak ok, node=",name,", capacity=",capacity,",key=",key)
		end
	end

	-- 同步state, 通知worker更新
	if state < _STATE.LIMIT_FUSE_OPEN then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name, node_id)
		local ok, _ = shared:get(key);
		if not ok then
			local res, _ = shared:set(key, _STATE.LIMIT_FUSE_CLOSE);
			if not res then
				tlog:err("tl_ops_limit_fuse_node_upgrade get state err ,key=",key)
			end
			
			tlog:dbg("tl_ops_limit_fuse_node_upgrade first update state, key=",key)
		end
		ok, _ = shared:set(key , state + 1)
		if not ok then
			tlog:err("tl_ops_limit_fuse_node_upgrade set state err ,key=",key)
		else
			node.state = state + 1
		end

		conf.service_version = tl_ops_limit_fuse_check_version.incr_service_version(service_name);
	end

	tlog:dbg("tl_ops_limit_fuse_node_upgrade done")
end


-- 服务state降级
tl_ops_limit_fuse_service_degrade = function ( conf )
	tlog:dbg("tl_ops_limit_fuse_service_degrade start")

	local state = conf.state
	local depend = conf.depend
	local service_name = conf.service_name

	-- node处于限流状态, 节点桶扩容
	if state == _STATE.LIMIT_FUSE_HALF then
		-- 令牌桶模式
		if depend == tl_ops_constant_limit.depend.token then
			local expand = tl_ops_limit_token_bucket.tl_ops_limit_token_expand(service_name)
			if not expand or expand == false then
				tlog:err("tl_ops_limit_fuse_service_degrade expand token err ,",expand)
				return
			end
	
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.capacity, service_name)
			local capacity, _ = shared:get(key)
	
			tlog:dbg("tl_ops_limit_fuse_service_degrade expand token ok, service_name=",service_name,", capacity=",capacity,",key=",key)
		end

		-- 漏桶模式
		if depend == tl_ops_constant_limit.depend.leak then
			local expand = tl_ops_limit_leak_bucket.tl_ops_limit_leak_expand(service_name)
			if not expand or expand == false then
				tlog:err("tl_ops_limit_fuse_service_degrade expand leak err ,",expand)
				return
			end
	
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.capacity, service_name)
			local capacity, _ = shared:get(key)
	
			tlog:dbg("tl_ops_limit_fuse_service_degrade expand leak ok, service_name=",service_name,", capacity=",capacity,",key=",key)
		end
	end

	-- 同步state, 通知worker更新
	if state > _STATE.LIMIT_FUSE_CLOSE then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name)
		local ok, _ = shared:get(key);
		if not ok then
			local res, _ = shared:set(key, _STATE.LIMIT_FUSE_CLOSE);
			if not res then
				tlog:err("tl_ops_limit_fuse_service_degrade get state err ,key=",key)
			end
			
			tlog:dbg("tl_ops_limit_fuse_service_degrade first update state, key=",key)
		end
		ok, _ = shared:set(key , state - 1)
		if not ok then
			tlog:err("tl_ops_limit_fuse_service_degrade set state err ,key=",key)
		else
			conf.state = state - 1
		end

		conf.service_version = tl_ops_limit_fuse_check_version.incr_service_version(service_name);
	end

	tlog:dbg("tl_ops_limit_fuse_service_degrade done")
end

-- 服务state升级
tl_ops_limit_fuse_service_upgrade = function ( conf )
	tlog:dbg("tl_ops_limit_fuse_service_upgrade start")

	local state = conf.state
	local depend = conf.depend
	local service_name = conf.service_name

	-- node处于限流状态, 节点桶扩容
	if state == _STATE.LIMIT_FUSE_HALF then
		-- 令牌桶模式
		if depend == tl_ops_constant_limit.depend.token then
			local shrink = tl_ops_limit_token_bucket.tl_ops_limit_token_shrink(service_name)
			if not shrink or shrink == false then
				tlog:err("tl_ops_limit_fuse_service_upgrade shrink token err ,",shrink)
				return
			end
	
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.capacity, service_name)
			local capacity, _ = shared:get(key)
	
			tlog:dbg("tl_ops_limit_fuse_service_upgrade shrink token ok, service_name=",service_name,", capacity=",capacity,",key=",key)
		end

		-- 漏桶模式
		if depend == tl_ops_constant_limit.depend.leak then
			local shrink = tl_ops_limit_leak_bucket.tl_ops_limit_leak_shrink(service_name)
			if not shrink or shrink == false then
				tlog:err("tl_ops_limit_fuse_service_upgrade shrink leak err ,",shrink)
				return
			end
	
			local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.capacity, service_name)
			local capacity, _ = shared:get(key)
	
			tlog:dbg("tl_ops_limit_fuse_service_upgrade shrink leak ok, service_name=",service_name,", capacity=",capacity,",key=",key)
		end
	end

	-- 同步state, 通知worker更新
	if state < _STATE.LIMIT_FUSE_OPEN then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name)
		local ok, _ = shared:get(key);
		if not ok then
			local res, _ = shared:set(key, _STATE.LIMIT_FUSE_CLOSE);
			if not res then
				tlog:err("tl_ops_limit_fuse_service_upgrade get state err ,key=",key)
			end
			
			tlog:dbg("tl_ops_limit_fuse_service_upgrade first update state, key=",key)
		end
		ok, _ = shared:set(key , state + 1)
		if not ok then
			tlog:err("tl_ops_limit_fuse_service_upgrade set state err ,key=",key)
		else
			conf.state = state + 1
		end

		conf.service_version = tl_ops_limit_fuse_check_version.incr_service_version(service_name);
	end

	tlog:dbg("tl_ops_limit_fuse_service_upgrade done")
end


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


return _M