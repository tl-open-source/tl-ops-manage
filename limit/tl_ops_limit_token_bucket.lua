-- tl_ops_limit
-- en : token bucket
-- zn : 令牌桶
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson             = require("cjson.safe");
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_limit_token_bucket");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local lock              = require("lib.lock");
local shared            = ngx.shared.tlopsbalance


local _M = {
    _VERSION = '0.02'
}
local mt = { __index = _M }



function _M:new( options, keys )
    if not options or options == nil or not keys or keys == nil then
        tlog:err(" options nil or keys nil")
        return setmetatable({}, mt)
    end

    local capacity = tonumber(options.capacity)
    if not capacity or capacity <= 0 then
        capacity = options.capacity
    end
    local ok, _ = shared:set(keys.capacity, capacity)
    if not ok then
        tlog:err(" init token bucket capacity err, capacity=",capacity,",err=",_)
        return
    end

    local rate = tonumber(options.rate)
    if not rate or rate <= 0 then
        rate = options.rate
    end
    local ok, _ = shared:set(keys.rate, rate)
    if not ok then
        tlog:err(" init token bucket rate err, rate=",rate,",err=",_)
        return
    end

    local warm = tonumber(options.warm) or 0
    if warm and warm > capacity then
        warm = options.warm
    end
    local ok, _ = shared:set(keys.warm, warm)
    if not ok then
        tlog:err(" init token bucket warm err, warm=",warm,",err=",_)
        return
    end

    local expand = tonumber(options.expand)
    if not expand or expand <= 0 then
        expand = options.expand
    end
    local ok, _ = shared:set(keys.expand, expand)
    if not ok then
        tlog:err(" init token bucket expand err, expand=",expand,",err=",_)
        return
    end

    local shrink = tonumber(options.shrink)
    if not shrink or shrink <= 0 then
        shrink = options.shrink
    end
    local ok, _ = shared:set(keys.shrink, shrink)
    if not ok then
        tlog:err(" init token bucket shrink err, shrink=",shrink,",err=",_)
        return
    end

    local token_bucket = 0
    if warm > 0 then
        token_bucket = warm
    end
    local ok, _ = shared:set(keys.token_bucket, warm)
    if not ok then
        tlog:err(" init token bucket token_bucket err, token_bucket=",token_bucket,",err=",_)
        return
    end

    local pre_time = ngx.now()
    local ok, _ = shared:set(keys.pre_time, pre_time)
    if not ok then
        tlog:err(" init token bucket pre_time err, pre_time=",pre_time,",err=",_)
        return
    end


    local final_option = {
        capacity = capacity,
        rate = rate,
        warm = warm,
        token_bucket = token_bucket,
        pre_time = pre_time
    }
    tlog:dbg("new token bucket ok ,options=",final_option)

	return setmetatable({options = final_option, keys = keys}, mt)
end


-- get token with lazy generate
-- block 取用令牌数量
local tl_ops_limit_token_bucket = function( block )
    local capacity = shared:get(self.keys.capacity)
    if not capacity then
        return false
    end
    local rate = shared:get(self.keys.rate)
    if not rate then
        return false
    end

    local pre_time, _ = shared:get(self.keys.pre_time)
    if not pre_time then
        return false
    end

    local token_bucket, _ = shared:get(self.keys.token_bucket)
    if not token_bucket then
        token_bucket = 0
    end

    -- 取出令牌
    if token_bucket > block then
        local ok, _ = shared:incr(self.keys.token_bucket, -block)
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
        local ok, _ = shared:set(self.keys.token_bucket, new_token_bucket)
        if not ok then
            return false
        end
    
        local ok, _ = shared:set(self.keys.pre_time, cur_time)
        if not ok then
            return false
        end

        return false
    end

    -- 移除一个令牌
    local ok, _ = shared:set(self.keys.token_bucket, new_token_bucket - block)
    if not ok then
        return false
    end

    local ok, _ = shared:set(self.keys.pre_time, cur_time)
    if not ok then
        return false
    end
    
    return true
end


-- get token api
function _M:tl_ops_limit_token( block )
    if not block or type(block) ~= 'number' then
        return false
    end

    if block <= 0 then
        return false
    end

    -- lock
    local lock, err = lock:new("tlopsbalance")
    if not lock then
        return false
    end

    local elapsed, err = lock:lock(self.keys.lock)
    if not elapsed then
        return false
    end

    local token = tl_ops_limit_token_bucket( block )
    if not token or token == false then
        return false
    end

    -- unlock
    local ok, err = lock:unlock()
    if not ok then
        return false
    end

    return true
end


-- 扩容
function _M:tl_pos_limit_token_expand( )
    if self.options.capacity <= 0 then
        return false
    end
    
    -- 扩容量 = 当前桶容量 * 比例
    local expand_capacity = self.options.capacity * self.options.expand

    -- lock
    local lock, err = lock:new("tlopsbalance")
    if not lock then
        return false
    end

    local elapsed, err = lock:lock(self.keys.lock)
    if not elapsed then
        return false
    end
    
    local res ,_ = shared:incr(self.keys.capacity, expand_capacity)
    if not res or res == false then
        return false
    end

    self.options.capacity = self.options.capacity + expand_capacity

    -- unlock
    local ok, err = lock:unlock()
    if not ok then
        return false
    end

    return true
end


-- 缩容
function _M:tl_pos_limit_token_shrink( )
    if self.options.capacity <= 0 then
        return false
    end
    
    -- 缩容量 = -当前桶容量 * 比例
    local shrink_capacity = self.options.capacity * self.options.shrink

    -- lock
    local lock, err = lock:new("tlopsbalance")
    if not lock then
        return false
    end

    local elapsed, err = lock:lock(self.keys.lock)
    if not elapsed then
        return false
    end
    
    local res ,_ = shared:incr(self.keys.capacity, -shrink_capacity)
    if not res or res == false then
        return false
    end

    self.options.capacity = self.options.capacity - shrink_capacity

    -- unlock
    local ok, err = lock:unlock()
    if not ok then
        return false
    end

    return true
end


return _M