-- tl_ops_health
-- en : health check dynamic conf
-- zn : 健康检查加载动态新增服务配置
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_health_check_dynamic_conf");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local cache_health = require("cache.tl_ops_cache"):new("tl-ops-health");
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local shared = ngx.shared.tlopsbalance

-- 需要提前定义，定时器访问不了
local tl_ops_health_check_dynamic_conf_add_timer_check;


--[[
	以下是同步worker conf新增接口
]]

---- 校验service是否已有对应的health check option
local tl_ops_health_check_dynamic_conf_all_service_option_asynced = function( options, services )
	local service_has_options = {}; 

	for service_name, nodes in pairs(services) do
		service_has_options[service_name] = false
		for i = 1, #options do
			local option = options[i]
			if service_name == option.check_service_name then
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

---- 通过service name获取对于的option
local tl_ops_health_check_dynamic_conf_get_option = function( options, name )
	for i = 1, #options do
		local service_name = options[i].check_service_name
		if name == service_name then
			return { options[i] }
		end
	end
	return nil
end

---- 获取当前健康检查的所有service，并对新增的service启动定时器，key : tl_ops_health_timers，value : ['service1','service2',...]
local tl_ops_health_check_dynamic_conf_add_core = function(options, services)

	-- 暂时还有service的option未同步对应的，先不执行，等到option准备完毕再执行后续逻辑
	local all_service_option_asynced = tl_ops_health_check_dynamic_conf_all_service_option_asynced(options, services)
	if not all_service_option_asynced then
		return
	end

	-- 查看现在已有的service timer，如果没有，说明首次启动，为所有service启动timer
	local timers_str = shared:get(tl_ops_constant_health.cache_key.timers)
	if not timers_str then
		tlog:dbg("[add-check] first new timer done")

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
			tlog:dbg("[add-check] new timer done, service_name=",service_name, ",matcher_options=",matcher_options)

			require("health.tl_ops_health_check"):new(matcher_options, services):tl_ops_health_check_start();
			shared:set(tl_ops_constant_health.cache_key.service_options_version, nil)
		end
	end
end

---- 同步新增的service option
---- key : tl_ops_health_version
---- value : true/false
local tl_ops_health_check_dynamic_conf_add_check = function()
	tlog:dbg("[add-check] loop check cus options version start")

	local version, _ = shared:get(tl_ops_constant_health.cache_key.service_options_version)
	if not version then
		return
	end

	tlog:dbg("[add-check] service version conf true ")

	local options_str, _ = cache_health:get(tl_ops_constant_health.cache_key.options_list)
	if not options_str then
		tlog:dbg("[add-check] load dynamic options failed , options_str=",options_str)
		return
	end
	local dynamic_options = cjson.decode(options_str)

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

---- 加载新增配置的周期为10s
tl_ops_health_check_dynamic_conf_add_timer_check = function(premature, args)
	if premature then
		return
	end

	local ok, _ = pcall(tl_ops_health_check_dynamic_conf_add_check)
	if not ok then
		tlog:err("[add-check] failed to pcall : " ,  _)
	end

	local interval = 10

	local ok, _ = ngx.timer.at(interval, tl_ops_health_check_dynamic_conf_add_timer_check, args)
	if not ok then
		tlog:err("[add-check] failed to create timer: " , _)
	end
end

---- 动态配置加载器启动
local tl_ops_health_check_dynamic_conf_add_start = function() 
	local ok, _ = ngx.timer.at(0, tl_ops_health_check_dynamic_conf_add_timer_check, nil)
	if not ok then
		tlog:err("[add-check] failed to run default args check , create timer failed " ,_)
		return nil
	end
end




--[[
	以下是同步worker conf变更接口
]]

---- 同步state
local tl_ops_health_check_dynamic_conf_change_state_async = function( conf )
    local nodes = conf.nodes;
	if nodes == nil then
		tlog:dbg("[change-check] nodes nil")
		return
	end
	for i = 1, #nodes do
		local node_id = i - 1
		local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, conf.check_service_name, node_id)
		local res, _ = shared:get(key)

		tlog:dbg("[change-check] node state, key=",key,",state=",res)

		if not res then
			nodes[i].state = false
		else
			nodes[i].state = true
		end
	end
end

---- 同步health check option
local tl_ops_health_check_dynamic_conf_change_service_options_async = function( conf )
    local options_str, _ = cache_health:get(tl_ops_constant_health.cache_key.options_list)
	if not options_str then
		tlog:dbg("[change-check] load dynamic options failed , options_str=",options_str)
		return
	end
    local dynamic_options = cjson.decode(options_str)
    
    if dynamic_options then
		local matcher_options = tl_ops_health_check_dynamic_conf_get_option( dynamic_options, conf.check_service_name )
		if matcher_options and matcher_options[1] then
			local option = matcher_options[1]
			conf.check_content = option.check_content
			conf.check_timeout = option.check_timeout
			conf.check_failed_max_count = option.check_failed_max_count
			conf.check_success_max_count = option.check_success_max_count
		end
		
	end
end

---- 同步service配置
local tl_ops_health_check_dynamic_conf_change_service_node_async = function( conf )
	local service_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list)
	if not service_str then
		tlog:dbg("[change-check] load dynamic service failed , service_str=",service_str)
		return
	end
	local dynamic_service = cjson.decode(service_str)
    
    if dynamic_service then
        conf.nodes = dynamic_service[conf.check_service_name]
	end
end

---- 同步变更的service信息
local tl_ops_health_check_dynamic_conf_change_core = function( conf, service_version )

	-- 保证更新顺序，service/options > service.nodes > node.state 
    tl_ops_health_check_dynamic_conf_change_service_options_async(conf)
    tl_ops_health_check_dynamic_conf_change_service_node_async(conf)
    tl_ops_health_check_dynamic_conf_change_state_async(conf)
	conf.service_version = service_version

end

---- 校验是否需要同步conf变更
local tl_ops_health_check_dynamic_conf_change_check = function( conf )
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, conf.check_service_name)
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
		tlog:dbg("[change-check] conf need update, service_version=", service_version, "conf.service_version=",conf.service_version)
		tl_ops_health_check_dynamic_conf_change_core( conf, service_version )
    end
end

---- 动态配置加载器启动
local tl_ops_health_check_dynamic_conf_change_start = function( conf ) 

    if not conf then
        tlog:err("[change-check] err , conf nil")
    end
	tl_ops_health_check_dynamic_conf_change_check(conf)

end


return {
	dynamic_conf_change_start = tl_ops_health_check_dynamic_conf_change_start,
	dynamic_conf_add_start = tl_ops_health_check_dynamic_conf_add_start
}