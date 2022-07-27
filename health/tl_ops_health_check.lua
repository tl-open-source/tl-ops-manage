-- tl_ops_health
-- en : health check core
-- zn : 健康检查实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson								= require("cjson.safe")
local tlog								= require("utils.tl_ops_utils_log"):new("tl_ops_health")
local tl_ops_utils_func					= require("utils.tl_ops_utils_func")
local tl_ops_constant_health			= require("constant.tl_ops_constant_health")
local tl_ops_status						= require("constant.tl_ops_constant_comm").tl_ops_status;
local tl_ops_health_check_dynamic_conf	= require("health.tl_ops_health_check_dynamic_conf")
local tl_ops_health_check_version		= require("health.tl_ops_health_check_version")
local nx_socket							= ngx.socket.tcp
local shared							= ngx.shared.tlopsbalance
local find								= ngx.re.find



local _M = {
	_VERSION = '0.02'
}
local mt = { __index = _M }

local tl_ops_health_check, 
tl_ops_health_check_main ,
tl_ops_health_check_get_lock,  
tl_ops_health_check_default_confs,
tl_ops_health_check_nodes,
tl_ops_health_check_node_failed,
tl_ops_health_check_node_ok;


function _M:new(options, services)
	return setmetatable({options = options, services = services}, mt)
end


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
	
	local timer_list = {};
	local timers_str = shared:get(tl_ops_constant_health.cache_key.timers)
	if timers_str then
		timer_list = cjson.decode(timers_str);
	end

	for index, conf in ipairs(confs) do
		local ok, _ = ngx.timer.at(0, tl_ops_health_check, conf)
		if not ok then
			tlog:err("tl_ops_health_check_start failed to run check , create timer failed " , _)
			return nil
		end

		table.insert(timer_list, conf.check_service_name)
	end

	shared:set(tl_ops_constant_health.cache_key.timers, cjson.encode(timer_list))

	tlog:dbg("tl_ops_health_check_start check end , timer_list=",timer_list)

	return true
end

-- 对给定配置内容进行初始化，对配置进行默认值给定和过滤
tl_ops_health_check_default_confs = function (options, services)
	local confs = tl_ops_utils_func:new_tab(#options, 0)
	
	tlog:dbg("tl_ops_health_check_default_confs start")

	for _, opt in pairs(options) do
		local check_content = opt.check_content
		if not check_content then
			tlog:err("tl_ops_health_check_default_confs invaild check_content")
			return nil
		end

		local check_timeout = opt.check_timeout
		if not check_timeout then 
			tlog:dbg("tl_ops_health_check_default_confs warp default check_timeout")
			check_timeout = 1000
		end

		local check_interval = opt.check_interval
		if not tonumber(check_interval) then
			tlog:dbg("tl_ops_health_check_default_confs warp default check_interval")
			check_interval = 1000
		else -- 最小 2ms
			if check_interval < 2 then  
				check_interval = 2
			end
		end
		check_interval = check_interval / 1000; 	-- 配置是ms格式, 使用是s格式

		local check_failed_max_count = opt.check_failed_max_count
		if not tonumber(check_failed_max_count) then
			tlog:dbg("tl_ops_health_check_default_confs warp default check_failed_max_count")
		    check_failed_max_count = 5
		end

		local check_success_max_count = opt.check_success_max_count
		if not tonumber(check_success_max_count) then
			tlog:dbg("tl_ops_health_check_default_confs warp default check_success_max_count")
		    check_success_max_count = 2
		end

		local check_service_name = opt.check_service_name
		if not check_service_name then
			tlog:err("tl_ops_health_check_default_confs warp default check_service_name nil")
			return nil
		end

		local check_success_status = opt.check_success_status
		if not check_success_status then
			check_success_status = {200}
		end

		local nodes = services[check_service_name]
		if not nodes then
			tlog:err("tl_ops_health_check_default_confs warp default nodes nil ")
			return nil
		end

		table.insert(confs, {
	        service_version = 0,		-- 当前conf对应的version
	        nodes = nodes,				-- 当前conf对应的service配置
			check_service_name = check_service_name,
	        check_content = check_content,
	        check_timeout = check_timeout,
			check_interval = check_interval,
			check_success_status = check_success_status,
	        check_failed_max_count = check_failed_max_count,
			check_success_max_count = check_success_max_count,
		})
	end

	tlog:dbg("tl_ops_health_check_default_confs end")

	return confs
end

-- 创建健康检查定时器
tl_ops_health_check = function(premature, conf)
	if premature then
		return
	end

	tlog:dbg("tl_ops_health_check start")

	local ok, _ = pcall(tl_ops_health_check_main, conf)
	if not ok then
		tlog:err("tl_ops_health_check failed to pcall : " ,  _)
	end

	local ok, _ = ngx.timer.at(conf.check_interval, tl_ops_health_check, conf)
	if not ok then
		tlog:err("tl_ops_health_check failed to create timer: " , _)
	end

	tlog:dbg("tl_ops_health_check end")
end

-- 健康检查主逻辑
tl_ops_health_check_main = function (conf)
	tlog:dbg("tl_ops_health_check_main start")

	--同步配置
	tl_ops_health_check_dynamic_conf.dynamic_conf_change_start( conf )

	-- 心跳包
	local lock_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.lock, conf.check_service_name)
    local lock_time = conf.check_interval - 0.01
    if tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
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


-- 对配置的路由机器依次发送心跳包
tl_ops_health_check_nodes = function (conf)
	local check_content = conf.check_content
	local check_timeout = conf.check_timeout
	local check_success_status = conf.check_success_status
	local nodes = conf.nodes

	tlog:dbg("tl_ops_health_check_nodes start" , ",nodes=",nodes)

	if nodes == nil then
		tlog:err("tl_ops_health_check_nodes nodes nil")
		return
	end

	for i = 1, #nodes do
		repeat
			local node = nodes[i]
			local node_id = i - 1
			local name = node.ip .. ":" .. node.port

			tlog:dbg("tl_ops_health_check_nodes start connect socket : name=", name)

			local sock, _ = nx_socket()
			if not sock then
				tlog:err("tl_ops_health_check_nodes failed to create stream socket: ", _)
				break
			end
			sock:settimeout(check_timeout)

			-- 心跳socket
			local ok, _ = sock:connect(node.ip, node.port)
			if not ok then
				tlog:err("tl_ops_health_check_nodes failed to connect socket: ", _)
				tl_ops_health_check_node_failed(conf, node_id, node)
				break; 
			end

			tlog:dbg("tl_ops_health_check_nodes connect socket ok : ok=", ok)

			local bytes, _ = sock:send(check_content .. "\r\n\r\n\r\n")
			if not bytes then
				tlog:err("tl_ops_health_check_nodes failed to send socket: ", _)
				tl_ops_health_check_node_failed(conf, node_id, node)
				break
			end

			tlog:dbg("tl_ops_health_check_nodes send socket ok : byte=", bytes)

			-- socket反馈
			local receive_line, _ = sock:receive()
			if not receive_line then
				if _ == "check_timeout" then
					tlog:err("tl_ops_health_check_nodes socket check_timeout: ", _)
					sock:close()
				end
				tl_ops_health_check_node_failed(conf, node_id, node)
				break
			end

			tlog:dbg("tl_ops_health_check_nodes receive socket ok : ", receive_line)

			local from, to, _ = find(receive_line, [[^HTTP/\d+\.\d+\s+(\d+)]], "joi", nil, 1)
			if not from then
				tlog:err("tl_ops_health_check_nodes ngx.re.find receive err: ", from, to, _)
				sock:close()
				tl_ops_health_check_node_failed(conf, node_id, node)
				break
			end

			-- 心跳状态
			local status = tonumber(string.sub(receive_line, from, to))

			tlog:dbg("tl_ops_health_check_nodes get status ok ,name=" ,name, ", status=" , status)
			local statusPass = false;
			for j = 1, #check_success_status do
				if check_success_status[j] == status then
					statusPass = true
				end
			end

			if statusPass == false then
				tlog:err("tl_ops_health_check_nodes status not pass ,name=" ,name, ", status=" , status)
				tl_ops_health_check_node_failed(conf, node_id, node)
				sock:close()
				break
			end

			-- 心跳成功
			tl_ops_health_check_node_ok(conf, node_id, node)

			tlog:dbg("tl_ops_health_check_nodes node ok")

			sock:close()
			break
		until true
	end

	tlog:dbg("tl_ops_health_check_nodes end ,conf=" , conf, ",nodes=",nodes)
end

-- 心跳检查失败
tl_ops_health_check_node_failed = function (conf, node_id, node)
	tlog:dbg("tl_ops_health_check_node_failed start ,conf=" , conf, ",node=" , node)

	local check_failed_max_count = conf.check_failed_max_count
	local check_service_name = conf.check_service_name

	-- key=tl_ops_health_check_failed_count:resin-site0 (health check not ok)
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, check_service_name, node_id)
	local cur_failed_count, _ = shared:get(key)

	tlog:dbg("tl_ops_health_check_node_failed failed key= " , key ,", cur_failed_count=" , cur_failed_count)

	if not cur_failed_count then
		cur_failed_count = 1
		local ok, _ = shared:set(key, cur_failed_count)
		if not ok then 
			tlog:err("tl_ops_health_check_node_failed failed to set node check_failed_max_count key: " , key)
		end
	else
		cur_failed_count = cur_failed_count + 1
		local ok, _ = shared:incr(key, 1)
		if not ok then
			tlog:err("tl_ops_health_check_node_failed failed to incr node check_failed_max_count key: "  , key)
		end
	end

	-- 心跳包失败后，重置之前有过累计的成功次数
	if cur_failed_count == 1 then
		key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, check_service_name, node_id)
		local succ, _ = shared:get(key)
		
		tlog:dbg("tl_ops_health_check_node_failed success key= " , key ,", succ_count=" , succ)

		if not succ or succ == 0 then
			tlog:err("tl_ops_health_check_node_failed failed to get node check_success_max_count key: " , key , " or check_success_max_count = 0")
		else
			local ok, _ = shared:set(key, 0)
			if not ok then
				tlog:err("tl_ops_health_check_node_failed failed to set node check_success_max_count key: " .. key)
			end
		end
	end

	-- 该机器当前状态:在线 && 心跳包失败次数 > 配置的次数，将shareDict中该机器的状态置为下线，
	-- {tl_ops_health_check_donw_state:resin-site0:true}
	if node.state and cur_failed_count > check_failed_max_count then
		local name =  node.ip .. ":" .. node.port

		tlog:dbg("tl_ops_health_check_node_failed failed count > max failed count , cur_failed_count=",cur_failed_count, ",ip=" .. node.ip .. ":" .. node.port) 

		key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, check_service_name, node_id)
		local ok, _ = shared:set(key, nil)
		if not ok then
			tlog:err("tl_ops_health_check_node_failed failed to set node down state:", _)
		end
		node.state = false
		
		conf.service_version = tl_ops_health_check_version.incr_service_version(check_service_name);

		tlog:dbg("tl_ops_health_check_node_failed conf.service_version=" , conf.service_version)
	end

	tlog:dbg("tl_ops_health_check_node_failed end ,node=" , node)

end

-- 心跳检查成功
tl_ops_health_check_node_ok = function (conf, node_id, node)
	tlog:dbg("tl_ops_health_check_node_ok start ,conf=" , conf, ",node=" , node)

	local shared = shared
	local check_success_max_count = conf.check_success_max_count
	local check_service_name = conf.check_service_name
	
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, check_service_name, node_id)
	local cur_success_count, _ = shared:get(key)

	tlog:dbg("tl_ops_health_check_node_ok success key= " , key ,", cur_success_count=" , cur_success_count)

	if not cur_success_count then
		cur_success_count = 1
		local ok, _ = shared:set(key, cur_success_count)
		if not ok then 
			tlog:err("tl_ops_health_check_node_ok failed to set node ok key: " , key)
		end
	else
		cur_success_count = cur_success_count + 1
		local ok, _ = shared:incr(key, 1)
		if not ok then
			tlog:err("tl_ops_health_check_node_ok failed to incr node ok key: "  , key)
		end
	end

	-- 心跳包成功后，重置之前有过累计的失败次数
	if cur_success_count == 1 then
		key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, check_service_name, node_id)
		local fails, _ = shared:get(key)

		tlog:dbg("tl_ops_health_check_node_ok success key= " , key , ",cur_success_count=", cur_success_count, ", check_failed_max_count=" , fails)

		if not fails or fails == 0 then
			if _ then
				tlog:err("tl_ops_health_check_node_ok failed to get node nok key: " , key)
			end
		else
			local ok, _ = shared:set(key, 0)
			if not ok then
				tlog:err("tl_ops_health_check_node_ok failed to set node nok key: " , key)
			end
		end
	end

	-- 该机器当前状态:下线 && 心跳包成功次数 > 配置的次数，将shareDict中该机器的状态置为上线，
	-- {tl_ops_health_check_donw_state:resin-site0:nil}
	if not node.state and cur_success_count >= check_success_max_count then
		local name = node.port .. ":" .. node.ip

		
		tlog:dbg("tl_ops_health_check_node_ok success count > max success count , state=",node.state," cur_success_count=",cur_success_count, ",ip=" .. node.ip .. ":" .. node.port) 

		key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, check_service_name, node_id)
		local ok, _ = shared:set(key, true)
		if not ok then
			tlog:err("tl_ops_health_check_node_ok failed to set node down state:", _)
		end
		node.state = true
		
		conf.service_version = tl_ops_health_check_version.incr_service_version(check_service_name);

		tlog:dbg("tl_ops_health_check_node_ok conf.service_version=" , conf.service_version)
	end

	tlog:dbg("tl_ops_health_check_node_ok end ,node=" , node)
end

return _M
