-- tl_ops_waf_core_ip
-- en : waf core ip black white list impl
-- zn : waf ip黑白名单
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_constant_waf_ip    = require("constant.tl_ops_constant_waf_ip");
local waf_scope                 = require("constant.tl_ops_constant_comm").tl_ops_waf_scope;
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local waf_count_ip              = require("waf.count.tl_ops_waf_count_ip")
local cache_ip                  = require("cache.tl_ops_cache_core"):new("tl-ops-waf-ip");
local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_waf_ip");
local find                      = ngx.re.find
local cjson                     = require("cjson.safe");

-- 全局拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_ip_filter_global_pass = function()
    -- 作用域
    local ip_scope, _ = cache_ip:get(tl_ops_constant_waf_ip.cache_key.scope);
    if not ip_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if ip_scope ~= waf_scope.global then
        return true
    end

    -- 是否开启拦截
    local open, _ = cache_ip:get(tl_ops_constant_waf_ip.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local ip_list, _ = cache_ip:get(tl_ops_constant_waf_ip.cache_key.list);
    if not ip_list then
        return true
    end
    
    local ip_list_table = cjson.decode(ip_list);
    if not ip_list_table then
        return true
    end

    -- 获取当前ip
    local cur_ip = tl_ops_utils_func:get_req_ip();
    if not cur_ip then
        return true
    end

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_ip get list ok, scope=",ip_scope, ",host=",cur_host,",ip=",cur_ip,",list=",ip_list_table)

    -- 优先处理白名单
    for _, ip in ipairs(ip_list_table) do
        repeat
            local value = ip.value
            local host = ip.host
            local white = ip.white
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
            local res, _ = find(cur_ip , value , 'joi');
            if not res then
                break
            end
            -- 白名单，不用后续比对，直接通过
            return true
        until true
    end

    for _, ip in ipairs(ip_list_table) do
        repeat
            local value = ip.value
            local host = ip.host
            local white = ip.white
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
            local res, _ = find(cur_ip , value , 'joi');
            if not res then
                break
            end
            -- 命中规则的ip
            waf_count_ip.tl_ops_waf_count_incr_ip_succ()
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_ip done")
    
    return true
end


-- 匹配到服务层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_ip_filter_service_pass = function(service_name, node_id)
    if not service_name or node_id == nil then
        return true
    end
    
    -- 作用域
    local ip_scope, _ = cache_ip:get(tl_ops_constant_waf_ip.cache_key.scope);
    if not ip_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if ip_scope ~= waf_scope.service then
        return true
    end

    -- 是否开启拦截
    local open, _ = cache_ip:get(tl_ops_constant_waf_ip.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local ip_list, _ = cache_ip:get(tl_ops_constant_waf_ip.cache_key.list);
    if not ip_list then
        return true
    end
    
    local ip_list_table = cjson.decode(ip_list);
    if not ip_list_table then
        return true
    end

    -- 获取当前ip
    local cur_ip = tl_ops_utils_func:get_req_ip();
    if not cur_ip then
        return true
    end

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_ip get list ok, scope=",ip_scope, ",host=",cur_host,",ip=",cur_ip,",list=",ip_list_table)

    -- 优先处理白名单
    for _, ip in ipairs(ip_list_table) do
        repeat
            local value = ip.value
            local host = ip.host
            local service = ip.service
            local white = ip.white
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
            -- 未命中拦截规则，进行下一个
            local res, _ = find(cur_ip , value , 'joi');
            if not res then
                break
            end
            -- 白名单，不用后续比对，直接通过
            return true
        until true
    end


    for _, ip in ipairs(ip_list_table) do
        repeat
            local value = ip.value
            local host = ip.host
            local service = ip.service
            local white = ip.white
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
            local res, _ = find(cur_ip , value , 'joi');
            if not res then
                break
            end
            -- 命中规则的ip
            waf_count_ip.tl_ops_waf_count_incr_ip_succ(service_name, 0, ip.id)
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_ip done")

    return true
end


return {
    tl_ops_waf_core_ip_filter_global_pass = tl_ops_waf_core_ip_filter_global_pass,
    tl_ops_waf_core_ip_filter_service_pass = tl_ops_waf_core_ip_filter_service_pass,
}