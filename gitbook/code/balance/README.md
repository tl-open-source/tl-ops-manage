# 负载均衡

负载均衡的实现是本身nginx是支持配置多种轮询机制的，如权重，随机，备份等。tl-ops-manage提供的负载策略是更加细化的负载。目前支持几种策略 `api最长前缀正则匹配负载`，`cookie键值对匹配负载`，`请求参数键值对匹配负载`，`请求头部键值对匹配负载`，以及每种策略下支持两种模式的动态切换，`指定节点负载` ，`随机节点负载`。

    在服务节点列表中，所有节点是依赖健康检查动态上下线。上线节点加入负载列表，下线节点剔除负载列表。在负载列表中的所有有效节点，将被用作根据负载策略进行负载。

## 规则预热

对于负载逻辑而言，其核心在于规则的匹配，负载作为流量的入口，应该保持高性能，所以规则的加载和匹配不能阻塞请求的分发，在tl-ops-manage中，由于数据都是存在store文件, (或者自定义存储中)。在实际启动后，对于数据的加载每次都要访问磁盘IO，对性能会有极大的影响，所以tl-ops-manage提供了数据同步和预热功能，只需开启 `sync` 插件即可。

    开启后会在启动时执行一次数据同步，并将磁盘数据加载进入shared:dict共享内存中。


## 负载规则

#### V2.7.2版本之前

通过下面代码，我们可以看到主入口是放置在 conf 文件中的，通过设置一个节点变量 `node` 在 `access_by_lua_block` 阶段执行balance逻辑后，得到具体的`node`值，从而通过`proxy_pass`转发到具体节点。

```lua
# 代码位置 : conf/tl_ops_manage.conf

location / {
	...
    set $node '';
    access_by_lua_block {
        tlops:tl_ops_process_init_access();
    }
    proxy_pass $node;
}

# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init_access()
    -- 加载api
    m_api:init();

    -- 启动负载均衡
    m_balance:init();
    
    ...
end

```

#### V2.7.2版本之后

通过下面代码，我们可以看到主入口是放置在 conf 文件中的，通过在 `tl_ops_process_init_rewrite` 阶段执行filter逻辑后，得出可用的节点，再通过  `balance_by_lua_block` 阶段中执行balance逻辑通过`set_current_peer`转发到具体节点。

```lua
# 代码位置 : conf/tl_ops_manage.conf

upstream tlopsmanage {
	server 0.0.0.0;
	balancer_by_lua_block {
		tlops:tl_ops_process_init_balancer();
	}
	keepalive 1024;
}
location / {
    ...

    proxy_pass http://tlopsmanage;
    
    ...
}


# 代码位置 : tl_ops_manage.lua


function _M:tl_ops_process_init_rewrite()
    ...

    -- 负载均衡筛选
    m_balance:filter(ngx.ctx);
    
    ...
end

function _M:tl_ops_process_init_balancer()
    ...

    -- 负载均衡请求分发
    m_balance:init(ngx.ctx);
    
    ...
end

```


接下来，我们看回负载核心逻辑代码 : `tl_ops_balance_core_filter`，可以看到先获取当前所有服务节点，然后根据负载策略依次匹配，直到命中规则，得到具体节点。得到具体节点后，通过ctx保存节点，然后在balance阶段转发到具体节点

策略匹配顺序为 ： `api策略 > 请求参数策略 > 请求cookie策略 > 请求头策略 `。

匹配到具体规则后，转而匹配域名，如果域名匹配也命中，说明当前请求应该被此条规则所配置的节点处理。

    当前在实际负载前，应该要考虑当前节点所配置的流控策略，在流控限制下，如果能拿到令牌或正常留出漏桶，说明当前请求已经被允许转发到上游服务了，当然，如果此时，服务状态不佳，不能正常处理请求，那么就无需转发请求，直接丢弃即可。


```lua
# 代码位置 : balance/tl_ops_balance_core.lua


-- 负载节点过滤筛选
function _M:tl_ops_balance_core_filter(ctx)
    -- 服务节点配置列表
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str then
        tl_ops_err_content:err_content_rewrite_to_balance("", "empty", "", tl_ops_constant_balance.cache_key.service_empty)
        return
    end
    local service_list_table = cjson.decode(service_list_str);
    if not service_list_table and type(service_list_table) ~= 'table' then
        tl_ops_err_content:err_content_rewrite_to_balance("", "empty", "", tl_ops_constant_balance.cache_key.service_empty)
        return
    end

    -- 负载模式
    local balance_mode = "api"

    -- 先走api负载
    local node, node_state, node_id, host = tl_ops_balance_core_api.tl_ops_balance_api_service_matcher(service_list_table)
    if not node then
        -- api不匹配，走param负载
        balance_mode = "param"

        node, node_state, node_id, host = tl_ops_balance_core_param.tl_ops_balance_param_service_matcher(service_list_table)
        if not node then
            -- param不匹配，走cookie负载
            balance_mode = "cookie"

            node, node_state, node_id, host = tl_ops_balance_core_cookie.tl_ops_balance_cookie_service_matcher(service_list_table)
            if not node then
                -- cookie不匹配，走header负载
                balance_mode = "header"

                node, node_state, node_id, host = tl_ops_balance_core_header.tl_ops_balance_header_service_matcher(service_list_table)
                if not node then
                    -- 无匹配
                    tl_ops_err_content:err_content_rewrite_to_balance("", "empty", balance_mode, tl_ops_constant_balance.cache_key.mode_empty)
                    return
                end
            end
        end
    end

    -- 域名负载
    if host == nil or host == '' then
        tl_ops_err_content:err_content_rewrite_to_balance("", "nil", balance_mode, tl_ops_constant_balance.cache_key.host_empty)
        return
    end

    -- 域名匹配
    if host ~= "*" and host ~= ngx.var.host then
        tl_ops_err_content:err_content_rewrite_to_balance("", "pass", balance_mode, tl_ops_constant_balance.cache_key.host_pass)
        return
    end

    -- 流控介入
    if tl_ops_manage_env.balance.limiter then
        local depend = tl_ops_limit.tl_ops_limit_get_limiter(node.service, node_id)
        if depend then
            -- 令牌桶流控
            if depend == tl_ops_constant_limit.depend.token then
                local token_result = tl_ops_limit_fuse_token_bucket.tl_ops_limit_token( node.service, node_id)  
                if not token_result or token_result == false then
                    balance_count:tl_ops_balance_count_incr_fail(node.service, node_id)
                    tl_ops_err_content:err_content_rewrite_to_balance("", "t-limit", balance_mode, tl_ops_constant_balance.cache_key.token_limit)
                    return
                end
            end
    
            -- 漏桶流控 
            if depend == tl_ops_constant_limit.depend.leak then
                local leak_result = tl_ops_limit_fuse_leak_bucket.tl_ops_limit_leak( node.service, node_id)
                if not leak_result or leak_result == false then
                    balance_count:tl_ops_balance_count_incr_fail(node.service, node_id)
                    tl_ops_err_content:err_content_rewrite_to_balance("", "l-limit", balance_mode, tl_ops_constant_balance.cache_key.leak_limit)
                    return
                end
            end
        end
    end

    -- 服务层waf
    waf:init_service(node.service);

    -- 节点下线
    if not node_state or node_state == false then
        balance_count:tl_ops_balance_count_incr_fail(node.service, node_id)

        local limit_req_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail, node.service, node_id)
        local failed_count = shared:get(limit_req_fail_count_key)
		if not failed_count then
			shared:set(limit_req_fail_count_key, 0);
        end
        shared:incr(limit_req_fail_count_key, 1)
        
        tl_ops_err_content:err_content_rewrite_to_balance(node.service .. ":" .. node.name, "offline", balance_mode, tl_ops_constant_balance.cache_key.offline)
        return
    end

    ctx.tlops_ups_node = node
    ctx.tlops_ups_node_id = node_id
    ctx.tlops_ups_mode = balance_mode

    return
end




-- 请求负载分发
function _M:tl_ops_balance_core_balance(ctx)

    local tlops_ups_mode = ctx.tlops_ups_mode
    local tlops_ups_node = ctx.tlops_ups_node
    local tlops_ups_node_id = ctx.tlops_ups_node_id

    if not tlops_ups_mode or not tlops_ups_node or not tlops_ups_node_id then
        return
    end

    -- 负载成功
    balance_count:tl_ops_balance_count_incr_succ(tlops_ups_node.service, tlops_ups_node_id)

    local limit_req_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, tlops_ups_node.service, tlops_ups_node_id)
    local success_count = shared:get(limit_req_succ_count_key)
    if not success_count then
        shared:set(limit_req_succ_count_key, 0);
    end
    shared:incr(limit_req_succ_count_key, 1)

    ngx.header['Tl-Proxy-Server'] = tlops_ups_node.service .. ":" .. tlops_ups_node.name;
    ngx.header['Tl-Proxy-State'] = "online"
    ngx.header['Tl-Proxy-Mode'] = tlops_ups_mode

    local ok, err = ngx_balancer.set_current_peer(tlops_ups_node.ip, tlops_ups_node.port)
    if ok then
        ngx_balancer.set_timeouts(3, 60, 60)
    end
end


```

需要注意的点，负载中出现的各种情况都有对应的返回码，需要自行配置，以上就是负载核心思路，下面我将对不同策略以及每种策略下的不同模式进行说明
