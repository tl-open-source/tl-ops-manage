-- tl_ops_waf_core_param
-- en : waf core param black white list impl
-- zn : waf 请求参数黑白名单
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_constant_waf_param = require("constant.tl_ops_constant_waf_param");
local tl_ops_constant_waf_scope = require("constant.tl_ops_constant_waf_scope");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local cache_param = require("cache.tl_ops_cache"):new("tl-ops-waf-param");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_waf_param");
local cjson = require("cjson");

local unescape = ngx.unescape_uri
local find = ngx.re.find


-- 全局拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_param_filter_global_pass = function()
    -- 作用域
    local param_scope, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.scope);
    if not param_scope then
        return false
    end

    -- 根据作用域进行waf拦截
    if param_scope ~= tl_ops_constant_waf_scope.global then
        return false
    end

    -- 是否开启拦截
    local open, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local param_list, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.list);
    if not param_list then
        return false
    end
    
    local param_list_table = cjson.decode(param_list);
    if not param_list_table then
        return false
    end

    -- 获取当前参数
    local args = ngx.req.get_uri_args()
    if not args then
        return true
    end
    
    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_param get list ok, scope=",param_scope, ",host=",cur_host,",param=",args,",list=",param_list_table)

    -- 优先处理白名单
    for _, param in ipairs(param_list_table) do
        repeat
            local value = param.value
            local host = param.host
            local white = param.white
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
            -- 参数k-v对比
            for arg_k ,arg_v in pairs(args) do
                repeat
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(unescape(arg_k .. "=" .. arg_v) , value , 'joi');
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

    for _, param in ipairs(param_list_table) do
        repeat
            local value = param.value
            local host = param.host
            local white = param.white
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
            -- 参数k-v对比
            for arg_k ,arg_v in pairs(args) do
                if type(arg_v) == 'boolean' then
                    if arg_v then
                        arg_v = "true"
                    else
                        arg_v = "false"
                    end
                end
                repeat
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(unescape(arg_k .. "=" .. arg_v) , value , 'joi');
                    if not res then
                        break
                    end
                    -- 命中规则的param
                    return false
                until true
            end
            break
        until true
    end

    tlog:dbg("tl_ops_waf_param done")

    return true
end


-- 匹配到服务层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_param_filter_service_pass = function(service_name)
    if not service_name then
        return false
    end
    
    -- 作用域
    local param_scope, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.scope);
    if not param_scope then
        return false
    end

    -- 根据作用域进行waf拦截
    if param_scope ~= tl_ops_constant_waf_scope.service then
        return false
    end

    -- 是否开启拦截
    local open, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local param_list, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.list);
    if not param_list then
        return false
    end
    
    local param_list_table = cjson.decode(param_list);
    if not param_list_table then
        return false
    end

    -- 获取当前参数
    local args = ngx.req.get_uri_args()
    if not args then
        return true
    end
    
    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_param get list ok, scope=",param_scope, ",host=",cur_host,",param=",args,",list=",param_list_table)

    for _, param in ipairs(param_list_table) do
        repeat
            local value = param.value
            local host = param.host
            local service = param.service
            local white = param.white
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
            -- 参数k-v对比
            for arg_k ,arg_v in pairs(args) do
                repeat
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(unescape(arg_k .. "=" .. arg_v) , value , 'joi');
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

    for _, param in ipairs(param_list_table) do
        repeat
            local value = param.value
            local host = param.host
            local service = param.service
            local white = param.white
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
            -- 参数k-v对比
            for arg_k ,arg_v in pairs(args) do
                repeat
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(unescape(arg_k .. "=" .. arg_v) , value , 'joi');
                    if not res then
                        break
                    end
                    -- 命中规则的param
                    return false
                until true
            end
            break
        until true
    end

    tlog:dbg("tl_ops_waf_param done")

    return true
end


-- 匹配到节点层拦截
-- true : 通过, false : 拦截
local tl_ops_waf_core_param_filter_node_pass = function(service_name, node_id)
    if not service_name or not node_id then
        return false
    end
    
    -- 作用域
    local param_scope, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.scope);
    if not param_scope then
        return false
    end

    -- 根据作用域进行waf拦截
    if param_scope ~= tl_ops_constant_waf_scope.node then
        return false
    end

    -- 是否开启拦截
    local open, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.open);
    if not open then
        return true
    end

    -- 配置列表
    local param_list, _ = cache_param:get(tl_ops_constant_waf_param.cache_key.list);
    if not param_list then
        return false
    end
    
    local param_list_table = cjson.decode(param_list);
    if not param_list_table then
        return false
    end

    -- 获取当前参数
    local args = ngx.req.get_uri_args()
    if not args then
        return true
    end

    local cur_host = ngx.var.host
    if not cur_host then
        return true
    end

    tlog:dbg("tl_ops_waf_param get list ok, scope=",param_scope, ",host=",cur_host,",param=",args,",list=",param_list_table)

    -- 优先处理白名单
    for _, param in ipairs(param_list_table) do
        repeat
            local value = param.value
            local host = param.host
            local service = param.service
            local node = param.node
            local white = param.white
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
            -- 节点为空
            if node == nil or node == '' then
                break
            end
            -- 节点不匹配
            if node ~= node_id then
                break
            end
            -- 参数k-v对比
            for arg_k ,arg_v in pairs(args) do
                repeat
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(unescape(arg_k .. "=" .. arg_v) , value , 'joi');
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

    for _, param in ipairs(param_list_table) do
        repeat
            local value = param.value
            local host = param.host
            local service = param.service
            local node = param.node
            local white = param.white
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
            -- 节点为空
            if node == nil or node == '' then
                break
            end
            -- 节点不匹配
            if node ~= node_id then
                break
            end
            -- 参数k-v对比
            for arg_k ,arg_v in pairs(args) do
                repeat
                    -- 未命中拦截规则，进行下一个
                    local res, _ = find(unescape(arg_k .. "=" .. arg_v) , value , 'joi');
                    if not res then
                        break
                    end
                    -- 命中规则的param
                    return false
                until true
            end
            break
        until true
    end

    tlog:dbg("tl_ops_waf_param done")

    return true
end


return {
    tl_ops_waf_core_param_filter_global_pass = tl_ops_waf_core_param_filter_global_pass,
    tl_ops_waf_core_param_filter_service_pass = tl_ops_waf_core_param_filter_service_pass,
    tl_ops_waf_core_param_filter_node_pass = tl_ops_waf_core_param_filter_node_pass
}