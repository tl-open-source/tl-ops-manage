
# API最长前缀匹配策略

全称，api最长前缀匹配负载策略，通过请求的URI的最长前缀子串，再拿到所有API负载规则进行匹配，得到命中的API匹配规则，进而得到具体匹配的节点。


```lua
# 代码位置 : balance/tl_ops_balance_core_api.lua


-- 处理匹配逻辑
local tl_ops_balance_api_matcher_mode = function (matcher, request_uri, obj)
    local match_mode = obj.match_mode
    if not match_mode then
        match_mode = tl_ops_match_mode.reg
    end
    -- 正则匹配模式
    if match_mode == tl_ops_match_mode.reg or match_mode == tl_ops_match_mode.regi or match_mode == tl_ops_match_mode.regid then
        local from, to , _ = find(request_uri , (obj.fake_prefix .. obj.url) , match_mode);
        if from and to then
            local sub = string.sub(request_uri, from, to)
            if sub then
                if not matcher or not matcher.url then
                    matcher = obj
                end
                -- 规则最长匹配优先
                if matcher.url and #sub > #matcher.url then
                    matcher = obj
                end
            end
        end
    end
    -- 全文匹配
    if match_mode == tl_ops_match_mode.all then
        if request_uri == (obj.fake_prefix .. obj.url) then
            matcher = obj;
        end
    end

    return matcher
end

-- 获取命中的api路由项
local tl_ops_balance_api_get_matcher_rule = function(api_list_table, rule, rule_match_mode, request_uri)
    local matcher = nil;
    local matcher_list = api_list_table[rule]

    if not matcher_list then
        return nil
    end 

    -- 获取当前host
    local cur_host = ngx.var.host;

    for i, obj in pairs(matcher_list) do
        repeat
            if rule_match_mode == tl_ops_constant_balance_api.mode.host then
                -- 如果是优先host规则匹配，先剔除不属于当前host的规则
                if obj.host == nil or obj.host == '' then
                    break
                end
                if obj.host ~= "*" and obj.host ~= cur_host then
                    break
                end
            end

            matcher = tl_ops_balance_api_matcher_mode(matcher, request_uri, obj)

            break
        until true
    end

    return matcher
end


local tl_ops_balance_api_service_matcher = function(service_list_table)
    
    local matcher = nil
    local node = nil

    -- 规则匹配模式
    local rule_match_mode, _ = cache_api:get(tl_ops_constant_balance_api.cache_key.rule_match_mode);
    if not rule_match_mode then
        -- 默认以host优先匹配
        rule_match_mode = tl_ops_constant_balance_api.mode.host;
    end
    
    -- api路由策略
    local api_rule, _ = cache_api:get(tl_ops_constant_balance_api.cache_key.rule);
    if not api_rule then
        return nil, nil, nil, nil, rule_match_mode
    end

    -- api配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_balance_api.cache_key.list);
    if not api_list then
        return nil, nil, nil, nil, rule_match_mode
    end
    
    local api_list_table = cjson.decode(api_list);
    if not api_list_table then
        return nil, nil, nil, nil, rule_match_mode
    end

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();
    
    -- 根据路由当前策略进行路由, 返回正则命中的api
    if api_rule == tl_ops_constant_balance_api.rule.point then
        matcher = tl_ops_balance_api_get_matcher_rule(
            api_list_table, tl_ops_constant_balance_api.rule.point, rule_match_mode, request_uri
        );
    elseif api_rule == tl_ops_constant_balance_api.rule.random then
        matcher = tl_ops_balance_api_get_matcher_rule(
            api_list_table, tl_ops_constant_balance_api.rule.random, rule_match_mode, request_uri
        );
    end

    if not matcher or type(matcher) ~= 'table' then
        return nil, nil, nil, nil, rule_match_mode
    end

    local service_list = service_list_table[matcher.service]
    local node_id = matcher.node  -- lua index start 1

    local host = matcher.host
    if not host or host == nil then
        host = ""
    end

    -- 指定节点
    if api_rule == tl_ops_constant_balance_api.rule.point then
        if node_id ~= nil then
            node = service_list[tonumber(node_id) + 1]            
        else
            return nil, nil, nil, host, rule_match_mode
        end
    -- 服务内随机
    elseif api_rule == tl_ops_constant_balance_api.rule.random then
        math.randomseed(#request_uri)
        node_id = tonumber(math.random(0,1) % #service_list_table[matcher.service]) + 1
        node = service_list[node_id]
    end

    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, matcher.service, node_id)
    local node_state , _ = shared:get(key)

    -- 命中统计
    balance_count_api.tl_ops_balance_count_incr_api_succ(matcher.service, node_id, matcher.id);

    -- 静态页面代理路径
    local api_type = matcher.api_type
    if api_type and api_type == tl_ops_api_type.page then
        ngx.req.set_uri_args({ 
            url = request_uri
        })
        ngx.req.set_uri("/pageproxy", true)
        return
    end

    -- 需要重写url
    local rewrite_url = matcher.rewrite_url
    if rewrite_url and rewrite_url ~= '' then
        ngx.req.set_uri(rewrite_url, false)
        return
    end

    -- 需要转发到服务下的具体路径
    local fake_prefix = matcher.fake_prefix
    if fake_prefix and fake_prefix ~= '' then
        -- 通过虚拟前缀截取后缀
        local fake_sub = string.sub(request_uri, #fake_prefix + 1, #request_uri)
        if fake_sub then
            ngx.var.tlops_ups_api_prefix = fake_sub
        end
    end
    
    return node, node_state, node_id, host, rule_match_mode
end
```


# COOKIE精准匹配策略

这种策略是精准匹配，获取请求内所有cookie后，再拿到所有cookie负载规则进行匹配，得到命中的cookie匹配规则，进而得到具体匹配的节点。

具体实现代码类似 URI 匹配。


# 请求参数精准匹配策略

这种策略是精准匹配，获取请求内所有请求参数后，再拿到所有请求参数负载规则进行匹配，得到命中的请求参数匹配规则，进而得到具体匹配的节点。

具体实现代码类似 URI 匹配。


# 请求头部精准匹配策略

这种策略是精准匹配，获取请求内所有请求头后，再拿到所有请求头负载规则进行匹配，得到命中的请求头匹配规则，进而得到具体匹配的节点。

具体实现代码类似 URI 匹配。


# 请求body子串匹配策略

这种策略是子串匹配，获取请求内请求body后，再拿到所有请求body负载规则子串进行匹配，得到命中的请求头匹配规则，进而得到具体匹配的节点。

具体实现代码类似 URI 匹配。
