
# 动态限流器

在处理完节点/服务的状态时，会并行处理限流器的扩缩容。因为要想做到服务升降级，从而减少进入服务节点的流量，限流器是不可缺少的一部分。而要想要限流器做到随着服务升降级而动态进行限流。就需要用到动态扩缩容的概念

在tl-ops-manage中，我提供了两种限流算法，并整合了这两种算法到熔断逻辑中，我称之为熔断限流器，目前有 `令牌桶限流器`，`漏桶限流器`。下面我着重说明下两种限流器的扩缩容实现和整合

## 令牌桶限流器

### 令牌桶扩容

我们知道令牌桶是一个容器，之所以它能实现限流，是因为他有最大最小边界值，我们假设桶最大容量为`capacity`， 那么令牌数量的范围就是 `[0, capacity]`，在某一时刻，这里我们假定容量为  `[0, capacity/2]`，也就是服务处理请求的能力将下降一半，发生扩容后，能够存放令牌的数量将变为 `[0, (capacity/2) * 扩容比例]`

下面我们看具体实现代码，可以看到首先从shared中拿出 capacity，判定是否在合法值内，如果是，再拿到扩容比例，将其扩容，

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_token_bucket_.lua

-- 扩容 熔断定时器中保证锁，所以这里不加锁
local tl_ops_limit_token_expand = function( service_name, node_id )

    local token_mode = tl_ops_limit_token_mode( service_name, node_id)

    local capacity_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.capacity, service_name, node_id)
    local capacity = shared:get(capacity_key)
    if not capacity then
        local res, _ = shared:set(capacity_key, token_mode.options.capacity)
        if not res then
            return false
        end
        capacity = token_mode.options.capacity
    end

    if capacity <= 1 then
        return false
    end

    local expand_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.expand, service_name, node_id)
    local expand = shared:get(expand_key)
    if not expand then
        local res, _ = shared:set(expand_key, token_mode.options.expand)
        if not res then
            return false
        end
        expand = token_mode.options.expand
    end

    -- 扩容量 = 当前桶容量 * 比例
    local expand_capacity = capacity * expand

    local capacity_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.capacity, service_name, node_id)
    local res ,_ = shared:incr(capacity_key, expand_capacity)
    if not res or res == false then
        return false
    end

    return true
end
```


### 令牌桶缩容

明白了，上面的的扩容，自然也就能明白缩容了，只是将扩容的值补充负号即可。部分代码如下


```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_token_bucket_.lua

-- 缩容量 = -当前桶容量 * 比例
local shrink_capacity = capacity * shrink

local res ,_ = shared:incr(capacity_key, -shrink_capacity)
if not res or res == false then
	return false
end
```

## 漏桶限流器

### 漏桶扩容

漏桶的扩缩容也是类似于令牌桶，部分代码如下

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_leak_bucket_.lua

-- 扩容量 = 当前桶容量 * 比例
local expand_capacity = capacity * expand

local res ,_ = shared:incr(capacity_key, expand_capacity)
if not res or res == false then
	return false
end
```


### 漏桶缩容

```lua
# 代码位置 : limit/fuse/tl_ops_limit_fuse_leak_bucket_.lua

-- 缩容量 = -当前桶容量 * 比例
local shrink_capacity = capacity * shrink

local res ,_ = shared:incr(capacity_key, -shrink_capacity)
if not res or res == false then
	return false
end
```
