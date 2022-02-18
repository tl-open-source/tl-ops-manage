-- tl_ops_limit
-- en : flow fuse limit 
-- zn : 流控，限流熔断实现
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_limit_fuse");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local tl_ops_limit_token_bucket = require("limit.tl_ops_limit_token_bucket");

local tl_ops_limit_fuse_check_dynamic_conf = require("limit.fuse.tl_ops_limit_fuse_check_dynamic_conf")
local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")

local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");

local shared = ngx.shared.tlopsbalance

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end


local _STATE = {
	LIMIT_FUSE_CLOSE = 0,  ---- 熔断器关闭
	LIMIT_FUSE_HALF = 1,	 ---- 半熔断/限流
	LIMIT_FUSE_OPEN = 2,	 ---- 全熔断开启
}

local _M = {
    _VERSION = '0.01'
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


---- 限流熔断检测启动器
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
	
	for index, conf in ipairs(confs) do
		local ok, _ = ngx.timer.at(0, tl_ops_limit_fuse, conf)
		if not ok then
			tlog:err("tl_ops_limit_fuse_start failed to run check , create timer failed " , _)
			return nil
		end
	end

	tlog:dbg("tl_ops_limit_fuse_start check end")

	return true
end



tl_ops_limit_fuse_default_confs = function(options, services)
	local confs = new_tab(#options, 0)
	
	tlog:dbg("tl_ops_limit_fuse_default_confs start")

	for _, opt in pairs(options) do
		local interval = opt.interval
		if not tonumber(interval) then
			tlog:dbg("tl_ops_limit_fuse_default_confs warp default interval")
			interval = 1000
		else ---- 最小 2ms
			if interval < 2 then  
				interval = 2
			end
		end
		interval = interval / 1000; 	---- 配置是ms格式, 使用是s格式

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
		recover = recover / 1000; 	---- 配置是ms格式, 使用是s格式

		local depend = opt.depend
		if not depend then
			tlog:err("tl_ops_limit_fuse_default_confs warp default depend nil")
			return nil
		end
		if not tl_ops_constant_limit.depend[depend] then
			tlog:err("tl_ops_limit_fuse_default_confs warp default depend illegal")
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

		-- bucket conf
		local service_token_bucket = tl_ops_limit_token_bucket:new(
			tl_ops_constant_limit.service_token.options, tl_ops_constant_limit.service_token_cache_key(service_name)
		)
		for i = 1, #nodes do
			local node_id = i - 1
			local node_token_bucket = tl_ops_limit_token_bucket:new(
				tl_ops_constant_limit.node_token.options, tl_ops_constant_limit.node_token_cache_key(service_name, node_id)
			)
			nodes[i].bucket = node_token_bucket		---- 节点桶
			nodes[i].state = _STATE.LIMIT_FUSE_CLOSE	---- 节点熔断/限流状态
		end

		table.insert(confs, {
	        service_version = 0,					---- 配置版本号
			nodes = nodes,							---- 服务节点信息
			service_name = service_name,			---- 服务名称
			interval = interval,					---- 服务单次循环周期时间
			node_threshold = node_threshold,		---- 节点限流/熔断阈值
			service_threshold = service_threshold,	---- 服务限流/熔断阈值
	        recover = recover,						---- 熔断后自动恢复时间
	        depend = depend,						---- 自检依赖的模式
			level = level,							---- 自检层级 
			state = _STATE.LIMIT_FUSE_CLOSE,	---- 服务熔断/限流状态
			bucket = service_token_bucket,			---- 服务桶
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

	---- 全熔断周期结束
	if conf.state == _STATE.LIMIT_FUSE_OPEN then
		local ok, _ = ngx.timer.at(conf.recover, tl_ops_limit_fuse, conf)
		if not ok then
			tlog:err("tl_ops_limit_fuse failed to create timer recover: " , _)
		end
	else
	---- 半熔断/关闭 状态周期结束
		local ok, _ = ngx.timer.at(conf.interval, tl_ops_limit_fuse, conf)
		if not ok then
			tlog:err("tl_ops_limit_fuse failed to create timer interval: " , _)
		end
	end

	tlog:dbg("tl_ops_limit_fuse end")

end


tl_ops_limit_fuse_main = function( conf )
	tlog:dbg("tl_ops_limit_fuse_main start")

	----同步配置
	tl_ops_limit_fuse_check_dynamic_conf.dynamic_conf_change_start( conf )

	---- 自动熔断/恢复
	if tl_ops_limit_fuse_get_lock( conf ) then
		tl_ops_limit_fuse_auto_recover( conf )
		tl_ops_limit_fuse_check_nodes( conf )
	end

    tlog:dbg("tl_ops_limit_fuse_main end")
end


tl_ops_limit_fuse_get_lock = function(conf)
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.lock,conf.service_name)

	tlog:dbg("tl_ops_limit_fuse_get_lock start : key=", key)

	local ok, _ = shared:add(key, true, conf.interval - 0.01)
	if not ok then
		if _ == "exists" then
			tlog:dbg("tl_ops_limit_fuse_get_lock key exists : key=", key)
			return nil
		end
		tlog:err("tl_ops_limit_fuse_get_lock failed to add key, get lock failed, key=" ,key)
		return nil
	end
	
	tlog:dbg("tl_ops_limit_fuse_get_lock done : key=", key, ",service_name=" , conf.service_name)

	return true
end


---- 对配置的机器节点依次检测负载失败比例，以此决定node/service限流或熔断
tl_ops_limit_fuse_check_nodes = function ( conf )
	local service_name = conf.service_name
	local recover = conf.recover
	local interval = conf.interval
	local node_threshold = conf.node_threshold
	local service_threshold = conf.service_threshold
	local nodes = conf.nodes

	local degrade_count = 0
	local upgrade_count = 0

	tlog:dbg("tl_ops_limit_fuse_check_nodes start : service_name=", service_name)

	---- node层级
	for i = 1, #nodes do
		local node_id = i-1

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
			total_count = -1 	---- can not be 0
		end

		tlog:dbg("tl_ops_limit_fuse_check_nodes, node=", nodes[i].name, ",succ=",success_count, ",fail=",failed_count, ",total=",total_count)

		---- 超过阈值
		if failed_count / total_count >= node_threshold then
			upgrade_count = upgrade_count + 1
			tl_ops_limit_fuse_node_upgrade( conf, node_id )
		else
			degrade_count = degrade_count + 1
			tl_ops_limit_fuse_node_degrade( conf, node_id )
		end
	end

	---- service层级
	local service_total_count = upgrade_count + degrade_count
	if service_total_count == 0 then
		service_total_count = -1 	---- can not be 0
	end
	if degrade_count / service_total_count >= service_threshold then
		tl_ops_limit_fuse_service_upgrade( conf )
	else
		tl_ops_limit_fuse_service_degrade( conf )
	end

	tlog:dbg("tl_ops_limit_fuse_check_nodes done : conf=", conf)

	tl_ops_limit_fuse_reset_count( conf )
end


-- 节点state降级
tl_ops_limit_fuse_node_degrade = function ( conf, node_id )
	tlog:dbg("tl_ops_limit_fuse_node_degrade start")

	local node = conf.nodes[node_id + 1]
	local name = node.name
	local state = node.state
	local node_bucket = node.bucket
	local service_name = conf.service_name

	---- node处于限流状态, 节点桶扩容
	if state == _STATE.LIMIT_FUSE_HALF then
		local expand = node_bucket:tl_pos_limit_token_expand()
		if not expand or expand == false then
			tlog:err("tl_ops_limit_fuse_node_degrade expand err ,",expand)
			return
		end

		tlog:dbg("tl_ops_limit_fuse_node_degrade expand ok , node_bucket=",node_bucket)
	end

	---- 同步state, 通知worker更新
	if state > _STATE.LIMIT_FUSE_CLOSE then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_node_state, service_name, id)
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
	local node_bucket = node.bucket
	local service_name = conf.service_name

	---- node处于限流状态, 节点桶缩容
	if state == _STATE.LIMIT_FUSE_HALF then
		local shrink = node_bucket:tl_pos_limit_token_shrink()
		if not shrink or shrink == false then
			tlog:err("tl_ops_limit_fuse_node_upgrade shrink err ,",shrink)
			return
		end

		tlog:dbg("tl_ops_limit_fuse_node_upgrade shrink ok , node_bucket=",node_bucket)
	end

	---- 同步state, 通知worker更新
	if state < _STATE.LIMIT_FUSE_OPEN then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_node_state, service_name, id)
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
	local service_bucket = conf.bucket
	local service_name = conf.service_name

	---- node处于限流状态, 节点桶扩容
	if state == _STATE.LIMIT_FUSE_HALF then
		local expand = service_bucket:tl_pos_limit_token_expand()
		if not expand or expand == false then
			tlog:err("tl_ops_limit_fuse_service_degrade expand err ,",expand)
			return
		end

		tlog:dbg("tl_ops_limit_fuse_service_degrade expand ok , service_bucket=",service_bucket)
	end

	---- 同步state, 通知worker更新
	if state > _STATE.LIMIT_FUSE_CLOSE then
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name)
		local ok, _ = shared:get(key);
		if not ok then
			local res, _ = shared:set(key, _STATE.LIMIT_FUSE_OPEN);
			if not res then
				tlog:err("tl_ops_limit_fuse_service_degrade get state err ,key=",key)
			end
			
			tlog:dbg("tl_ops_limit_fuse_service_degrade first update state, key=",key)
		end
		ok, _ = shared:set(key , state + 1)
		if not ok then
			tlog:err("tl_ops_limit_fuse_service_degrade set state err ,key=",key)
		else
			conf.state = state + 1
		end

		conf.service_version = tl_ops_limit_fuse_check_version.incr_service_version(service_name);
	end

	tlog:dbg("tl_ops_limit_fuse_service_degrade done")
end
-- 服务state升级
tl_ops_limit_fuse_service_upgrade = function ( conf )
	tlog:dbg("tl_ops_limit_fuse_service_upgrade start")

	local state = conf.state
	local service_bucket = conf.bucket
	local service_name = conf.service_name

	---- node处于限流状态, 节点桶扩容
	if state == _STATE.LIMIT_FUSE_HALF then
		local shrink = service_bucket:tl_pos_limit_token_shrink()
		if not shrink or shrink == false then
			tlog:err("tl_ops_limit_fuse_service_upgrade shrink err ,",shrink)
			return
		end

		tlog:dbg("tl_ops_limit_fuse_service_upgrade shrink ok , service_bucket=",service_bucket)
	end

	---- 同步state, 通知worker更新
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
		ok, _ = shared:set(key , state - 1)
		if not ok then
			tlog:err("tl_ops_limit_fuse_service_upgrade set state err ,key=",key)
		else
			conf.state = state - 1
		end

		conf.service_version = tl_ops_limit_fuse_check_version.incr_service_version(service_name);
	end

	tlog:dbg("tl_ops_limit_fuse_service_upgrade done")
end


---- 单个周期内请求次数统计，周期结束清除
tl_ops_limit_fuse_reset_count = function ( conf )
	local service_name = conf.service_name
	local nodes = conf.nodes

	for i = 1, #nodes do
		local node_id = i-1

		local success_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, service_name, node_id)
		shared:set(success_count_key, 0)

		local failed_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail, service_name, node_id)
		shared:set(failed_count_key, 0)

	end

	tlog:dbg("tl_ops_limit_fuse_reset_count done")
end


---- 全熔断自动恢复
tl_ops_limit_fuse_auto_recover = function( conf )
	local nodes = conf.nodes
	local service_state = conf.state
	local service_name = conf.service_name

	---- 服务熔断自动恢复
	if service_state == _STATE.LIMIT_FUSE_OPEN then
		tl_ops_limit_fuse_service_degrade( conf )
		tlog:dbg("tl_ops_limit_fuse_auto_recover service done : service=", service_name, ",state=",service_state)
	end

	---- 节点熔断自动恢复
	for i = 1, #nodes do
		local node_id = i-1
		local node_state = nodes[i].state
		if node_state == _STATE.LIMIT_FUSE_OPEN then
			tl_ops_limit_fuse_node_degrade( conf, node_id)
		end
		tlog:dbg("tl_ops_limit_fuse_auto_recover node done : node=", nodes[i].name, ",state=",node_state)
	end

end

return _M