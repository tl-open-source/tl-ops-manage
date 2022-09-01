-- tl_ops_time_alert
-- en : request long time alert
-- zn : 请求耗时告警插件
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_time_alert")
local time_alert_constant   = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant")
local time_alert_content    = require("plugins.tl_ops_time_alert.time_alert_content")
local time_alert_log        = require("plugins.tl_ops_time_alert.time_alert_log_handler")
local time_alert_email      = require("plugins.tl_ops_time_alert.time_alert_email_handler")
local cjson                 = require("cjson.safe");
local utils                 = tlops.utils
local shared                = tlops.plugin_shared


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


local ALERT_TYPE = {
    INTERVAL = "interval",
    COUNT = "count",
    TIME = "time"
}

local ALERT_MODE = time_alert_constant.mode


-- 定时告警数据消费
local tl_ops_time_alert_consume = function( )

    -- 告警缓冲组cache_key前缀
    local list_cache_key = time_alert_constant.cache_key.list
    -- 告警消息组消费指针
    local consume_cache_key = time_alert_constant.cache_key.consume
    -- 单个缓冲组告警消息最大长度
    local max_list_len = time_alert_constant.max_list_len
    -- 最多缓冲组数量
    local max_list_count = time_alert_constant.max_list_count

    -- 当前消费指针值
    local consume_count = shared:get(consume_cache_key)
    if not consume_count then
        local res = shared:set(consume_cache_key, 0)
        if not res then
            tlog:err("tl_ops_time_alert_consume get consume_count nil , init consume_count err, timer exit")
            return
        end

        tlog:dbg("tl_ops_time_alert_consume get consume_count nil , init consume_count = 0")
        consume_count = 0
    end

    consume_count = tonumber(consume_count)
    if consume_count < 0 then
        tlog:err("tl_ops_time_alert_consume consume_count err ! consume_count=",list_count)
        return
    end

    -- 当前消费缓冲组的长度
    local len = shared:llen(list_cache_key ..  consume_count)
    if len == nil then
        tlog:err("tl_ops_time_alert_consume get len err")
        return
    end

    -- 当前消费指针队列为空
    if len == 0 then
        local new_consume_count = math.min(max_list_count, consume_count + 1)

        -- 消费指针达到最大，从头开始继续
        if consume_count == max_list_count then
            new_consume_count = 0
        end

        -- 更新指针后跳出
        local res, _ = shared:set(consume_cache_key, new_consume_count)
        if not res then
            tlog:err("tl_ops_time_alert_consume incr consume_count err, err=",_)
            return
        end

        tlog:dbg("tl_ops_time_alert_consume len 0, consume_count=",consume_count)
        return
    end

    tlog:dbg("tl_ops_time_alert_consume list len, consume_count=",consume_count,",len=",len,",key=",list_cache_key .. consume_count)

    -- 用于批量操作日志记录
    local log_group = {}

    -- 一次消费一个缓冲组
    for i = 1, max_list_len do
        local content_json, _ = shared:rpop(list_cache_key .. consume_count)
        if not content_json then
            tlog:dbg("tl_ops_time_alert_consume content nil, key=",list_cache_key .. consume_count,",err=",_)
            break
        end

        local content = cjson.decode(content_json)
        if not content then
            tlog:err("tl_ops_time_alert_consume decode content err")
            break
        end

        -- 写入磁盘/发送邮件
        local option = content.option
        local alert_type = content.alert_type
        local mode = option.mode
        local target = option.target

        -- 日志
        if mode == ALERT_MODE.log then
            local target_list = log_group[target]
            if not target_list then
                target_list = utils:new_tab(0, 50)
            end
            table.insert(target_list, content)
            
            log_group[target] = target_list
        end

        -- 邮件
        if mode == ALERT_MODE.log then
            time_alert_email:handler(option, content)
        end
    end
    
    -- 批量IO
    for target, target_list in pairs(log_group) do
        local option = {
            target = target
        }
        time_alert_log:handler(option, target_list)
    end

    tlog:dbg("tl_ops_time_alert_consume done, log_group_len=",#log_group)

    -- 更新消费指针
    local new_consume_count = math.min(max_list_count, consume_count + 1)

    -- 消费指针达到最大，从0组开始覆盖消费
    if consume_count == max_list_count then
        tlog:dbg("tl_ops_time_alert_consume consume_count max , reset to 0")
        new_consume_count = 0
    end

    local res, _ = shared:set(consume_cache_key, new_consume_count)
    if not res then
        tlog:err("tl_ops_time_alert_consume decri consume_count err, err=",_)
        return 
    end
end


-- 定时告警数据生产
local tl_ops_time_alert_produce = function(ctx, option, alert_mode)

    tlog:dbg("tl_ops_time_alert_produce start, alert_mode=",alert_mode)

    -- 告警缓冲组cache_key前缀
    local list_cache_key = time_alert_constant.cache_key.list
    -- 告警消息组生产指针
    local produce_cache_key = time_alert_constant.cache_key.produce
    -- 单个缓冲组告警消息最大长度
    local max_list_len = time_alert_constant.max_list_len
    -- 最多缓冲组数量
    local max_list_count = time_alert_constant.max_list_count

    -- 当前告警消息组生产指针
    local produce_count = shared:get(produce_cache_key)
    if not produce_count then
        local res = shared:set(produce_cache_key, 0)
        if not res then
            tlog:err("tl_ops_time_alert_produce get produce_count nil , init produce_count err, timer exit")
            return
        end

        tlog:dbg("tl_ops_time_alert_produce get produce_count nil , init produce_count = 0")
        produce_count = 0
    end

    produce_count = tonumber(produce_count)

    -- 当前缓冲组的长度
    local len = shared:llen(list_cache_key ..  produce_count)
    if len == nil then
        tlog:err("tl_ops_time_alert_produce get len nil err")
        return
    end

    -- 当前缓冲组还没満，写入告警消息
    if len + 1 <= max_list_len then
        local content = time_alert_content.time_alert_content_wrap(ctx, option, alert_mode)
        local ok, _ = shared:rpush(list_cache_key .. produce_count, content)

        tlog:dbg("tl_ops_time_alert_produce rpush done ,ok=",ok,",key=",list_cache_key .. produce_count)
        return
    end

    -- 缓冲组满了 && 当前生产组指针到达最大，从头开始覆盖
    if produce_count == max_list_count then
        local res, _ = shared:delete(list_cache_key ..  0)
        if not res then
            tlog:err("tl_ops_time_alert_produce list full ! reset 0 err, err=",_)
            return
        end

        tlog:dbg("tl_ops_time_alert_produce list full ! start use 0 list")
        produce_count = -1
    end

    -- 更新生产指针
    local new_produce_count = math.min(max_list_count, produce_count + 1)
    local res, _ = shared:set(produce_cache_key, new_produce_count)
    if not res then
        tlog:err("tl_ops_time_alert_produce incr produce_count err, err=",_)
        return 
    end

    -- 放入新的缓冲组
    local content = time_alert_content.time_alert_content_wrap(ctx, option, alert_mode)
    local ok, _ = shared:rpush(list_cache_key ..  new_produce_count, content)

    tlog:dbg("tl_ops_time_alert_produce rpush new done , ok=",ok,",key=",list_cache_key .. new_produce_count)
    return
end


-- 定时器
local tl_ops_time_alert_timer
tl_ops_time_alert_timer = function(premature, options)
	if premature then
		return
    end

    tlog:dbg("tl_ops_time_alert_timer start")

	local ok, _ = pcall(tl_ops_time_alert_consume, options)
	if not ok then
		tlog:err("tl_ops_time_alert_timer failed to pcall : " ,  _)
	end

	local ok, _ = ngx.timer.at(options.interval, tl_ops_time_alert_timer, options)
	if not ok then
		tlog:err("tl_ops_time_alert_timer failed to create timer: " , _)
	end

	tlog:dbg("tl_ops_time_alert_timer end")
end


-- 启动器
function _M:tl_ops_time_alert_timer_start( )
    local lock_key = time_alert_constant.cache_key.time_lock
    local lock_time = 3
    if not utils:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    local options = {
        interval = time_alert_constant.interval,
    }

    local ok, _ = ngx.timer.at(0, tl_ops_time_alert_timer, options)
	if not ok then
		tlog:err("tl_ops_time_alert_timer start failed to run , create timer failed " ,_)
		return nil
    end
end


-- 耗时统计告警
function _M:tl_ops_time_alert_log(ctx)
    
    local request_time = ngx.var.request_time * 1000
    local options = time_alert_constant.options

    for _, rule in ipairs(options) do
        local time = rule.time
        if not time then 
            break
        end
        time = tonumber(time)

        local count = rule.count
        if not count then 
            break
        end
        count = tonumber(count)

        local interval = rule.interval
        if not interval then 
            break
        end
        interval = tonumber(interval)

        -- 周期内触发多少次超时
        if interval > 0 then
            if count > 0 then
                if time > 0 and request_time > time then
                    tl_ops_time_alert_produce(ctx, rule, ALERT_TYPE.INTERVAL)
                end
            end
            break
        end

        -- 触发多少次超时
        if count > 0 then
            if time > 0 and request_time > time then
                tl_ops_time_alert_produce(ctx, rule, ALERT_TYPE.COUNT)
            end

            break
        end

        -- 触发超时
        if request_time > time then
            tl_ops_time_alert_produce(ctx, rule, ALERT_TYPE.TIME)
            break
        end
    end

end


function _M:new()
	return setmetatable({}, mt)
end


return _M
