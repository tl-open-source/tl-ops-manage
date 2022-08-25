# 耗时告警插件

请求耗时告警主要用来对一些异常请求进行监控，如果请求时间过长，周期内大量请求超时等等。实现思路主要是依赖一个生产消费队列组。


## 队列组

因为告警插件生命周期为`log_by_lua`阶段，虽然此阶段是异步执行，但是考虑到可能在请求量较大的情况下，每次都重复执行一些逻辑，可能对worker有一定压力，于是考虑将这些重复逻辑组合成 `消息` 格式，周期性的去消费。

在设计上，我将队列长度，队列数量都做成配置化，以方便适应不同场景，配置需要依赖实际情况来做权衡设置。

默认最大队列数量 = 10，默认单个队列最大消息长度 = 100。也就是说，在单个消息体大小为1kb的情况下，shared共享内存中，最多占用 `1kb * 10 * 100 ~= 1M `

### 注意

队列的实现是循环覆盖，也就是说如果全部队列满了，或者消费速度太慢，消息将会从头开始覆盖，从而丢失部分告警消息。

所以具体的数值配置需要对线上机器环境情况进行权衡来设定，在保证性能的情况下，减少消息的丢失。

## 告警信息生产

对于告警消息的生产，是每一个请求都会产生的，在触发告警规则后，在插件的 `tl_ops_process_after_init_log` 阶段，每次都向合适的队列中去插入一条告警消息。

合适的队列是由写入指针不断偏移来决定的，实现方式如下


```lua
# 代码位置 : plugins/tl_ops_time_alert/time_alert.lua

-- 定时告警数据生产
local tl_ops_time_alert_produce = function(ctx, option, alert_mode)

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
        shared:rpush(list_cache_key .. produce_count, content)

        tlog:dbg("tl_ops_time_alert_produce rpush done ,key=",list_cache_key .. produce_count)
        return
    end

    -- 缓冲组满了 && 当前生产组指针到达最大，从头开始覆盖
    if produce_count == max_list_count then
        local res, _ = shared:delete(list_cache_key ..  0)
        if not res then
            tlog:err("tl_ops_time_alert_produce list full ! reset 0 err, err=",_)
            return
        end

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
    shared:rpush(list_cache_key ..  new_produce_count, content)

    return
end
```

## 告警信息消费

对于告警消息的消费，是依赖定时任务去消费，在配置的周期内执行消费逻辑，一次消费一个合适的队列。

合适的队列是由消费指针不断偏移来决定的，实现方式如下

```lua
# 代码位置 : plugins/tl_ops_time_alert/time_alert.lua

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

        return
    end

    -- 一次消费一个缓冲组
    while true do 
        local content_json = shared:rpop(list_cache_key .. consume_count)
        if not content_json then
            tlog:dbg("tl_ops_time_alert_consume content json nil, ",content_json)
            break
        end

        local content = cjson.decode(content_json)
        if not content then
            tlog:err("tl_ops_time_alert_consume decode content json err")
            break
        end

        -- 写入磁盘/发送邮件
        local option = content.option
        local alert_type = content.alert_type
        local mode = option.mode

        -- 日志
        if mode == ALERT_MODE.log then
            time_alert_log:handler(option, content)
        end

        -- 邮件
        if mode == ALERT_MODE.log then
            time_alert_email:handler(option, content)
        end

    end

    -- 更新消费指针
    local new_consume_count = math.min(max_list_count, consume_count + 1)

    -- 消费指针达到最大，从0组开始覆盖消费
    if consume_count == max_list_count then
        new_consume_count = 0
    end

    local res, _ = shared:set(consume_cache_key, new_consume_count)
    if not res then
        tlog:err("tl_ops_time_alert_consume decri consume_count err, err=",_)
        return 
    end
end
```


### 弊端


看完实现和思路，想必大家也看出弊端了，但是总体来说，对于告警信息，对业务影响不是特别重要，只是一种辅助性的功能，所以暂时只做了一个雏形


    1 . 在生产时，如果没有设置合理的队列大小和数量，会造成消息丢失。

    2 . 消息在内存中，如果重启，消息丢失。

    3 . 消费时，如果队列设置长度过长，还是会对性能造成影响

    4 . 暂时不支持消费时一次消费的消息数量。