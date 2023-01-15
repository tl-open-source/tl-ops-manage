-- tl_ops_limit
-- en : limit fuse dynamic conf
-- zn : 限流熔断加载动态新增服务配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson						= require("cjson.safe");
local tlog						= require("utils.tl_ops_utils_log"):new("tl_ops_limit_fuse_check_dynamic_conf");
local tl_ops_utils_func			= require("utils.tl_ops_utils_func");
local tl_ops_constant_limit		= require("constant.tl_ops_constant_limit")
local cache_limit				= require("cache.tl_ops_cache_core"):new("tl-ops-limit");
local tl_ops_constant_service	= require("constant.tl_ops_constant_service")
local shared					= ngx.shared.tlopsbalance

local tl_ops_limit_fuse_check_dynamic_conf_add_timer_check;


--[[
	以下是同步worker conf新增接口
]]

-- 校验service是否已有对应的 limit fuse option
local tl_ops_limit_fuse_check_dynamic_conf_all_service_option_asynced = function( options, services )
	local service_has_options = {}; 

	for service_name, nodes in pairs(services) do
		service_has_options[service_name] = false
		for i = 1, #options do
			local option = options[i]
			if service_name == option.service_name then
				service_has_options[service_name] = true
				break
			end
		end
		if service_has_options[service_name] == false then
			tlog:dbg("[add-check] has options not ready , service_name=",service_name)
			return false
		end
	end

	return true
end

-- 通过service name获取对于的option
local tl_ops_limit_fuse_check_dynamic_conf_get_option = function( options, name )
	for i = 1, #options do
		local service_name = options[i].service_name
		if name == service_name then
			return { options[i] }
		end
	end
	return nil
end


-- 获取当前限流熔断的所有service，并对新增的service启动定时器
-- key : tl_ops_limit_fuse_timers
-- value : ['service1','service2',...]
local tl_ops_limit_fuse_check_dynamic_conf_add_core = function(options, services)

	-- 暂时还有service的option未同步对应的，先不执行，等到option准备完毕再执行后续逻辑
	local all_service_option_asynced = tl_ops_limit_fuse_check_dynamic_conf_all_service_option_asynced(options, services)
	if not all_service_option_asynced then
		return
	end

	-- 查看现在已有的service timer，如果没有，说明首次启动，为所有service启动timer
	local timers_str = shared:get(tl_ops_constant_limit.fuse.cache_key.timers)
	if not timers_str then
		tlog:dbg("[add-check] first new timer done")

		require("limit.fuse.tl_ops_limit_fuse_check"):new(options, services):tl_ops_limit_fuse_start();
		shared:set(tl_ops_constant_limit.fuse.cache_key.service_options_version, nil)
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
			local matcher_options = tl_ops_limit_fuse_check_dynamic_conf_get_option( options, service_name)
			tlog:dbg("[add-check] new timer done, service_name=",service_name, ",matcher_options=",matcher_options)

			require("limit.fuse.tl_ops_limit_fuse_check"):new(matcher_options, services):tl_ops_limit_fuse_start();
			shared:set(tl_ops_constant_limit.fuse.cache_key.service_options_version, nil)
		end
	end
end


-- 同步新增的service option
-- key : tl_ops_limit_version
-- value : true/false
local tl_ops_limit_fuse_check_dynamic_conf_add_check = function()
	tlog:dbg("[add-check] loop check cus options version start")

	local version, _ = shared:get(tl_ops_constant_limit.fuse.cache_key.service_options_version)
	if not version then
		return
	end

	tlog:dbg("[add-check] service version conf true ")

	local options_str, _ = cache_limit:get(tl_ops_constant_limit.fuse.cache_key.options_list)
	if not options_str then
		tlog:err("[add-check] load dynamic options failed , options_str=",options_str)
		return
	end
	local dynamic_options = cjson.decode(options_str)

	local cache_service = require("cache.tl_ops_cache_core"):new("tl-ops-service");
	local service_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list)
	if not service_str then
		tlog:err("[add-check] load dynamic service failed , service_str=",service_str)
		return
	end
	local dynamic_service = cjson.decode(service_str)

	if dynamic_options and dynamic_service then		
		tl_ops_limit_fuse_check_dynamic_conf_add_core(dynamic_options, dynamic_service)
		tlog:dbg("[add-check] async dynamic conf done")
	end
end


-- 加载新增配置的周期为10s
tl_ops_limit_fuse_check_dynamic_conf_add_timer_check = function(premature, args)
	if premature then
		return
	end

	local ok, _ = pcall(tl_ops_limit_fuse_check_dynamic_conf_add_check)
	if not ok then
		tlog:err("[add-check] failed to pcall : " ,  _)
	end

	local interval = 10

	local ok, _ = ngx.timer.at(interval, tl_ops_limit_fuse_check_dynamic_conf_add_timer_check, args)
	if not ok then
		tlog:err("[add-check] failed to create timer: " , _)
	end
end


-- 动态配置加载器启动
local tl_ops_limit_fuse_check_dynamic_conf_add_start = function() 
    local ok, _ = ngx.timer.at(0, tl_ops_limit_fuse_check_dynamic_conf_add_timer_check, nil)
	if not ok then
		tlog:err("[add-check] failed to run default args check , create timer failed " ,_)
		return nil
	end
end





--[[
	以下是同步worker conf变更接口
]]


-- 是否是新增的节点
local tl_ops_limit_fuse_check_dynamic_conf_exsit_node = function(nodes, name)
	for i = 1, #nodes do
		local node = nodes[i]
		if node.name == name then
			return true
		end
	end

	return false;
end


-- 同步state
local tl_ops_limit_fuse_dynamic_conf_change_state_async = function( conf )
    local nodes = conf.nodes;
	if nodes == nil then
		tlog:err("[change-check] nodes nil")
		return
	end
	for i = 1, #nodes do
		local node_id = i - 1
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, conf.service_name, node_id)
		local node_state, _ = shared:get(key)

		tlog:dbg("[change-check] node state, key=",key,",state=",node_state)

		if not node_state then
			nodes[i].state = 0
		else
			nodes[i].state = node_state
		end
	end

	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, conf.service_name)
	local state, _ = shared:get(key)
	if not state then
		conf.state = 0
	else
		conf.state = state
	end
end

-- 同步limit fuse check option
local tl_ops_limit_fuse_dynamic_conf_change_service_options_async = function( conf )
    local options_str, _ = cache_limit:get(tl_ops_constant_limit.fuse.cache_key.options_list)
	if not options_str then
		tlog:err("[change-check] load dynamic options failed , options_str=",options_str)
		return
	end
    local dynamic_options = cjson.decode(options_str)
    
	if not dynamic_options then
		tlog:err("[change-check] load dynamic options decode failed , options_str=",options_str)
		return
	end

	
	local matcher_options = tl_ops_limit_fuse_check_dynamic_conf_get_option( dynamic_options, conf.service_name )

	if matcher_options and matcher_options[1] then
		local option = matcher_options[1]

		local interval = option.interval
		if not tonumber(interval) then
			interval = 1000
		else -- 最小 2ms
			if interval < 2 then  
				interval = 2
			end
		end
		interval = interval / 1000; 	-- 配置是ms格式, 使用是s格式

		local node_threshold = option.node_threshold
		if not tonumber(node_threshold) then
		    node_threshold = 0.3
		end

		local service_threshold = option.service_threshold
		if not tonumber(service_threshold) then
		    service_threshold = 0.5
		end

		local recover = option.recover
		if not tonumber(recover) then
		    recover = 3000
		else
			if recover < 1000 then  
				recover = 1000
			end
		end
		recover = recover / 1000; 	-- 配置是ms格式, 使用是s格式

		conf.interval = interval
		conf.node_threshold = node_threshold         
		conf.service_threshold = service_threshold
		conf.recover = recover
		conf.depend = option.depend
		conf.level = option.level
		conf.mode = option.mode
	end
end

-- 同步service node配置
local tl_ops_limit_fuse_dynamic_conf_change_service_node_async = function( conf )
	local cache_service = require("cache.tl_ops_cache_core"):new("tl-ops-service");
	local service_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list)
	if not service_str then
		tlog:err("[change-check] load dynamic service failed , service_str=",service_str)
		return
	end
	local dynamic_service = cjson.decode(service_str)
    
	if dynamic_service then
		conf.nodes = dynamic_service[conf.service_name]
	end
end

-- 同步变更的service信息
local tl_ops_limit_fuse_check_dynamic_conf_change_core = function( conf, service_version )

	-- 保证更新顺序，service/options > service.nodes > node.state 
    tl_ops_limit_fuse_dynamic_conf_change_service_options_async(conf)
    tl_ops_limit_fuse_dynamic_conf_change_service_node_async(conf)
	tl_ops_limit_fuse_dynamic_conf_change_state_async(conf)
	
	conf.service_version = service_version

end

-- 校验是否需要同步conf变更
local tl_ops_limit_fuse_check_dynamic_conf_change_check = function( conf )
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_version, conf.service_name)
	local service_version, _ = shared:get(key)

	tlog:dbg("[change-check] start check conf_version=",conf.service_version,",service_version=" , service_version, ",key=",key)

	if not service_version then
		local ok ,_ = shared:add(key, 1)
		if not ok then
			tlog:err("[change-check] failed to init service_version key, " , _)
		end
		return
	end

	if service_version > conf.service_version then
		tlog:dbg("[change-check] conf need update, service_version=", service_version, ",conf.service_version=",conf.service_version)
		tl_ops_limit_fuse_check_dynamic_conf_change_core( conf, service_version )
    end
end

-- 动态配置加载器启动
local tl_ops_limit_fuse_check_dynamic_conf_change_start = function( conf ) 
    if not conf then
        tlog:err("[change-check] err , conf nil")
    end
	tl_ops_limit_fuse_check_dynamic_conf_change_check(conf)
end


return {
	dynamic_conf_change_start = tl_ops_limit_fuse_check_dynamic_conf_change_start,
	dynamic_conf_add_start = tl_ops_limit_fuse_check_dynamic_conf_add_start
}