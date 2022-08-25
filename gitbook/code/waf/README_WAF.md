# 规则过滤

waf规则过滤，默认提供了六种规则，分别是cc规则，api(uri)规则，ip规则，cookie规则，header规则，param(args)规则。


其对应的过滤顺序为 `ip > api > cc > header > cookie > param`，如果执行完过滤链后，没有命中规则，说明通过waf。否则命中waf


接下来我们看各种规则的实现流程。这里主要对cc规则和api规则进行说明，其他的规则实现类似

### CC规则

cc规则，是对cc攻击次数的拦截，一般用某个特定key来限制，可以理解为一定时间内的次数访问限制。如，规则设置为，1分钟访问100次，超过100次认定为cc，对当前请求的 `key` 进行限制1分钟不能访问。


#### CC-Key 

    tl-ops-manage的cc规则的key是 ip + url 组成，由于key的生成会依赖url，但由于url长度不可控，所以默认截取url的前50个字符。

    后续可能会支持到自定义变量key，如host, ip, url等，


对于cc规则具体实现代码如下


```lua
# 代码位置 : waf/tl_ops_waf_cc.lua


local tl_ops_waf_core_cc_filter_global_pass = function()
    -- 作用域
    local cc_scope, _ = cache_cc:get(tl_ops_constant_waf_cc.cache_key.scope);
    if not cc_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if cc_scope ~= tl_ops_constant_waf_scope.global then
        return true
    end
    
    -- 配置列表
    local cc_list, _ = cache_cc:get(tl_ops_constant_waf_cc.cache_key.list);
    if not cc_list then
        return true
    end
    
    local cc_list_table = cjson.decode(cc_list);
    if not cc_list_table then
        return true
    end
    
    -- 获取当前url
    local request_uri = string.sub(tl_ops_utils_func:get_req_uri(), 1, MAX_URL_LEN);
    if not request_uri then
        request_uri = ""
    end
    -- 获取当前ip
    local ip = tl_ops_utils_func:get_req_ip();
    if not ip then
        ip = ""
    end

    -- cc key
    local cc_key = tl_ops_constant_waf_cc.cache_key.prefix .. ip .. request_uri

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    for _, cc in ipairs(cc_list_table) do
        repeat
            local host = cc.host
            local time = cc.time
            local count = cc.count
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 首次
            local res, _ = shared_waf:get(cc_key)
            if not res then
                shared_waf:set(cc_key, 1, time)
                break
            end
            -- 没有达到cc次数
            if res < count then
                shared_waf:incr(cc_key, 1)
                break
            end
            -- 触发cc
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_cc done")

    return true
end

```


### API规则

对API规则来说，主要思路是规则的匹配，也就是正则字符串匹配，对相应的api进行对比拦截处理。同负载api规则一样，waf也是支持到域名级别的匹配，以便于分流处理不同业务

具体实现如下 : 

```lua
# 代码位置 : waf/tl_ops_waf_api.lua

local tl_ops_waf_core_api_filter_global_pass = function()
    -- 作用域
    local api_scope, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.scope);
    if not api_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if api_scope ~= tl_ops_constant_waf_scope.global then
        return true
    end

    -- 是否开启拦截
    local open, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.open);
    if not open then
        return true
    end
    
    -- 配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.list);
    if not api_list then
        return true
    end
    
    local api_list_table = cjson.decode(api_list);
    if not api_list_table then
        return true
    end

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();
    if not request_uri then
        return true
    end

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    ...

    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local white = api.white
            -- 此前已处理白名单
            if white then
                break
            end
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'joi');

            if not res then
                break
            end
            -- 命中规则的api
            return false
        until true
    end

    return true
end

```


相较于API规则来说，其他的waf规则实现也是类似。如ip规则，header规则，cookie规则，param规则，都是在请求阶段拿到不同的数据进行规则匹配



