-- tl_ops_waf_core_header
-- en : waf core header black white list impl
-- zn : waf header黑白名单
-- @author iamtsm
-- @email 1905333456@qq.com


local waf_count_header              = require("waf.count.tl_ops_waf_count_header")
local tl_ops_constant_waf_header    = require("constant.tl_ops_constant_waf_header")
local waf_scope                     = require("constant.tl_ops_constant_comm").tl_ops_waf_scope;
local cache_header                  = require("cache.tl_ops_cache_core"):new("tl-ops-waf-header")
local tlog                          = require("utils.tl_ops_utils_log"):new("tl_ops_waf_header")
local find                          = ngx.re.find
local cjson                         = require("cjson.safe")


-- 全局拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_header_filter_global_pass = function()
    -- 作用域
    local header_scope, _ = cache_header:get(tl_ops_constant_waf_header.cache_key.scope);
    if not header_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if header_scope ~= waf_scope.global then
        return true
    end
    
    -- 是否开启拦截
    local open, _ = cache_header:get(tl_ops_constant_waf_header.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local header_list, _ = cache_header:get(tl_ops_constant_waf_header.cache_key.list);
    if not header_list then
        return true
    end
    
    local header_list_table = cjson.decode(header_list);
    if not header_list_table then
        return true
    end

    -- 获取当前header
    local headers, _ = ngx.req.get_headers();
    if not headers then
        return true
    end
    
    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_header get list ok, scope=",header_scope, ",host=",cur_host,",headers=",headers,",list=",header_list_table)

    -- 优先处理白名单
    for _, header in ipairs(header_list_table) do
        repeat
            local keys = header.keys
            local value = header.value
            local host = header.host
            local white = header.white
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
            -- 请求头键列表为空
            if not keys then
                break
            end
            -- 请求头值列表过滤
            for _, key in pairs(keys) do
                repeat
                    -- 值为空
                    if headers[key] == nil or headers[key] == '' then
                        break
                    end
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(headers[key] , value , 'joi');
                    if not res then
                        break
                    end
                    -- 白名单，不用后续比对，直接通过
                    return true
                until true
            end
            break
        until true
    end

    for _, header in ipairs(header_list_table) do
        repeat
            local keys = header.keys
            local value = header.value
            local host = header.host
            local white = header.white
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
            -- 请求头键列表为空
            if not keys then
                break
            end
            -- 请求头值列表过滤
            for _, key in pairs(keys) do
                repeat
                    -- 值为空
                    if headers[key] == nil or headers[key] == '' then
                        break
                    end
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(headers[key] , value , 'joi');
                    if not res then
                        break
                    end
                    -- 命中规则的header
                    waf_count_header.tl_ops_waf_count_incr_header_succ()
                    return false
                until true
            end
            break
        until true
    end

    tlog:dbg("tl_ops_waf_header done")

    return true
end


-- 匹配到服务层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_header_filter_service_pass = function(service_name)
    if not service_name then
        return true
    end
    
    -- 作用域
    local header_scope, _ = cache_header:get(tl_ops_constant_waf_header.cache_key.scope);
    if not header_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if header_scope ~= waf_scope.service then
        return true
    end
    
    -- 是否开启拦截
    local open, _ = cache_header:get(tl_ops_constant_waf_header.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local header_list, _ = cache_header:get(tl_ops_constant_waf_header.cache_key.list);
    if not header_list then
        return true
    end
    
    local header_list_table = cjson.decode(header_list);
    if not header_list_table then
        return true
    end

    -- 获取当前header
    local headers, _ = ngx.req.get_headers();
    if not headers then
        return true
    end

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_header get list ok, scope=",header_scope, ",host=",cur_host,",headers=",headers,",list=",header_list_table)

    -- 优先处理白名单
    for _, header in ipairs(header_list_table) do
        repeat
            local keys = header.keys
            local value = header.value
            local host = header.host
            local service = header.service
            local white = header.white
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
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
                break
            end
            -- 请求头键列表为空
            if not keys then
                break
            end
            -- 请求头值列表过滤
            for _, key in pairs(keys) do
                repeat
                    -- 值为空
                    if headers[key] == nil or headers[key] == '' then
                        break
                    end
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(headers[key] , value , 'joi');
                    if not res then
                        break
                    end
                    -- 白名单，不用后续比对，直接通过
                    return true
                until true
            end
            break
        until true
    end

    for _, header in ipairs(header_list_table) do
        repeat
            local keys = header.keys
            local value = header.value
            local host = header.host
            local service = header.service
            local balck = header.balck
            local white = header.white
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
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
                break
            end
            -- 请求头键列表为空
            if not keys then
                break
            end
            -- 请求头值列表过滤
            for _, key in pairs(keys) do
                repeat
                    -- 值为空
                    if headers[key] == nil or headers[key] == '' then
                        break
                    end
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(headers[key] , value , 'joi');
                    if not res then
                        break
                    end
                    -- 命中规则的header
                    waf_count_header.tl_ops_waf_count_incr_header_succ(service_name, 0, header.id)
                    return false
                until true
            end
            break
        until true
    end

    tlog:dbg("tl_ops_waf_header done")

    return true
end



return {
    tl_ops_waf_core_header_filter_global_pass = tl_ops_waf_core_header_filter_global_pass,
    tl_ops_waf_core_header_filter_service_pass = tl_ops_waf_core_header_filter_service_pass,
}