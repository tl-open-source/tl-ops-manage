# 心跳包

在介绍实现之前，首先有必要铺垫一下openresty的执行阶段相关知识。

由于nginx在启动时是多woker进程来处理请求，而openresty将nginx处理请求分为七个阶段。

 ![图片](https://qnproxy.iamtsm.cn/20190112153020353.png "图片")


健康检查的启动应与请求阶段无关，所以应该放在 `init_by_lua`阶段或者`init_worker_by_lua`阶段较为合适，但是定时器的生命周期只能在`init_worker_by_lua`阶段（如下图），所以健康检查的启动器就应在`init_worker_by_lua`阶段来做。

 ![图片](https://qnproxy.iamtsm.cn/c60e698ec50f369cd9a3451be14c8bf.png "图片")

由于`init_worker_by_lua`阶段是初始化worker进程阶段，所以在此阶段是存在多个worker进程，也就是可能存在抢占执行定时器的情况。而每个定时器有其依赖的配置，多个worker之间数据不共享，就会导致健康检查数据统计、配置不一致的情况。

 ![图片](https://qnproxy.iamtsm.cn/89488d01acdad5b5f31f7a3b3a98332.png "图片")


所以才会有这样一段逻辑，`tl_ops_health_check_get_lock`对应的就是加锁逻辑，主要方式是通过  `ngx.shared` 共享内存来实现，有兴趣可以查看下具体实现代码，这里就不细讲了。

```lua
---- 心跳包

if tl_ops_health_check_get_lock(conf) then
	tl_ops_health_check_nodes(conf)
end

```

我们继续看回代码，在抢占锁后，只会有一个worker进程进入锁内，并执行 `tl_ops_health_check_nodes`，进行发送心跳包。

对于发送心跳包，我们可以看到是对 `服务-节点` 依次进行遍历发送socket包（心跳包内容自定义），如心跳周期正常结束，进入 `tl_ops_health_check_node_ok` 成功逻辑，否则进入`tl_ops_health_check_node_failed` 失败逻辑


```lua
# 代码位置 : health/tl_ops_health_check.lua


-- 对配置的路由机器依次发送心跳包
tl_ops_health_check_nodes = function (conf)

	...

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

			local from, to, _ = ngx.re.find(receive_line, [[^HTTP/\d+\.\d+\s+(\d+)]], "joi", nil, 1)
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
```


## 心跳成功

心跳成功之后，会累加成功的次数，并清空之前累加的失败次数，当成功累加达到一定的次数后，认为该节点可以用于正常处理请求，即可将改节点状态变更为 `上线节点`，由此该节点就可以用于请求路由负载节点中

```lua
# 代码位置 : health/tl_ops_health_check.lua

-- 心跳检查成功
tl_ops_health_check_node_ok = function (conf, node_id, node)
	tlog:dbg("tl_ops_health_check_node_ok start ,conf=" , conf, ",node=" , node)

	local shared = shared
	local check_success_max_count = conf.check_success_max_count
	local check_service_name = conf.check_service_name
	
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, check_service_name, node_id)
	local cur_success_count, _ = shared:get(key)

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

		key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, check_service_name, node_id)
		local ok, _ = shared:set(key, true)
		if not ok then
			tlog:err("tl_ops_health_check_node_ok failed to set node down state:", _)
		end
		node.state = true

		...

	end

	tlog:dbg("tl_ops_health_check_node_ok end ,node=" , node)
end
```


## 心跳失败

心跳失败之后，会累加失败的次数，并清空之前累加的成功次数，当失败累加达到一定的次数后，认为该节点不可以用于正常处理请求，即可将改节点状态变更为 `下线节点`，由此该节点就应该剔除在正常服务中，就不能用于路由负载使用


```lua
# 代码位置 : health/tl_ops_health_check.lua

-- 心跳检查失败
tl_ops_health_check_node_failed = function (conf, node_id, node)
	tlog:dbg("tl_ops_health_check_node_failed start ,conf=" , conf, ",node=" , node)

	local check_failed_max_count = conf.check_failed_max_count
	local check_service_name = conf.check_service_name

	-- key=tl_ops_health_check_failed_count:resin-site0 (health check not ok)
	local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, check_service_name, node_id)
	local cur_failed_count, _ = shared:get(key)

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

		key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, check_service_name, node_id)
		local ok, _ = shared:set(key, nil)
		if not ok then
			tlog:err("tl_ops_health_check_node_failed failed to set node down state:", _)
		end
		node.state = false

		...

	end

	tlog:dbg("tl_ops_health_check_node_failed end ,node=" , node)

end

```

