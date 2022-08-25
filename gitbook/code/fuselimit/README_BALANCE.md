
# 负载均衡流控

明白了上面的扩缩容，对于取用令牌桶的消费和漏桶的消费也是需要了解的。下面将对两种情况分别介绍

我们可以看到流控接入负载均衡逻辑是在负载核心逻辑中，依赖配置的限流器，选择对应的限流策略。


```lua
# 代码位置 : balance/tl_ops_balance_core.lua

-- 流控介入
local depend = tl_ops_balance_core_get_limiter(node.service, node_id)
if depend then
	-- 令牌桶流控
	if depend == tl_ops_constant_limit.depend.token then
		local token_result = tl_ops_limit_fuse_token_bucket.tl_ops_limit_token( node.service, node_id)
		if not token_result or token_result == false then
			ngx.header['Tl-Proxy-Server'] = "";
			ngx.header['Tl-Proxy-State'] = "t-limit"
			ngx.header['Tl-Proxy-Mode'] = balance_mode
			ngx.exit(503)
		end
	end

	-- 漏桶流控
	if depend == tl_ops_constant_limit.depend.leak then
		local leak_result = tl_ops_limit_fuse_leak_bucket.tl_ops_limit_leak( node.service, node_id)
		if not leak_result or leak_result == false then
			ngx.header['Tl-Proxy-Server'] = "";
			ngx.header['Tl-Proxy-State'] = "l-limit"
			ngx.header['Tl-Proxy-Mode'] = balance_mode
			ngx.exit(503)
		end
	end
end
```

## 令牌桶流控

令牌桶的实现思路之前我额外写过一些文章来讲解，这里就不细说了 具体可查看我的这篇文章  :fa-hand-o-right:  [令牌桶的实现思路](https://blog.iamtsm.cn/detail.html?id=36 "令牌桶的实现思路")

这里需要注意的是，实际令牌桶算法应该要在获取令牌时加锁，避免并发问题。tl-ops-manage 接入负载逻辑中的限流器，并未加锁，所以是允许少量请求并发获取的情况。如果对加锁能接受，可以自行补充锁即可。

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_token_bucket.lua

-- block 取用令牌数量
local tl_ops_limit_token = function( service_name, node_id )
    ...

    -- 取出令牌
    if token_bucket > block then
        local ok, _ = shared:incr(token_bucket_key, -block)
        if not ok then
            return false
        end

        return true
    end

    -- 距离上次填充时间差 * 生成速率 = 需要补充的令牌
    ngx.update_time()
    local cur_time = ngx.now()
    local duration_token_bucket = (cur_time - pre_time) * rate
    if duration_token_bucket <= 0 then
        return false
    end

    local new_token_bucket = math.min(token_bucket + duration_token_bucket, capacity)

    -- 令牌还是不够
    if new_token_bucket < block then
        local ok, _ = shared:set(token_bucket_key, new_token_bucket)
        if not ok then
            return false
        end

        local ok, _ = shared:set(pre_time_key, cur_time)
        if not ok then
            return false
        end

        return false
    end

    -- 移除一个令牌
    local ok, _ = shared:set(token_bucket_key, new_token_bucket - block)
    if not ok then
        return false
    end

    local ok, _ = shared:set(pre_time_key, cur_time)
    if not ok then
        return false
    end

    return true
end
```


## 漏桶流控

和令牌桶不同，漏桶的实现是依靠向外流出令牌的方式，他们的区别可以大致这么理解，`令牌桶是从桶中拿令牌，拿到令牌后执行请求`，`漏桶是将请求当成令牌，一个一个放入桶`。

同令牌桶一致，漏桶限流器也未加锁。需要可自行补充

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_leak_bucket.lua

-- block 取用漏桶数量
local tl_ops_limit_leak = function( service_name, node_id )

    ...

    -- 当前堆积量
    local leak_bucket_key = tl_ops_utils_func:gen_node_key(leak_mode.cache_key.leak_bucket, service_name, node_id)
    local leak_bucket, _ = shared:get(leak_bucket_key)
    if not leak_bucket then
        local res, _ = shared:set(leak_bucket_key, 0)
        if not res then
            return false
        end
        leak_bucket = 0
    end

    -- 漏桶当前可堆积请求量 = 当前堆积量 - (在此时间区间应该被漏出的请求量) 
    -- ==
    -- 漏桶当前可堆积请求量 = 当前堆积量 - (距离上次时间差 * 漏出速率)
    ngx.update_time()
    local cur_time = ngx.now()
    local lave_leak_bucket = math.max(leak_bucket - (cur_time - pre_time) * rate, 0)

    -- 溢出
    if lave_leak_bucket + block > capacity then
        return false
    end

    local new_leak_bucket = math.min(capacity, lave_leak_bucket + block)
    local ok, _ = shared:set(leak_bucket_key, new_leak_bucket)
    if not ok then
        return false
    end

    local ok, _ = shared:set(pre_time_key, cur_time)
    if not ok then
        return false
    end

    return true
end
```

