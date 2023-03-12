-- tl_ops_waf_core_cookie
-- en : waf core cookie black white list impl
-- zn : waf cookie黑白名单
-- @author iamtsm
-- @email 1905333456@qq.com

local waf_count_cookie              = require("waf.count.tl_ops_waf_count_cookie")
local tl_ops_constant_waf_cookie    = require("constant.tl_ops_constant_waf_cookie");
local waf_scope                     = require("constant.tl_ops_constant_comm").tl_ops_waf_scope;
local cache_cookie                  = require("cache.tl_ops_cache_core"):new("tl-ops-waf-cookie");
local tlog                          = require("utils.tl_ops_utils_log"):new("tl_ops_waf_cookie");
local find                          = ngx.re.find
local cjson                         = require("cjson.safe");


-- 全局拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_cookie_filter_global_pass = function()
    -- 作用域
    local cookie_scope, _ = cache_cookie:get(tl_ops_constant_waf_cookie.cache_key.scope);
    if not cookie_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if cookie_scope ~= waf_scope.global then
        return true
    end

    -- 是否开启拦截
    local open, _ = cache_cookie:get(tl_ops_constant_waf_cookie.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local cookie_list, _ = cache_cookie:get(tl_ops_constant_waf_cookie.cache_key.list);
    if not cookie_list then
        return true
    end
    
    local cookie_list_table = cjson.decode(cookie_list);
    if not cookie_list_table then
        return true
    end

    -- 获取当前cookie
    local cookie_string, _ = ngx.var.http_cookie
    if not cookie_string then
        return true
    end
    
    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_cookie get list ok, scope=",cookie_scope, ",host=",cur_host,",cookie_string=",cookie_string,",list=",cookie_list_table)

    -- 优先处理白名单
    for _, cookie in ipairs(cookie_list_table) do
        repeat
            local value = cookie.value
            local host = cookie.host
            local white = cookie.white
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
            local res, _ = find(cookie_string , value , 'joi');
            if not res then
                break
            end
            -- 白名单，不用后续比对，直接通过
            return true
        until true
    end

    for _, cookie in ipairs(cookie_list_table) do
        repeat
            local value = cookie.value
            local host = cookie.host
            local white = cookie.white
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
            local res, _ = find(cookie_string , value , 'joi');
            if not res then
                break
            end
            -- 命中规则的cookie
            waf_count_cookie.tl_ops_waf_count_incr_cookie_succ()
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_cookie done")

    return true
end


-- 匹配到服务层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_cookie_filter_service_pass = function(service_name)
    if not service_name then
        return true
    end
    
    -- 作用域
    local cookie_scope, _ = cache_cookie:get(tl_ops_constant_waf_cookie.cache_key.scope);
    if not cookie_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if cookie_scope ~= waf_scope.service then
        return true
    end

    -- 是否开启拦截
    local open, _ = cache_cookie:get(tl_ops_constant_waf_cookie.cache_key.open);
    if not open then
        return true
    end
    
    -- 配置列表
    local cookie_list, _ = cache_cookie:get(tl_ops_constant_waf_cookie.cache_key.list);
    if not cookie_list then
        return true
    end
    
    local cookie_list_table = cjson.decode(cookie_list);
    if not cookie_list_table then
        return true
    end

    -- 获取当前cookie
    local cookie_string = ngx.var.http_cookie
    if not cookie_string then
        return true
    end

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_cookie get list ok, scope=",cookie_scope, ",host=",cur_host,",cookie_string=",cookie_string,",list=",cookie_list_table)

    -- 优先处理白名单
    for _, cookie in ipairs(cookie_list_table) do
        repeat
            local value = cookie.value
            local host = cookie.host
            local service = cookie.service
            local white = cookie.white
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
            local res, _ = find(cookie_string , value , 'joi');
            if not res then
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
            -- 白名单，不用后续比对，直接通过
            return true
        until true
    end

    for _, cookie in ipairs(cookie_list_table) do
        repeat
            local value = cookie.value
            local host = cookie.host
            local service = cookie.service
            local white = cookie.white
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
            -- 未命中拦截规则，进行下一个
            local res, _ = find(cookie_string , value , 'joi');
            if not res then
                break
            end
            -- 命中规则的cookie
            waf_count_cookie.tl_ops_waf_count_incr_cookie_succ(service_name, 0, cookie.id)
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_cookie done")

    return true
end


return {
    tl_ops_waf_core_cookie_filter_global_pass = tl_ops_waf_core_cookie_filter_global_pass,
    tl_ops_waf_core_cookie_filter_service_pass = tl_ops_waf_core_cookie_filter_service_pass,
}