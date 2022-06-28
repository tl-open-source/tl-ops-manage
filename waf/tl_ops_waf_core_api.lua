-- tl_ops_waf_core_api
-- en : waf core api black white list impl
-- zn : waf api黑白名单
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_constant_waf_api = require("constant.tl_ops_constant_waf_api");
local tl_ops_constant_waf_scope = require("constant.tl_ops_constant_waf_scope");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local cache_api = require("cache.tl_ops_cache"):new("tl-ops-waf-api");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_waf_api");
local find = ngx.re.find
local cjson = require("cjson");



-- 全局拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_api_filter_global_pass = function()
    -- 作用域
    local api_scope, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.scope);
    if not api_scope then
        return false
    end

    -- 根据作用域进行waf拦截
    if api_scope ~= tl_ops_constant_waf_scope.global then
        return false
    end

    -- 是否开启拦截
    local open, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.open);
    if not open then
        return true
    end
    
    -- 配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.list);
    if not api_list then
        return false
    end
    
    local api_list_table = cjson.decode(api_list);
    if not api_list_table then
        return false
    end

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();
    if not request_uri then
        return true
    end

    local cur_host = ngx.var.host

    tlog:dbg("tl_ops_waf_api get list ok, scope=",api_scope, ",host=",cur_host,",uri=",request_uri,",list=",api_list_table)

    -- 优先处理白名单
    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local white = api.white
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'jo');
            if not res then
                break
            end
            -- 继续比对下一个白名单
            if not white then
                break
            end
            -- api白名单，不用后续比对，直接通过
            return true
        until true
    end

    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local white = api.white
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'jo');
            if not res then
                break
            end
            -- 命中规则的api
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_api done")

    return true
end


-- 匹配到服务层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_api_filter_service_pass = function(service_name)
    if not service_name then
        return false
    end
    
    -- 作用域
    local api_scope, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.scope);
    if not api_scope then
        return false
    end

    -- 根据作用域进行waf拦截
    if api_scope ~= tl_ops_constant_waf_scope.service then
        return false
    end

    -- 是否开启拦截
    local open, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.open);
    if not open then
        return true
    end
    
    -- 配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.list);
    if not api_list then
        return false
    end
    
    local api_list_table = cjson.decode(api_list);
    if not api_list_table then
        return false
    end

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();
    if not request_uri then
        return true
    end
    
    local cur_host = ngx.var.host

    tlog:dbg("tl_ops_waf_api get list ok, scope=",api_scope, ",host=",cur_host,",uri=",request_uri,",list=",api_list_table)

    -- 优先处理白名单
    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local service = api.service
            local white = api.white
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'jo');
            if not res then
                break
            end
            -- 继续比对下一个白名单
            if not white then
                break
            end
            -- api白名单，不用后续比对，直接通过
            return true
        until true
    end

    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local service = api.service
            local white = api.white
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'jo');
            if not res then
                break
            end
            -- 命中规则的api
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_api done")

    return true
end


-- 匹配到节点层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_api_filter_node_pass = function(service_name, node_id)
    if not service_name or not node_id then
        return false
    end
    
    -- 作用域
    local api_scope, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.scope);
    if not api_scope then
        return false
    end

    -- 根据作用域进行waf拦截
    if api_scope ~= tl_ops_constant_waf_scope.node then
        return false
    end
    
    -- 是否开启拦截
    local open, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_waf_api.cache_key.list);
    if not api_list then
        return false
    end
    
    local api_list_table = cjson.decode(api_list);
    if not api_list_table then
        return false
    end

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();
    if not request_uri then
        return true
    end

    local cur_host = ngx.var.host

    tlog:dbg("tl_ops_waf_api get list ok, scope=",api_scope, ",host=",cur_host,",uri=",request_uri,",list=",api_list_table)

    -- 优先处理白名单
    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local service = api.service
            local node = api.node
            local white = api.white
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
                break
            end
            -- 节点为空
            if node == nil or node == '' then
                break
            end
            -- 节点不匹配
            if node ~= node_id then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'jo');
            if not res then
                break
            end
            -- 继续比对下一个白名单
            if not white then
                break
            end
            -- api白名单，不用后续比对，直接通过
            return true
        until true
    end

    for _, api in ipairs(api_list_table) do
        repeat
            local value = api.value
            local host = api.host
            local service = api.service
            local node = api.node
            local white = api.white
            -- 域名为空跳过规则
            if host == nil or host == '' then
                break
            end
            -- 域名不匹配跳过规则
            if host ~= "*" and host ~= cur_host then
                break
            end
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
                break
            end
            -- 节点为空
            if node == nil or node == '' then
                break
            end
            -- 节点不匹配
            if node ~= node_id then
                break
            end
            -- 未命中拦截规则，进行下一个
            local res, _ = find(request_uri , value , 'jo');
            if not res then
                break
            end
            -- 命中规则的api
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_api done")

    return true
end


return {
    tl_ops_waf_core_api_filter_global_pass = tl_ops_waf_core_api_filter_global_pass,
    tl_ops_waf_core_api_filter_service_pass = tl_ops_waf_core_api_filter_service_pass,
    tl_ops_waf_core_api_filter_node_pass = tl_ops_waf_core_api_filter_node_pass
}