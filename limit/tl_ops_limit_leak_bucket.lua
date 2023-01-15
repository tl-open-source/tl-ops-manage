-- tl_ops_limit
-- en : leak bucket
-- zn : 漏桶流控
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson             = require("cjson.safe");
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_limit_leak_bucket");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local shared            = ngx.shared.tlopsbalance


local _M = {
    _VERSION = '0.01'
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
        tlog:err(" init leak bucket capacity err, capacity=",capacity,",err=",_)
        return
    end

    local rate = tonumber(options.rate)
    if not rate or rate <= 0 then
        rate = options.rate
    end
    local ok, _ = shared:set(keys.rate, rate)
    if not ok then
        tlog:err(" init leak bucket rate err, rate=",rate,",err=",_)
        return
    end

    local expand = tonumber(options.expand)
    if not expand or expand <= 0 then
        expand = options.expand
    end
    local ok, _ = shared:set(keys.expand, expand)
    if not ok then
        tlog:err(" init leak bucket expand err, expand=",expand,",err=",_)
        return
    end

    local shrink = tonumber(options.shrink)
    if not shrink or shrink <= 0 then
        shrink = options.shrink
    end
    local ok, _ = shared:set(keys.shrink, shrink)
    if not ok then
        tlog:err(" init leak bucket shrink err, shrink=",shrink,",err=",_)
        return
    end

    local pre_time = ngx.now()
    local ok, _ = shared:set(keys.pre_time, pre_time)
    if not ok then
        tlog:err(" init leak bucket pre_time err, pre_time=",pre_time,",err=",_)
        return
    end

    local final_option = {
        capacity = capacity,
        rate = rate,
        pre_time = pre_time
    }
    tlog:dbg("new leak bucket ok ,options=",final_option)

	return setmetatable({options = final_option, keys = keys}, mt)
end


-- get leak with lazy generate
-- block 漏桶流速单位
local tl_ops_limit_leak_bucket = function( block )
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

    -- 当前堆积量
    local leak_bucket, _ = shared:get(self.keys.leak_bucket)
    if not leak_bucket then
        leak_bucket = 0
    end

    -- 漏桶当前时间区间内的剩余请求量 = 当前堆积量 - (在此时间区间应该被漏出的请求量) 
    -- ==
    -- 漏桶当前时间区间内的剩余请求量 = 当前堆积量 - (距离上次时间差 * 生成速率)
    ngx.update_time()
    local cur_time = ngx.now()
    local lave_leak_bucket = leak_bucket - (cur_time - pre_time) * rate
    if lave_leak_bucket <= 0 then
        return false
    end

    -- 溢出
    if lave_leak_bucket + 1 > capacity then
        return false
    end

    local new_leak_bucket = math.max(capacity, lave_leak_bucket)
    local ok, _ = shared:set(self.keys.leak_bucket, new_leak_bucket)
    if not ok then
        return false
    end

    local ok, _ = shared:set(self.keys.pre_time, cur_time)
    if not ok then
        return false
    end

    return true
end


-- get leak api
function _M:tl_ops_limit_leak( block )
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

    local leak = tl_ops_limit_leak_bucket( block )
    if not leak or leak == false then
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
function _M:tl_pos_limit_leak_expand( )
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