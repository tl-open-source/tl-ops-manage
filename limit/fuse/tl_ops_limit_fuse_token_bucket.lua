-- tl_ops_limit
-- en : token bucket
-- zn : 令牌桶-熔断限流用
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                 = require("cjson.safe");
local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_limit_fuse_token_bucket");
local tl_ops_utils_func     = require("utils.tl_ops_utils_func");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local cache_limit           = require("cache.tl_ops_cache_core"):new("tl-ops-limit");
local shared                = ngx.shared.tlopsbalance


local _M = {
    _VERSION = '0.02'
}
local mt = { __index = _M }


-- 通过service name获取对于的option
local tl_ops_limit_token_get_option = function( options, name )
	for i = 1, #options do
		local service_name = options[i].service_name
		if name == service_name then
			return options[i]
		end
	end
	return nil
end


-- 模式
local tl_ops_limit_token_mode = function( service_name, node_id )
    local token_mode = nil

    if service_name then
        local options_str = cache_limit:get(tl_ops_constant_limit.token.cache_key.options_list)
        if not options_str then
            tlog:err("tl_ops_limit_token_mode err, options_str=",options_str)
            return nil
        end
        local options_list = cjson.decode(options_str)
        local matcher_option = tl_ops_limit_token_get_option(options_list, service_name)

        token_mode = { 
            cache_key = tl_ops_constant_limit.token.cache_key,
            options = matcher_option
        }

        if node_id then -- 暂不支持节点级别配置
            
        end  
    end

    return token_mode
end

-- get token with lazy generate
-- block 取用令牌数量
local tl_ops_limit_token = function( service_name, node_id )
    local token_mode = tl_ops_limit_token_mode( service_name , node_id)

    local block = token_mode.options.block

    local capacity_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.capacity, service_name, node_id)
    local capacity = shared:get(capacity_key)
    if not capacity then
        local res, _ = shared:set(capacity_key, token_mode.options.capacity)
        if not res then
            return false
        end
        capacity = token_mode.options.capacity
    end

    local rate_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.rate, service_name, node_id)
    local rate = shared:get(rate_key)
    if not rate then
        local res, _ = shared:set(rate_key, token_mode.options.rate)
        if not res then
            return false
        end
        rate = token_mode.options.rate
    end

    local pre_time_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.pre_time, service_name, node_id)
    local pre_time, _ = shared:get(pre_time_key)
    if not pre_time then
        local cur_time = ngx.now();
        local res, _ = shared:set(pre_time_key, cur_time)
        if not res then
            return false
        end
        pre_time = cur_time
    end

    local token_bucket_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.token_bucket, service_name, node_id)
    local token_bucket, _ = shared:get(token_bucket_key)
    if not token_bucket then
        local res, _ = shared:set(token_bucket_key, 0)
        if not res then
            return false
        end
        token_bucket = 0
    end

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

    local expand_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.expand, service_name, node_id)
    local expand = shared:get(expand_key)
    if not expand then
        local res, _ = shared:set(expand_key, token_mode.options.expand)
        if not res then
            return false
        end
        expand = token_mode.options.expand
    end

    tlog:dbg("token expand=",expand, ",service_name=", service_name, ",node_id=",node_id,",expand_key=", expand_key)
    
    -- 扩容量 = 当前桶容量 * 比例
    -- 扩容最大容量暂时不限制大小，理论上扩容前，必定伴随一次缩容，所以不最大容量会超过设置的最大容量
    local expand_capacity = capacity * expand

    local capacity_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.capacity, service_name, node_id)
    local res ,_ = shared:incr(capacity_key, expand_capacity)
    if not res or res == false then
        return false
    end

    return true
end


-- 缩容 熔断定时器中保证锁，所以这里不加锁
local tl_ops_limit_token_shrink = function( service_name, node_id )

    local token_mode = tl_ops_limit_token_mode( service_name, node_id)
    
    local block = token_mode.options.block

    local capacity_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.capacity, service_name, node_id)
    local capacity = shared:get(capacity_key)
    if not capacity then
        local res, _ = shared:set(capacity_key, token_mode.options.capacity)
        if not res then
            return false
        end
        capacity = token_mode.options.capacity
    end

    -- 无需缩容
    if capacity <= block then
        return true
    end
    
    local shrink_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.shrink, service_name, node_id)
    local shrink = shared:get(shrink_key)
    if not shrink then
        local res, _ = shared:set(shrink_key, token_mode.options.shrink)
        if not res then
            return false
        end
        shrink = token_mode.options.shrink
    end

    tlog:dbg("token shrink=",shrink, ",service_name=", service_name, ",node_id=",node_id,",shrink_key=", shrink_key)

    -- 缩容量 = -当前桶容量 * 比例
    -- 最小容量保证可用通过一个单位的请求
    local shrink_capacity = math.max(capacity * shrink, block)
    
    local res ,_ = shared:set(capacity_key, shrink_capacity)
    if not res or res == false then
        return false
    end

    return true
end



return {
    tl_ops_limit_token = tl_ops_limit_token,
    tl_ops_limit_token_expand = tl_ops_limit_token_expand,
    tl_ops_limit_token_shrink = tl_ops_limit_token_shrink
}