-- tl_ops_limit
-- en : token bucket
-- zn : 令牌流控
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_limit_token_bucket");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local lock = require("lib.lock");
local shared = ngx.shared.tlopsbalance


local _M = {
    _VERSION = '0.01'
}
local mt = { __index = _M }



function _M:new( options )
    if not options or options == nil then
        tlog:dbg(" get token obj ok ")
        return setmetatable({}, mt)
    end

    local capacity = tonumber(options.capacity)
    if not capacity or capacity <= 0 then
        capacity = tl_ops_constant_limit.token.options.capacity
    end
    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.capacity, capacity)
    if not ok then
        tlog:err(" init token bucket capacity err, capacity=",capacity,",err=",_)
        return
    end

    local rate = tonumber(options.rate)
    if not rate or rate <= 0 then
        rate = tl_ops_constant_limit.token.options.rate
    end
    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.rate, rate)
    if not ok then
        tlog:err(" init token bucket rate err, rate=",rate,",err=",_)
        return
    end

    local warm = tonumber(options.warm) or 0
    if warm and warm > capacity then
        warm = tl_ops_constant_limit.token.options.warm
    end
    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.warm, warm)
    if not ok then
        tlog:err(" init token bucket warm err, warm=",warm,",err=",_)
        return
    end

    local token_bucket = 0
    if warm > 0 then
        token_bucket = warm
    end
    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.token_bucket, warm)
    if not ok then
        tlog:err(" init token bucket token_bucket err, token_bucket=",token_bucket,",err=",_)
        return
    end

    local pre_time = ngx.now()
    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.pre_time, pre_time)
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

	return setmetatable({options = final_option}, mt)
end


---- get token with lazy generate
---- block 取用令牌数量
local tl_ops_limit_token_bucket = function( block )
    local capacity = shared:get(tl_ops_constant_limit.token.cache_key.capacity)
    if not capacity then
        return false
    end
    local rate = shared:get(tl_ops_constant_limit.token.cache_key.rate)
    if not rate then
        return false
    end

    local pre_time, _ = shared:get(tl_ops_constant_limit.token.cache_key.pre_time)
    if not pre_time then
        return false
    end

    local token_bucket, _ = shared:get(tl_ops_constant_limit.token.cache_key.token_bucket)
    if not token_bucket then
        token_bucket = 0
    end

    -- 取出令牌
    if token_bucket > block then
        local ok, _ = shared:incr(tl_ops_constant_limit.token.cache_key.token_bucket, -block)
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
    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.token_bucket, new_token_bucket)
    if not ok then
        return false
    end

    local ok, _ = shared:set(tl_ops_constant_limit.token.cache_key.pre_time, cur_time)
    if not ok then
        return false
    end

    return true
end


---- get token api
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

    local elapsed, err = lock:lock(tl_ops_constant_limit.token.cache_key.lock)
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

return _M