-- tl_ops_health
-- en : health check core
-- zn : 健康检查实现
-- @author iamtsm
-- @email 1905333456@qq.com

local ngx = require("ngx")
local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_heath");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local cache = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_status = require("constant.tl_ops_constant_comm").tl_ops_status;
local nx_socket = ngx.socket.tcp


local _M = {}
_M._VERSION = '0.01'
local mt = { __index = _M }



local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end


function _M:new(options, services)
	return setmetatable({options = options, services = services}, mt)
end



local tl_ops_heath_check, 
tl_ops_heath_check_main ,
tl_ops_heath_check_get_lock,  
tl_ops_heath_check_default_confs,
tl_ops_heath_check_service_version,
tl_ops_heath_check_peers_state,
tl_ops_heath_check_peers,
tl_ops_heath_check_peer_failed,
tl_ops_heath_check_peer_ok,
tl_ops_heath_check_sync_state;



---- 创建健康检查主入口
function _M:tl_ops_heath_start()
	if not self.options then
		tlog:err("tl_ops_heath_start failed to run check , options nil");
		return nil
	end

	tlog:dbg("tl_ops_heath_start options ok ")

	local confs, err = tl_ops_heath_check_default_confs(self.options, self.services)
	if not confs then
		tlog:err("tl_ops_heath_start failed to run check , confs nil")
		return nil
	end

	tlog:dbg("tl_ops_heath_start check conf ok")

	for _, conf in ipairs(confs) do
		---- 保证每次启动检查的时候dict旧数据被清空
		conf.shared:flush_all()
		conf.shared:flush_expired()

		local ok, err = ngx.timer.at(0, tl_ops_heath_check, conf)
		if not ok then
			tlog:err("tl_ops_heath_start failed to run check , create timer failed " ,err)
			return nil
		end

		tlog:dbg("tl_ops_heath_start ngx time at conf ok : conf=", conf)

	end

	tlog:dbg("tl_ops_heath_start check end")

	return true
end

---- 创建健康检查定时器
tl_ops_heath_check = function(premature, conf)
	if premature then
		return
	end

	tlog:dbg("tl_ops_heath_check start : conf=", conf)

	local ok, err = pcall(tl_ops_heath_check_main, conf)
	if not ok then
		tlog:err("tl_ops_heath_check failed to pcall : " ,  err)
	end

	tlog:dbg("tl_ops_heath_check pcall ok")

	local ok, err = ngx.timer.at(conf.check_interval, tl_ops_heath_check, conf)
	if not ok then
		tlog:err("tl_ops_heath_check failed to create timer: " , err)
	end

	tlog:dbg("tl_ops_heath_check end : conf=", conf)
end

---- 健康检查主逻辑
tl_ops_heath_check_main = function (conf)
	tlog:dbg("tl_ops_heath_check_main start")

	---- 同步更新所有worker进程中的conf
	tl_ops_heath_check_service_version(conf)

	---- 抢锁成功，开始发送心跳包，检查所有service中的peer的state
	if tl_ops_heath_check_get_lock(conf) then
		tl_ops_heath_check_peers(conf)
	end

	tlog:dbg("tl_ops_heath_check_main end")
end

---- 只允许一个work进行执行, 抢到锁的执行
tl_ops_heath_check_get_lock = function(conf)
	local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.lock,conf.check_service_name)

	tlog:dbg("tl_ops_heath_check_get_lock start : key=", key)

	local ok, err = conf.shared:add(key, true, conf.check_interval - 0.01)
	if not ok then
		if err == "exists" then
			tlog:dbg("tl_ops_heath_check_get_lock key exists : key=", key)
			return nil
		end
		tlog:err("tl_ops_heath_check_get_lock failed to add key, get lock failed, key=" ,key)
		return nil
	end
	
	tlog:dbg("tl_ops_heath_check_get_lock done : key=", key, ",check_service_name=" , conf.check_service_name)

	return true
end

---- 对配置内容进行初始化，给worker进程使用
tl_ops_heath_check_default_confs = function (options, services)
	local confs = new_tab(#options, 0)
	
	tlog:dbg("tl_ops_heath_check_default_confs start : options=", options, ",services=" , services)

	for _, opt in pairs(options) do
		local shared = ngx.shared.tlopsbalance
		if not shared then
			tlog:err("tl_ops_heath_check_default_confs warp default shared nil")
		    return nil
		end

		local check_content = opt.check_content
		if not check_content then
			tlog:err("tl_ops_heath_check_default_confs invaild check_content")
			return nil
		end

		local check_timeout = opt.check_timeout
		if not check_timeout then 
			tlog:dbg("tl_ops_heath_check_default_confs warp default check_timeout")
			check_timeout = 1000
		end

		local check_interval = opt.check_interval
		if not tonumber(check_interval) then
			tlog:dbg("tl_ops_heath_check_default_confs warp default check_interval")
			check_interval = 1000
		else ---- 最小 2ms
			if check_interval < 2 then  
				check_interval = 2
			end
		end
		check_interval = check_interval / 1000; 	---- 配置是ms格式, 使用是s格式

		local check_failed_max_count = opt.check_failed_max_count
		if not tonumber(check_failed_max_count) then
			tlog:dbg("tl_ops_heath_check_default_confs warp default check_failed_max_count")
		    check_failed_max_count = 5
		end

		local check_success_max_count = opt.check_success_max_count
		if not tonumber(check_success_max_count) then
			tlog:dbg("tl_ops_heath_check_default_confs warp default check_success_max_count")
		    check_success_max_count = 2
		end

		local check_service_name = opt.check_service_name
		if not check_service_name then
			tlog:err("tl_ops_heath_check_default_confs warp default check_service_name nil")
			return nil
		end

		local peers = services[check_service_name]
		if not peers then
			tlog:err("tl_ops_heath_check_default_confs warp default peers nil ")
			return nil
		end

		table.insert(confs, {
	        shared = shared,	---- 共享内存块
	        service_version = 0,		---- 当前conf对应的version
	        peers = peers,		---- 当前conf对应的service配置
			check_service_name = check_service_name,
	        check_content = check_content,
	        check_timeout = check_timeout,
	        check_interval = check_interval,
	        check_failed_max_count = check_failed_max_count,
	        check_success_max_count = check_success_max_count,
		}
		)
	end

	tlog:dbg("tl_ops_heath_check_default_confs end : confs=", confs)

	return confs
end

--[[
	由于ngx是多worker进程，启动health-check时，每一个worker都读取了一份配置在各自进程中。
	发送心跳包的过程中，单worker对自己进程内的service会存在更新，同时需要更新到shareDict中该service的版本。
	其他worker进程通过shareDict共享内存来获取service版本，如果版本大于自己的版本，
	那么说明当前的worker进程需要更新自己内存中的service的状态

	key = tl_ops_heath_check_version_service1 (health check version)
	对应在shared中的格式 {tl_ops_heath_check_version_service1:0} 0代表版本号，递增
]]
tl_ops_heath_check_service_version = function(conf)
	local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.version,conf.check_service_name)
	local service_version, err = conf.shared:get(key)

	tlog:dbg("tl_ops_heath_check_service_version start : key=", key, ",service_version=",service_version , ",conf.service_version=",conf.service_version)

	if not service_version then
		tlog:dbg("tl_ops_heath_check_service_version first check service_version: ", err)

		local ok ,err = conf.shared:add(key, 0)
		if not ok then
			tlog:err("tl_ops_heath_check_main failed to init service_version key in lock:" , err)
		end
	elseif service_version > conf.service_version then

		tl_ops_heath_check_peers_state(conf)

		tlog:dbg("tl_ops_heath_check_service_version service_version > conf.service_version , service_version=", service_version, "conf.service_version=",conf.service_version)

		conf.service_version = service_version
	end

	tlog:dbg("tl_ops_heath_check_service_version end : key=", key, ",conf=" , conf)
end

--[[
	key=tl_ops_heath_check_donw_state_service1 (health check down state), peer_id代表配置中设置的负载机器数组的下标
	对应在dict中的格式 {tl_ops_heath_check_donw_state_service1:true} true代表机器状态在线，false则下线
]]
tl_ops_heath_check_peers_state = function (conf)
	tlog:dbg("tl_ops_heath_check_peers_state start")

	local peers = conf.peers;
	for i = 1, #peers do
		local peer_id = i - 1

		local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.state, conf.check_service_name, peer_id)
		local res, err = conf.shared:get(key)

		tlog:dbg("tl_ops_heath_check_peers_state peer state=",res)

		if not res then
			peers[i].state = false
		else
			peers[i].state = true
		end
	end

	tlog:dbg("tl_ops_heath_check_peers_state end")
end

---- 对配置的负载机器依次发送心跳包
tl_ops_heath_check_peers = function (conf)
	local check_content = conf.check_content
	local check_timeout = conf.check_timeout
	local peers = conf.peers

	tlog:dbg("tl_ops_heath_check_peers start" , ",peers=",peers , ",#peers=", #peers)

	for i = 1, #peers do
		local peer = peers[i]
		local peer_id = i - 1
		local name = peer.ip .. ":" .. peer.port

		tlog:dbg("tl_ops_heath_check_peers start connect socket : name=", name)

		local sock, err = nx_socket()
		if not sock then
			tlog:err("tl_ops_heath_check_peers failed to create stream socket: ", err)
			return
		end
		sock:settimeout(check_timeout)

		---- 心跳socket
		local ok, err = sock:connect(peer.ip, peer.port)
		if not ok then
			tlog:err("tl_ops_heath_check_peers failed to connect socket: ", err)
			return tl_ops_heath_check_peer_failed(conf, peer_id, peer)
		end

		tlog:dbg("tl_ops_heath_check_peers connect socket ok : ok=", ok)

		local bytes, err = sock:send(check_content)
		if not bytes then
			tlog:err("tl_ops_heath_check_peers failed to send socket: ", err)
			tl_ops_heath_check_peer_failed(conf, peer_id, peer)
			return
		end

		tlog:dbg("tl_ops_heath_check_peers send socket ok : byte=", bytes)

		---- socket反馈
		local receive_line, err = sock:receive()
		if not receive_line then
			if err == "check_timeout" then
				tlog:err("tl_ops_heath_check_peers socket check_timeout: ", err)
				sock:close()
			end
			tl_ops_heath_check_peer_failed(conf, peer_id, peer)
			return
		end

		tlog:dbg("tl_ops_heath_check_peers receive socket ok : ", receive_line)

		local from, to, err = ngx.re.find(receive_line, [[^HTTP/\d+\.\d+\s+(\d+)]], "joi", nil, 1)
		if not from then
			tlog:err("tl_ops_heath_check_peers ngx.re.find receive err: ", from, to, err)
			sock:close()
			tl_ops_heath_check_peer_failed(conf, peer_id, peer)
			return
		end

		---- 心跳状态
		local status = tonumber(string.sub(receive_line, from, to))

		tlog:dbg("tl_ops_heath_check_peers get status ok ,name=" ,name, ", status=" , status)

		if status ~= 200 then
			tlog:err("tl_ops_heath_check_peers status ~= 200: ")
			tl_ops_heath_check_peer_failed(conf, peer_id, peer)
			sock:close()
			return
		end

		---- 心跳成功
		tl_ops_heath_check_peer_ok(conf, peer_id, peer)

		tlog:dbg("tl_ops_heath_check_peers peer ok")

		sock:close()
	end

	tlog:dbg("tl_ops_heath_check_peers end ,conf=" , conf, ",peers=",peers)
end

----- 心跳失败
tl_ops_heath_check_peer_failed = function (conf, peer_id, peer)
	tlog:dbg("tl_ops_heath_check_peer_failed start ,conf=" , conf, ",peer=" , peer)

	local check_failed_max_count = conf.check_failed_max_count
	local check_service_name = conf.check_service_name

	---- key=tl_ops_heath_check_failed_count:resin-site0 (health check not ok)
	local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.failed, check_service_name, peer_id)
	local cur_failed_count, err = conf.shared:get(key)

	tlog:dbg("tl_ops_heath_check_peer_failed failed key= " , key ,", cur_failed_count=" , cur_failed_count)

	if not cur_failed_count then
		cur_failed_count = 1
		local ok, err = conf.shared:set(key, cur_failed_count)
		if not ok then 
			tlog:err("tl_ops_heath_check_peer_failed failed to set peer check_failed_max_count key: " , key)
		end
	else
		cur_failed_count = cur_failed_count + 1
		local ok, err = conf.shared:incr(key, 1)
		if not ok then
			tlog:err("tl_ops_heath_check_peer_failed failed to incr peer check_failed_max_count key: "  , key)
		end
	end

	---- 心跳包失败后，重置之前有过累计的成功次数
	if cur_failed_count == 1 then
		key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.success, check_service_name, peer_id)
		local succ, err = conf.shared:get(key)
		
		tlog:dbg("tl_ops_heath_check_peer_failed success key= " , key ,", succ_count=" , succ)

		if not succ or succ == 0 then
			tlog:err("tl_ops_heath_check_peer_failed failed to get peer check_success_max_count key: " , key , " or check_success_max_count = 0")
		else
			local ok, err = conf.shared:set(key, 0)
			if not ok then
				tlog:err("tl_ops_heath_check_peer_failed failed to set peer check_success_max_count key: " .. key)
			end
		end
	end

	---- 该机器当前状态:在线 && 心跳包失败次数 > 配置的次数，将shareDict中该机器的状态置为下线，
	---- {tl_ops_heath_check_donw_state:resin-site0:true}
	if peer.state and cur_failed_count > check_failed_max_count then
		local name =  peer.ip .. ":" .. peer.port

		tlog:dbg("tl_ops_heath_check_peer_failed failed count > max failed count , cur_failed_count=",cur_failed_count, ",ip=" .. peer.ip .. ":" .. peer.port) 

		key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.state, check_service_name, peer_id)
		local ok, err = conf.shared:set(key, nil)
		if not ok then
			tlog:err("tl_ops_heath_check_peer_failed failed to set peer down state:", err)
		end
		peer.state = false

		---- 更新当前service的状态版本，用于通知其他worker进程同步最新peer的state
		local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.version,conf.check_service_name)
		local service_version, err = conf.shared:get(key)
		if not service_version then
			service_version, err = conf.shared:add(key, 1);
			if not service_version then 
				tlog:err("tl_ops_heath_check_main failed to publish new service_version:" , err)
			end
		else 
			service_version, err = conf.shared:incr(key, 1);
			if not service_version then 
				tlog:err("tl_ops_heath_check_main failed to publish new service_version:" , err)
			end
		end
		
		conf.service_version = service_version;

		tlog:dbg("tl_ops_heath_check_peer_failed conf.service_version=" , conf.service_version)
	end

	tlog:dbg("tl_ops_heath_check_peer_failed end ,peer=" , peer)

end

---- 心跳成功
tl_ops_heath_check_peer_ok = function (conf, peer_id, peer)
	tlog:dbg("tl_ops_heath_check_peer_ok start ,conf=" , conf, ",peer=" , peer)

	local shared = conf.shared
	local check_success_max_count = conf.check_success_max_count
	local check_service_name = conf.check_service_name
	
	local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.success, check_service_name, peer_id)
	local cur_success_count, err = shared:get(key)

	tlog:dbg("tl_ops_heath_check_peer_ok success key= " , key ,", cur_success_count=" , cur_success_count)

	if not cur_success_count then
		cur_success_count = 1
		local ok, err = shared:set(key, cur_success_count)
		if not ok then 
			tlog:err("tl_ops_heath_check_peer_ok failed to set peer ok key: " , key)
		end
	else
		cur_success_count = cur_success_count + 1
		local ok, err = shared:incr(key, 1)
		if not ok then
			tlog:err("tl_ops_heath_check_peer_ok failed to incr peer ok key: "  , key)
		end
	end

	---- 心跳包成功后，重置之前有过累计的失败次数
	if cur_success_count == 1 then
		key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.failed, check_service_name, peer_id)
		local fails, err = shared:get(key)

		tlog:dbg("tl_ops_heath_check_peer_ok success key= " , key , ",cur_success_count=", cur_success_count, ", check_failed_max_count=" , fails)

		if not fails or fails == 0 then
			if err then
				tlog:err("tl_ops_heath_check_peer_ok failed to get peer nok key: " , key)
			end
		else
			local ok, err = shared:set(key, 0)
			if not ok then
				tlog:err("tl_ops_heath_check_peer_ok failed to set peer nok key: " , key)
			end
		end
	end

	---- 该机器当前状态:下线 && 心跳包成功次数 > 配置的次数，将shareDict中该机器的状态置为上线，
	---- {tl_ops_heath_check_donw_state:resin-site0:nil}
	if not peer.state and cur_success_count >= check_success_max_count then
		local name = peer.port .. ":" .. peer.ip
		
		tlog:dbg("tl_ops_heath_check_peer_ok success count > max success count , cur_success_count=",cur_success_count, ",ip=" .. peer.ip .. ":" .. peer.port) 

		key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.state, check_service_name, peer_id)
		local ok, err = shared:set(key, true)
		if not ok then
			tlog:err("tl_ops_heath_check_peer_ok failed to set peer down state:", err)
		end
		peer.state = true
		
		---- 更新当前service的状态版本，用于通知其他worker进程同步最新peer的state
		local key = tl_ops_utils_func:gen_peer_key(tl_ops_constant_health.cache_key.version,conf.check_service_name)
		local service_version, err = conf.shared:get(key)
		if not service_version then
			service_version, err = conf.shared:add(key, 1);
			if not service_version then 
				tlog:err("tl_ops_heath_check_main failed to publish new service_version:" , err)
			end
		else 
			service_version, err = conf.shared:incr(key, 1);
			if not service_version then 
				tlog:err("tl_ops_heath_check_main failed to publish new service_version:" , err)
			end
		end
		
		conf.service_version = service_version;

		tlog:dbg("tl_ops_heath_check_peer_ok conf.service_version=" , conf.service_version)
	end

	tlog:dbg("tl_ops_heath_check_peer_ok end ,peer=" , peer)
end


return _M
