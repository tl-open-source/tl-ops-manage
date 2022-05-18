-- tl_ops_limit
-- en : token bucket
-- zn : 令牌桶
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_limit_fuse_token_bucket");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local shared = ngx.shared.tlopsbalance


local _M = {
    _VERSION = '0.02'
}
local mt = { __index = _M }


---- 模式
local tl_ops_limit_token_mode = function( service_name, node_id )
    local token_mode = nil

    if service_name then
        token_mode = tl_ops_constant_limit.service_token
        if node_id then
            token_mode = tl_ops_constant_limit.node_token
        end  
    end

    return token_mode
end


---- get token with lazy generate
---- block 取用令牌数量
local tl_ops_limit_token = function( service_name, node_id,  block )

    if not block or type(block) ~= 'number' then
        return false
    end

    if block <= 0 then
        return false
    end
    
    local token_mode = tl_ops_limit_token_mode( service_name , node_id)

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
    local ok, _ = shared:set(token_bucket_key, new_token_bucket)
    if not ok then
        return false
    end

    local ok, _ = shared:set(pre_time_key, cur_time)
    if not ok then
        return false
    end

    return true
end

---- 扩容
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

    if capacity <= 0 then
        return false
    end
    
    -- 暂定扩容量 = 当前桶容量 * 0.5
    local expand_capacity = capacity * 0.5


    local capacity_key = tl_ops_utils_func:gen_node_key(token_mode.cache_key.capacity, service_name, node_id)
    local res ,_ = shared:incr(capacity_key, expand_capacity)
    if not res or res == false then
        return false
    end

    return true
end


---- 缩容
local tl_ops_limit_token_shrink = function( service_name, node_id )

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

    if capacity <= 0 then
        return false
    end
    
    -- 暂定缩容量 = -当前桶容量 * 0.5
    local shrink_capacity = capacity * 0.5
    
    local res ,_ = shared:incr(capacity_key, -shrink_capacity)
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