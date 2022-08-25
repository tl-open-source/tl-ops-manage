# 黑白名单

在waf多规则的基础上进行拦截请求，同时为其扩展了一种黑白名单类型。


## 规则黑名单


在添加规则时，规则默认为黑名单规则，也就是需要waf过滤的规则。

如常用的一些封禁ip，封禁爬虫等，可以配置header黑名单规则，ip黑名单规则，即可实现对流量的过滤


## 规则白名单

如果将添加的规则设置为白名单规则，waf过滤将优先处理白名单规则列表，一旦命中白名单列表，将跳过当前阶段剩余所有的规则，进而执行下阶段waf。

这里以API黑白名单为例，可以看到waf过滤时，是优先逐个处理白名单规则，继而处理黑名单规则


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

    -- 优先处理白名单
    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local white = api.white
            -- 非白名单跳过
            if not white then
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
            -- api白名单，不用后续比对，直接通过
            return true
        until true
    end

    ...

    return true
end

```
