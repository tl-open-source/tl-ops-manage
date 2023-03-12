-- tl_ops_waf_core_cc
-- en : waf core cc impl
-- zn : waf cc防护
-- @author iamtsm
-- @email 1905333456@qq.com

local waf_count_cc              = require("waf.count.tl_ops_waf_count_cc")
local tl_ops_constant_waf_cc    = require("constant.tl_ops_constant_waf_cc");
local waf_scope                 = require("constant.tl_ops_constant_comm").tl_ops_waf_scope;
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local cache_cc                  = require("cache.tl_ops_cache_core"):new("tl-ops-waf-cc");
local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_waf_cc");
local find                      = ngx.re.find
local cjson                     = require("cjson.safe");
local shared_waf                = ngx.shared.tlopswaf
local MAX_URL_LEN               = 50

-- 全局拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_cc_filter_global_pass = function()
    -- 作用域
    local cc_scope, _ = cache_cc:get(tl_ops_constant_waf_cc.cache_key.scope);
    if not cc_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if cc_scope ~= waf_scope.global then
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

    tlog:dbg("tl_ops_waf_cc get list ok, scope=",cc_scope, ",host=",cur_host,",cc_key=",cc_key,",list=",cc_list_table)

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
            waf_count_cc.tl_ops_waf_count_incr_cc_succ()
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_cc done")

    return true
end


-- 匹配到服务层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_cc_filter_service_pass = function(service_name)
    if not service_name then
        return true
    end
    
    -- 作用域
    local cc_scope, _ = cache_cc:get(tl_ops_constant_waf_cc.cache_key.scope);
    if not cc_scope then
        return true
    end

    -- 根据作用域进行waf拦截
    if cc_scope ~= waf_scope.service then
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

    tlog:dbg("tl_ops_waf_cc get list ok, scope=",cc_scope, ",host=",cur_host,",cc_key=",cc_key,",list=",cc_list_table)

    for _, cc in ipairs(cc_list_table) do
        repeat
            local host = cc.host
            local service = cc.service
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
            -- 服务为空
            if service == nil or service == '' then
                break
            end
            -- 服务不匹配
            if service ~= service_name then
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
            waf_count_cc.tl_ops_waf_count_incr_cc_succ(service_name, 0, cc.id)
            return false
        until true
    end

    tlog:dbg("tl_ops_waf_cc done")

    return true
end



return {
    tl_ops_waf_core_cc_filter_global_pass = tl_ops_waf_core_cc_filter_global_pass,
    tl_ops_waf_core_cc_filter_service_pass = tl_ops_waf_core_cc_filter_service_pass,
}