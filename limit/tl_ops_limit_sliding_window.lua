-- tl_ops_limit
-- en : sliding window 
-- zn : 滑动窗口流控
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_limit_sliding_window");
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

    local block = tonumber(options.block)
    if not block or block <= 0 then
        block = options.block
    end
    local ok, _ = shared:set(keys.block, block)
    if not ok then
        tlog:err(" init sliding window block err, block=",block,",err=",_)
        return
    end

    local limit = tonumber(options.limit)
    if not limit or limit <= 0 then
        limit = options.limit
    end
    local ok, _ = shared:set(keys.limit, limit)
    if not ok then
        tlog:err(" init sliding window limit err, limit=",limit,",err=",_)
        return
    end

    local expand = tonumber(options.expand)
    if not expand or expand <= 0 then
        expand = options.expand
    end
    local ok, _ = shared:set(keys.expand, expand)
    if not ok then
        tlog:err(" init sliding window expand err, expand=",expand,",err=",_)
        return
    end

    local shrink = tonumber(options.shrink)
    if not shrink or shrink <= 0 then
        shrink = options.shrink
    end
    local ok, _ = shared:set(keys.shrink, shrink)
    if not ok then
        tlog:err(" init sliding window shrink err, shrink=",shrink,",err=",_)
        return
    end

    local ok, _ = shared:set(keys.count, 0)
    if not ok then
        tlog:err(" init sliding window count err, count=",keys.count,",err=",_)
        return
    end

    local final_option = {
        block = block,
        limit = limit,
    }
    tlog:dbg("new sliding window ok ,options=",final_option)

	return setmetatable({options = final_option, keys = keys}, mt)
end


-- try sliding, 尝试通过滑动窗口
-- block : 请求大小
local tl_ops_limit_sliding_window = function( block )

    local window = shared:get(self.keys.window)
    if not window then
        return false
    end

    local cycle = shared:get(self.keys.cycle)
    if not cycle then
        return false
    end

    local pre_time, _ = shared:get(self.keys.pre_time)
    if not pre_time then
        return false
    end

    ngx.update_time()
    local cur_time = ngx.now()
    local cur_duration = (cur_time - pre_time) / 1000
    
    -- 每个区间的时间 = 滑动时间窗口大小 / 需要拆分的区间数量
    local cycle_time = math.floor(window / cycle)

    -- 当前时间所处的区间 等价于 需要滑动的区间个数
    local point = math.floor(cur_duration / cycle_time)
    
    -- 达到滑动时间
    if cur_duration >= cycle_time then

        -- 统计并清除过期区间
        local old_count = 0
        for i = 0, point do
            local count, _ = shared:get(self.keys.count .. i)
            if not count then
                count = 0
            end
            local res, _ = shared:del(self.keys.count .. i)
            if not res then
                return false
            end
            old_count = old_count + count
        end

        --  更新总量
        local ok, _ = shared:incr(self.keys.count, -old_count)
        if not ok then
            return false
        end

        -- 最新时间窗口边界 = 上一次的时间窗口边界 + (point个区间 * 每个区间所占用的时间)
        local new_time = pre_time + (point * (cycle_time * 1000))
        local ok, _ = shared:set(self.keys.pre_time, new_time)
        if not ok then
            return false
        end
    end

    -- 记录总量
    local ok, _ = shared:incr(self.keys.count, block)
    if not ok then
        return false
    end

    -- 记录小区间
    local ok, _ = shared:incr(self.keys.count .. point, block)
    if not ok then
        return false
    end

    -- 请求量是否超过窗口最大限制
    local count = shared:get(self.keys.count)
    if not count then
        return false
    end

    local limit = shared:get(self.keys.limit)
    if not limit then
        return false
    end
    
    if count >= limit then
        return false
    end

    return true
end



-- try sliding 
function _M:tl_ops_sliding_window( block )
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

    local sliding = tl_ops_limit_sliding_window( block )
    if not sliding or sliding == false then
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
function _M:tl_pos_sliding_window_expand( )
    if self.options.block <= 0 then
        return false
    end
    
    -- 扩容量 = 当前窗口大小 * 比例
    local expand_block = self.options.block * self.options.expand

    -- lock
    local lock, err = lock:new("tlopsbalance")
    if not lock then
        return false
    end

    local elapsed, err = lock:lock(self.keys.lock)
    if not elapsed then
        return false
    end
    
    local res ,_ = shared:incr(self.keys.block, expand_block)
    if not res or res == false then
        return false
    end

    self.options.block = self.options.block + expand_block

    -- unlock
    local ok, err = lock:unlock()
    if not ok then
        return false
    end

    return true
end


-- 缩容
function _M:tl_pos_sliding_window_shrink( )
    if self.options.block <= 0 then
        return false
    end
    
    -- 缩容量 = -当前窗口大小 * 比例
    local shrink_block = self.options.block * self.options.shrink

    -- lock
    local lock, err = lock:new("tlopsbalance")
    if not lock then
        return false
    end

    local elapsed, err = lock:lock(self.keys.lock)
    if not elapsed then
        return false
    end
    
    local res ,_ = shared:incr(self.keys.block, -shrink_block)
    if not res or res == false then
        return false
    end

    self.options.block = self.options.block - shrink_block

    -- unlock
    local ok, err = lock:unlock()
    if not ok then
        return false
    end

    return true
end



return _M