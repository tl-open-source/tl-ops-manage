-- sync_fields
-- en : sync new fileds
-- zn : 同步由于功能迭代引起的模块字段变更。
-- @author iamtsm
-- @email 1905333456@qq.com

-- constant
local constant_service          =   tlops.constant.service
local constant_health           =   tlops.constant.health
local constant_limit            =   tlops.constant.limit
local constant_balance          =   tlops.constant.balance
local constant_balance_api      =   tlops.constant.balance_api
local constant_balance_body     =   tlops.constant.balance_body
local constant_balance_param    =   tlops.constant.balance_param
local constant_balance_header   =   tlops.constant.balance_header
local constant_balance_cookie   =   tlops.constant.balance_cookie
local constant_waf              =   tlops.constant.waf
local constant_waf_ip           =   tlops.constant.waf_ip
local constant_waf_api          =   tlops.constant.waf_api
local constant_waf_cc           =   tlops.constant.waf_cc
local constant_waf_header       =   tlops.constant.waf_header
local constant_waf_cookie       =   tlops.constant.waf_cookie
local constant_waf_param        =   tlops.constant.waf_param
local constant_plugins_manage   =   tlops.constant.plugins_manage
local tl_ops_rt                 =   tlops.constant.comm.tl_ops_rt;
-- cache
local cache_service             =   tlops.cache.service
local cache_limit               =   tlops.cache.limit
local cache_health              =   tlops.cache.health
local cache_balance_api         =   tlops.cache.balance_api
local cache_balance_body        =   tlops.cache.balance_body
local cache_balance_param       =   tlops.cache.balance_param
local cache_balance_header      =   tlops.cache.balance_header
local cache_balance_cookie      =   tlops.cache.balance_cookie
local cache_balance             =   tlops.cache.balance
local cache_waf_api             =   tlops.cache.waf_api
local cache_waf_ip              =   tlops.cache.waf_ip
local cache_waf_cookie          =   tlops.cache.waf_cookie
local cache_waf_header          =   tlops.cache.waf_header
local cache_waf_cc              =   tlops.cache.waf_cc
local cache_waf_param           =   tlops.cache.waf_param
local cache_waf                 =   tlops.cache.waf
local cache_plugins_manage      =   tlops.cache.plugins_manage
-- utils
local utils                             =   tlops.utils
local tl_ops_limit_fuse_check_version   =   require("limit.fuse.tl_ops_limit_fuse_check_version")
local tl_ops_health_check_version       =   require("health.tl_ops_health_check_version")
local cjson                             =   require("cjson.safe");
cjson.encode_empty_table_as_object(false)
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync");


local _M = {
    _VERSION = '0.01'
}


--+++++++++++++++服务节点数据同步+++++++++++++++--

-- 服务节点数据同步
local sync_fields_service = function ()

    local cache_key = constant_service.cache_key.service_list
    local cache_rule_key = constant_service.cache_key.service_rule
    local demo = constant_service.demo

    local data_str, _ = cache_service:get(cache_key);
    if not data_str then
        local res, _ = cache_service:set(cache_key, cjson.encode(constant_service.list))
        if not res then
            tlog:err("sync_fields_service new store list err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_service:get(cache_key);

        tlog:dbg("sync_fields_service new store data, res=",res)
    end

    local data_rule_str, _ = cache_service:get(cache_rule_key);
    if not data_rule_str then
        local res, _ = cache_service:set(cache_rule_key, constant_service.rule.auto_load)
        if not res then
            tlog:err("sync_fields_service new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_service new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_service err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_service start, old=",data)

    local add_keys = {}

    for service , _ in pairs(data) do
        local nodes = data[service]
        if nodes then
            -- demo fileds check
            for key , _ in pairs(demo) do
                -- data fileds check
                for i = 1, #nodes do
                    -- add keys
                    if nodes[i][key] == nil then
                        nodes[i][key] = demo[key]
                        table.insert(add_keys , key)
                    end
                end
            end
        end
    end

    local res = cache_service:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_service err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_service done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++健康检查数据同步+++++++++++++++--

-- 健康检查数据同步
local sync_fields_health = function ()

    local cache_key = constant_health.cache_key.options_list
    local demo = constant_health.demo

    local data_str, _ = cache_health:get(cache_key);
    if not data_str then
        local res, _ = cache_health:set(cache_key, cjson.encode(constant_health.options))
        if not res then
            tlog:err("sync_fields_health new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_health:get(cache_key);

        tlog:dbg("sync_fields_health new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_health err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_health start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , key)
            end
        end
    end

    local res = cache_health:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_health err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    for i = 1, #constant_health.options do
        local option = constant_health.options[i]
        local service_name = option.check_service_name
        if service_name then
            tl_ops_health_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("sync_fields_health done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++限流熔断数据同步+++++++++++++++--

-- 熔断数据同步
local sync_fields_limit = function ()
    local cache_key = constant_limit.fuse.cache_key.options_list
    local demo = constant_limit.fuse.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(constant_limit.fuse.options))
        if not res then
            tlog:err("sync_fields_limit new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("sync_fields_limit new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_limit err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_limit start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , key)
            end
        end
    end

    local res = cache_limit:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_limit err, res=",res,",new=",data)
        return tl_ops_rt.error
    end
    
    for i = 1, #constant_limit.fuse.options do
        local option = constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("sync_fields_limit done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- 限流数据同步 token
local sync_fields_limit_token = function ()
    local cache_key = constant_limit.token.cache_key.options_list
    local demo = constant_limit.token.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(constant_limit.token.options))
        if not res then
            tlog:err("sync_fields_limit_token new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("sync_fields_limit_token new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_limit_token err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_limit_token start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , key)
            end
        end
    end

    local res = cache_limit:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_limit_token err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    for i = 1, #constant_limit.fuse.options do
        local option = constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("sync_fields_limit_token done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- 限流数据同步 leak
local sync_fields_limit_leak = function ()
    local cache_key = constant_limit.leak.cache_key.options_list
    local demo = constant_limit.leak.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(constant_limit.leak.options))
        if not res then
            tlog:err("sync_fields_limit_leak new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("sync_fields_limit_leak new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_limit_leak err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_limit_leak start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , key)
            end
        end
    end

    for i = 1, #constant_limit.fuse.options do
        local option = constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end
    
    local res = cache_limit:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_limit_leak err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_limit_leak done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++路由数据同步+++++++++++++++--

-- 路由配置数据同步
local sync_fields_balance = function ()

    local cache_keys = {
        service_empty = {
            cache_key = constant_balance.cache_key.service_empty,
            constant = constant_balance.service_empty,
            demo = constant_balance.demo.service_empty
        },
        mode_empty = {
            cache_key = constant_balance.cache_key.mode_empty,
            constant = constant_balance.mode_empty,
            demo = constant_balance.demo.mode_empty
        },
        host_empty = {
            cache_key = constant_balance.cache_key.host_empty,
            constant = constant_balance.host_empty,
            demo = constant_balance.demo.host_empty
        },
        host_pass = {
            cache_key = constant_balance.cache_key.host_pass,
            constant = constant_balance.host_pass,
            demo = constant_balance.demo.host_pass
        },
        token_limit = {
            cache_key = constant_balance.cache_key.token_limit,
            constant = constant_balance.token_limit,
            demo = constant_balance.demo.token_limit
        },
        leak_limit = {
            cache_key = constant_balance.cache_key.leak_limit,
            constant = constant_balance.leak_limit,
            demo = constant_balance.demo.leak_limit
        },
        offline = {
            cache_key = constant_balance.cache_key.offline,
            constant = constant_balance.offline,
            demo = constant_balance.demo.offline
        }
    }


    for key, obj in pairs(cache_keys) do
        local cache_key = obj.cache_key
        local constant_data = obj.constant
        local demo = obj.demo

        local data_str, _ = cache_balance:get(cache_key);
        if not data_str then
            local res, _ = cache_balance:set(cache_key, cjson.encode(constant_data))
            if not res then
                tlog:err("sync_fields_balance new store err, cache_key=",cache_key,",res=",res)
                break
            end
    
            data_str, _ = cache_balance:get(cache_key);
    
            tlog:dbg("sync_fields_balance new store,  cache_key=",cache_key,",res=",res)
        end
    
        local data = cjson.decode(data_str);
        if not data and type(data) ~= 'table' then
            tlog:err("sync_fields_balance err,  cache_key=",cache_key,",old=",data)
            break
        end
    
        tlog:dbg("sync_fields_balance start,  cache_key=",cache_key,",old=",data)
    
        local add_keys = {}
    
        -- demo fileds check
        for key , _ in pairs(demo) do
            -- data fileds check
             -- add keys
             if data[key] == nil then
                data[key] = demo[key]
                table.insert(add_keys , key)
            end
        end
    
        local res = cache_balance:set(cache_key, cjson.encode(data))
        if not res then
            tlog:err("sync_fields_balance err,  cache_key=",cache_key,",res=",res,",new=",data)
            break
        end
    
        tlog:dbg("sync_fields_balance done,  cache_key=",cache_key,",new=",data,",add_keys=",add_keys)
    end

    return tl_ops_rt.ok
end

-- api策略数据同步
local sync_fields_balance_api = function ()
    local cache_key_list = constant_balance_api.cache_key.list;
    local cache_key_rule = constant_balance_api.cache_key.rule

    local demo = constant_balance_api.demo

    local data_str, _ = cache_balance_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_api:set(cache_key_list, cjson.encode(constant_balance.api.list))
        if not res then
            tlog:err("sync_fields_balance_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_api:get(cache_key_list)

        tlog:dbg("sync_fields_balance_api new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_api:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_api:set(cache_key_rule, constant_balance.api.rule)
        if not res then
            tlog:err("sync_fields_balance_api new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_balance_api new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_balance_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_api start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo.point) do
        -- data fileds check
        for i = 1, #data.point do
            -- add keys
            if data.point[i][key] == nil then
                data.point[i][key] = demo.point[key]
                table.insert(add_keys , {
                    key = data.point[i][key]
                })
            end
        end
    end

    -- demo fileds check
    for key , _ in pairs(demo.random) do
        -- data fileds check
        for i = 1, #data.random do
            -- add keys
            if data.random[i][key] == nil then
                data.random[i][key] = demo.random[key]
                table.insert(add_keys , {
                    key = data.random[i][key]
                })
            end
        end
    end

    local res = cache_balance_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_balance_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_api done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- post body策略数据同步
local sync_fields_balance_body = function ()
    local cache_key_list = constant_balance_body.cache_key.list;
    local cache_key_rule = constant_balance_body.cache_key.rule

    local demo = constant_balance_body.demo

    local data_str, _ = cache_balance_body:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_body:set(cache_key_list, cjson.encode(constant_balance.body.list))
        if not res then
            tlog:err("sync_fields_balance_body new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_body:get(cache_key_list)

        tlog:dbg("sync_fields_balance_body new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_body:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_body:set(cache_key_rule, constant_balance.body.rule)
        if not res then
            tlog:err("sync_fields_balance_body new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_balance_body new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_balance_body err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_body start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo.point) do
        -- data fileds check
        for i = 1, #data.point do
            -- add keys
            if data.point[i][key] == nil then
                data.point[i][key] = demo.point[key]
                table.insert(add_keys , {
                    key = data.point[i][key]
                })
            end
        end
    end

    -- demo fileds check
    for key , _ in pairs(demo.random) do
        -- data fileds check
        for i = 1, #data.random do
            -- add keys
            if data.random[i][key] == nil then
                data.random[i][key] = demo.random[key]
                table.insert(add_keys , {
                    key = data.random[i][key]
                })
            end
        end
    end

    local res = cache_balance_body:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_balance_body err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_body done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- cookie策略数据同步
local sync_fields_balance_cookie = function ()
    local cache_key_list = constant_balance_cookie.cache_key.list
    local cache_key_rule = constant_balance_cookie.cache_key.rule

    local demo = constant_balance_cookie.demo

    local data_str, _ = cache_balance_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_cookie:set(cache_key_list, cjson.encode(constant_balance.cookie.list))
        if not res then
            tlog:err("sync_fields_balance_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_cookie:get(cache_key_list);

        tlog:dbg("sync_fields_balance_cookie new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_cookie:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_cookie:set(cache_key_rule, constant_balance.cookie.rule)
        if not res then
            tlog:err("sync_fields_balance_cookie new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_balance_api new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_balance_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_cookie start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo.point) do
        -- data fileds check
        for i = 1, #data.point do
            -- add keys
            if data.point[i][key] == nil then
                data.point[i][key] = demo.point[key]
                table.insert(add_keys , {
                    key = data.point[i][key]
                })
            end
        end
    end

    -- demo fileds check
    for key , _ in pairs(demo.random) do
        -- data fileds check
        for i = 1, #data.random do
            -- add keys
            if data.random[i][key] == nil then
                data.random[i][key] = demo.random[key]
                table.insert(add_keys , {
                    key = data.random[i][key]
                })
            end
        end
    end

    local res = cache_balance_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_balance_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_cookie done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- header策略数据同步
local sync_fields_balance_header = function ()
    local cache_key_list = constant_balance_header.cache_key.list
    local cache_key_rule = constant_balance_header.cache_key.rule

    local demo = constant_balance_header.demo

    local data_str, _ = cache_balance_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_header:set(cache_key_list, cjson.encode(constant_balance.header.list))
        if not res then
            tlog:err("sync_fields_balance_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_header:get(cache_key_list);

        tlog:dbg("sync_fields_balance_header new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_header:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_header:set(cache_key_rule, constant_balance.header.rule)
        if not res then
            tlog:err("sync_fields_balance_header new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_balance_header new store rule, res=",res)
    end


    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_balance_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_header start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo.point) do
        -- data fileds check
        for i = 1, #data.point do
            -- add keys
            if data.point[i][key] == nil then
                data.point[i][key] = demo.point[key]
                table.insert(add_keys , {
                    key = data.point[i][key]
                })
            end
        end
    end

    -- demo fileds check
    for key , _ in pairs(demo.random) do
        -- data fileds check
        for i = 1, #data.random do
            -- add keys
            if data.random[i][key] == nil then
                data.random[i][key] = demo.random[key]
                table.insert(add_keys , {
                    key = data.random[i][key]
                })
            end
        end
    end

    local res = cache_balance_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_balance_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_header done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- param策略数据同步
local sync_fields_balance_param = function ()
    local cache_key_list = constant_balance_param.cache_key.list
    local cache_key_rule = constant_balance_param.cache_key.rule

    local demo = constant_balance_param.demo

    local data_str, _ = cache_balance_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_param:set(cache_key_list, cjson.encode(constant_balance.param.list))
        if not res then
            tlog:err("sync_fields_balance_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_param:get(cache_key_list);

        tlog:dbg("sync_fields_balance_param new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_param:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_param:set(cache_key_rule, constant_balance.param.rule)
        if not res then
            tlog:err("sync_fields_balance_param new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_balance_param new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_balance_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_param start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo.point) do
        -- data fileds check
        for i = 1, #data.point do
            -- add keys
            if data.point[i][key] == nil then
                data.point[i][key] = demo.point[key]
                table.insert(add_keys ,{
                    key = data.point[i][key]
                })
            end
        end
    end

    -- demo fileds check
    for key , _ in pairs(demo.random) do
        -- data fileds check
        for i = 1, #data.random do
            -- add keys
            if data.random[i][key] == nil then
                data.random[i][key] = demo.random[key]
                table.insert(add_keys , {
                    key = data.random[i][key]
                })
            end
        end
    end

    local res = cache_balance_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_balance_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_balance_param done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++WAF数据同步+++++++++++++++--

-- waf配置数据同步
local sync_fields_waf = function ()

    local cache_keys = {
        waf_ip = {
            cache_key = constant_waf.cache_key.waf_ip,
            constant = constant_waf.waf_ip,
            demo = constant_waf.demo.waf_ip
        },
        waf_api = {
            cache_key = constant_waf.cache_key.waf_api,
            constant = constant_waf.waf_api,
            demo = constant_waf.demo.waf_api
        },
        waf_cc = {
            cache_key = constant_waf.cache_key.waf_cc,
            constant = constant_waf.waf_cc,
            demo = constant_waf.demo.waf_cc
        },
        waf_header = {
            cache_key = constant_waf.cache_key.waf_header,
            constant = constant_waf.waf_header,
            demo = constant_waf.demo.waf_header
        },
        waf_cookie = {
            cache_key = constant_waf.cache_key.waf_cookie,
            constant = constant_waf.waf_cookie,
            demo = constant_waf.demo.waf_cookie
        },
        waf_param = {
            cache_key = constant_waf.cache_key.waf_param,
            constant = constant_waf.waf_param,
            demo = constant_waf.demo.waf_param
        }
    }

    for key, obj in pairs(cache_keys) do
        local cache_key = obj.cache_key
        local constant_data = obj.constant
        local demo = obj.demo

        local data_str, _ = cache_waf:get(cache_key);
        if not data_str then
            local res, _ = cache_waf:set(cache_key, cjson.encode(constant_data))
            if not res then
                tlog:err("sync_fields_waf new store err, cache_key=",cache_key,",res=",res)
                break
            end
    
            data_str, _ = cache_waf:get(cache_key);
    
            tlog:dbg("sync_fields_waf new store,  cache_key=",cache_key,",res=",res)
        end
    
        local data = cjson.decode(data_str);
        if not data and type(data) ~= 'table' then
            tlog:err("sync_fields_waf err,  cache_key=",cache_key,",old=",data)
            break
        end
    
        tlog:dbg("sync_fields_waf start,  cache_key=",cache_key,",old=",data)
    
        local add_keys = {}
    
        -- demo fileds check
        for key , _ in pairs(demo) do
            -- data fileds check
             -- add keys
             if data[key] == nil then
                data[key] = demo[key]
                table.insert(add_keys , key)
            end
        end
    
        local res = cache_waf:set(cache_key, cjson.encode(data))
        if not res then
            tlog:err("sync_fields_waf err,  cache_key=",cache_key,",res=",res,",new=",data)
            break
        end
    
        tlog:dbg("sync_fields_waf done,  cache_key=",cache_key,",new=",data,",add_keys=",add_keys)
    end
    
    return tl_ops_rt.ok
end

-- api waf规则数据同步
local sync_fields_waf_api = function ()
    local cache_key_list = constant_waf_api.cache_key.list;
    local cache_key_scope = constant_waf_api.cache_key.scope
    local cache_key_open = constant_waf_api.cache_key.open

    local demo = constant_waf_api.demo

    local data_str, _ = cache_waf_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_api:set(cache_key_list, cjson.encode(constant_waf.api.list))
        if not res then
            tlog:err("sync_fields_waf_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_api:get(cache_key_list)

        tlog:dbg("sync_fields_waf_api new store data, res=",res)
    end

    local data_scope, _ = cache_waf_api:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_api:set(cache_key_scope, constant_waf.api.scope)
        if not res then
            tlog:err("sync_fields_waf_api new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_api new store scope, res=",res)
    end

    local data_open, _ = cache_waf_api:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_api:set(cache_key_open, constant_waf.api.open)
        if not res then
            tlog:err("sync_fields_waf_api new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_api new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_waf_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_api start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_waf_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_waf_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_api done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- ip waf规则数据同步
local sync_fields_waf_ip = function ()
    local cache_key_list = constant_waf_ip.cache_key.list;
    local cache_key_scope = constant_waf_ip.cache_key.scope
    local cache_key_open = constant_waf_ip.cache_key.open

    local demo = constant_waf_ip.demo

    local data_str, _ = cache_waf_ip:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_ip:set(cache_key_list, cjson.encode(constant_waf.ip.list))
        if not res then
            tlog:err("sync_fields_waf_ip new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_ip:get(cache_key_list)

        tlog:dbg("sync_fields_waf_ip new store data, res=",res)
    end

    local data_scope, _ = cache_waf_ip:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_ip:set(cache_key_scope, constant_waf.ip.scope)
        if not res then
            tlog:err("sync_fields_waf_ip new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_ip new store scope, res=",res)
    end

    local data_open, _ = cache_waf_ip:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_ip:set(cache_key_open, constant_waf.ip.open)
        if not res then
            tlog:err("sync_fields_waf_ip new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_ip new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_waf_ip err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_ip start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_waf_ip:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_waf_ip err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_ip done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- cookie waf规则数据同步
local sync_fields_waf_cookie = function ()
    local cache_key_list = constant_waf_cookie.cache_key.list;
    local cache_key_scope = constant_waf_cookie.cache_key.scope
    local cache_key_open = constant_waf_cookie.cache_key.open

    local demo = constant_waf_cookie.demo

    local data_str, _ = cache_waf_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cookie:set(cache_key_list, cjson.encode(constant_waf.cookie.list))
        if not res then
            tlog:err("sync_fields_waf_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_cookie:get(cache_key_list)

        tlog:dbg("sync_fields_waf_cookie new store data, res=",res)
    end

    local data_scope, _ = cache_waf_cookie:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_cookie:set(cache_key_scope, constant_waf.cookie.scope)
        if not res then
            tlog:err("sync_fields_waf_cookie new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_cookie new store scope, res=",res)
    end

    local data_open, _ = cache_waf_cookie:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_cookie:set(cache_key_open, constant_waf.cookie.open)
        if not res then
            tlog:err("sync_fields_waf_cookie new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_cookie new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_waf_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_cookie start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_waf_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_waf_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_cookie done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- header waf规则数据同步
local sync_fields_waf_header = function ()
    local cache_key_list = constant_waf_header.cache_key.list;
    local cache_key_scope = constant_waf_header.cache_key.scope
    local cache_key_open = constant_waf_header.cache_key.open

    local demo = constant_waf_header.demo

    local data_str, _ = cache_waf_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_header:set(cache_key_list, cjson.encode(constant_waf.header.list))
        if not res then
            tlog:err("sync_fields_waf_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_header:get(cache_key_list)

        tlog:dbg("sync_fields_waf_header new store data, res=",res)
    end

    local data_scope, _ = cache_waf_header:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_header:set(cache_key_scope, constant_waf.header.scope)
        if not res then
            tlog:err("sync_fields_waf_header new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_header new store scope, res=",res)
    end

    local data_open, _ = cache_waf_header:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_header:set(cache_key_open, constant_waf.header.open)
        if not res then
            tlog:err("sync_fields_waf_header new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_header new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_waf_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_header start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_waf_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_waf_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_header done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- param waf规则数据同步
local sync_fields_waf_param = function ()
    local cache_key_list = constant_waf_param.cache_key.list;
    local cache_key_scope = constant_waf_param.cache_key.scope
    local cache_key_open = constant_waf_param.cache_key.open

    local demo = constant_waf_param.demo

    local data_str, _ = cache_waf_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_param:set(cache_key_list, cjson.encode(constant_waf.param.list))
        if not res then
            tlog:err("sync_fields_waf_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_param:get(cache_key_list)

        tlog:dbg("sync_fields_waf_param new store data, res=",res)
    end

    local data_scope, _ = cache_waf_param:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_param:set(cache_key_scope, constant_waf.param.scope)
        if not res then
            tlog:err("sync_fields_waf_param new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_param new store scope, res=",res)
    end

    local data_open, _ = cache_waf_param:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_param:set(cache_key_open, constant_waf.param.open)
        if not res then
            tlog:err("sync_fields_waf_param new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_param new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_waf_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_param start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_waf_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_waf_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_param done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- cc waf规则数据同步
local sync_fields_waf_cc = function ()
    local cache_key_list = constant_waf_cc.cache_key.list;
    local cache_key_scope = constant_waf_cc.cache_key.scope
    local cache_key_open = constant_waf_cc.cache_key.open

    local demo = constant_waf_cc.demo

    local data_str, _ = cache_waf_cc:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cc:set(cache_key_list, cjson.encode(constant_waf.cc.list))
        if not res then
            tlog:err("sync_fields_waf_cc new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_cc:get(cache_key_list)

        tlog:dbg("sync_fields_waf_cc new store data, res=",res)
    end

    local data_scope, _ = cache_waf_cc:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_cc:set(cache_key_scope, constant_waf.cc.scope)
        if not res then
            tlog:err("sync_fields_waf_cc new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_cc new store scope, res=",res)
    end

    local data_open, _ = cache_waf_cc:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_cc:set(cache_key_open, constant_waf.cc.open)
        if not res then
            tlog:err("sync_fields_waf_cc new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_fields_waf_cc new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_waf_cc err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_cc start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_waf_cc:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_waf_cc err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_waf_cc done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


--+++++++++++++++插件管理列表数据同步+++++++++++++++--

-- 插件管理列表
local sync_fields_plugins_manage = function ()
    local cache_key_list = constant_plugins_manage.cache_key.list;
    local constant = constant_plugins_manage.list;
    local demo = constant_plugins_manage.demo

    local data_str, _ = cache_plugins_manage:get(cache_key_list);
    if not data_str then
        local res, _ = cache_plugins_manage:set(cache_key_list, cjson.encode(constant))
        if not res then
            tlog:err("sync_fields_plugins_manage new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_plugins_manage:get(cache_key_list)

        tlog:dbg("sync_fields_plugins_manage new store data, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_fields_plugins_manage err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_plugins_manage start, old=",data)

    local add_keys = {}

    -- demo fileds check
    for key , _ in pairs(demo) do
        -- data fileds check
        for i = 1, #data do
            -- add keys
            if data[i][key] == nil then
                data[i][key] = demo[key]
                table.insert(add_keys , {
                    key = data[i][key]
                })
            end
        end
    end

    local res = cache_plugins_manage:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_fields_plugins_manage err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_fields_plugins_manage done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


--+++++++++++++++单个插件数据同步+++++++++++++++--

-- 获取某个插件
local sync_fields_get_plugin = function(name)
    for i = 1, #tlops.plugins do
        local plugin = tlops.plugins[i]
        if plugin.name == name then
            return plugin
        end
    end
    return nil
end


-- 插件静态配置数据
local sync_fields_plugin = function (module)
    local plugin = sync_fields_get_plugin(module)
    if not plugin then
        tlog:err("sync_fields_plugin not plugin, module=",module)
        return tl_ops_rt.error
    end

    if type(plugin.func.sync_fields) == 'function' then
        local ok, _ = plugin.func:sync_fields()
        if not ok then
            tlog:err("sync_fields_plugin sync_fields err, module=",module,",err=",_)
            return tl_ops_rt.error
        end
    end

    tlog:dbg("sync_fields_plugin done, module=",module, ",plugin=",plugin)

    return tl_ops_rt.ok
end


function _M:sync_fields_module( module )

    if module == 'service' then
        return sync_fields_service()
    elseif module == 'health' then
        return sync_fields_health()
    elseif module == 'limit' then
        sync_fields_limit_token()
        sync_fields_limit_leak()
        return sync_fields_limit()
    elseif module == 'balance' then
        return sync_fields_balance()
    elseif module == 'balance_api' then
        return sync_fields_balance_api()
    elseif module == 'balance_body' then
        return sync_fields_balance_body()
    elseif module == 'balance_cookie' then
        return sync_fields_balance_cookie()
    elseif module == 'balance_header' then
        return sync_fields_balance_header()
    elseif module == 'balance_param' then
        return sync_fields_balance_param()
    elseif module == 'waf' then
        return sync_fields_waf()
    elseif module == 'waf_api' then
        return sync_fields_waf_api()
    elseif module == 'waf_ip' then
        return sync_fields_waf_ip()
    elseif module == 'waf_header' then
        return sync_fields_waf_header()
    elseif module == 'waf_cookie' then
        return sync_fields_waf_cookie()
    elseif module == 'waf_param' then
        return sync_fields_waf_param()
    elseif module == 'waf_cc' then
        return sync_fields_waf_cc()
    elseif module == 'plugins_manage' then
        return sync_fields_plugins_manage()
    else 
        -- plugin
        return sync_fields_plugin(module)
    end
end


return _M