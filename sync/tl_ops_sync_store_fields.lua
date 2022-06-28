-- tl_ops_sync_store_fields
-- en : sync new fileds
-- zn : 同步由于功能迭代引起的模块字段变更。
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

-- constant
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");

local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_balance_api = require("constant.tl_ops_constant_balance_api");
local tl_ops_constant_balance_param = require("constant.tl_ops_constant_balance_param");
local tl_ops_constant_balance_header = require("constant.tl_ops_constant_balance_header");
local tl_ops_constant_balance_cookie = require("constant.tl_ops_constant_balance_cookie");

local tl_ops_constant_waf = require("constant.tl_ops_constant_waf");
local tl_ops_constant_waf_ip = require("constant.tl_ops_constant_waf_ip");
local tl_ops_constant_waf_api = require("constant.tl_ops_constant_waf_api");
local tl_ops_constant_waf_cc = require("constant.tl_ops_constant_waf_cc");
local tl_ops_constant_waf_header = require("constant.tl_ops_constant_waf_header");
local tl_ops_constant_waf_cookie = require("constant.tl_ops_constant_waf_cookie");
local tl_ops_constant_waf_param = require("constant.tl_ops_constant_waf_param");

-- cache
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local cache_limit = require("cache.tl_ops_cache"):new("tl-ops-limit");
local cache_health = require("cache.tl_ops_cache"):new("tl-ops-health");

local cache_balance_api = require("cache.tl_ops_cache"):new("tl-ops-balance-api");
local cache_balance_param = require("cache.tl_ops_cache"):new("tl-ops-balance-param");
local cache_balance_header = require("cache.tl_ops_cache"):new("tl-ops-balance-header");
local cache_balance_cookie = require("cache.tl_ops_cache"):new("tl-ops-balance-cookie");
local cache_balance = require("cache.tl_ops_cache"):new("tl-ops-balance");

local cache_waf_api = require("cache.tl_ops_cache"):new("tl-ops-waf-api");
local cache_waf_ip = require("cache.tl_ops_cache"):new("tl-ops-waf-ip");
local cache_waf_cookie = require("cache.tl_ops_cache"):new("tl-ops-waf-cookie");
local cache_waf_header = require("cache.tl_ops_cache"):new("tl-ops-waf-header");
local cache_waf_cc = require("cache.tl_ops_cache"):new("tl-ops-waf-cc");
local cache_waf_param = require("cache.tl_ops_cache"):new("tl-ops-waf-param");
local cache_waf = require("cache.tl_ops_cache"):new("tl-ops-waf");

-- utils
local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")
local tl_ops_health_check_version = require("health.tl_ops_health_check_version")
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_sync_store_fields");


local _M = {
    _VERSION = '0.01'
}
local mt = { __index = _M }


function _M:new( )
	return setmetatable({}, mt)
end


--+++++++++++++++服务节点数据同步+++++++++++++++--

-- 服务节点数据同步
local tl_ops_sync_store_fields_service = function ()

    local cache_key = tl_ops_constant_service.cache_key.service_list
    local cache_rule_key = tl_ops_constant_service.cache_key.service_rule
    local demo = tl_ops_constant_service.demo

    local data_str, _ = cache_service:get(cache_key);
    if not data_str then
        local res, _ = cache_service:set(cache_key, cjson.encode(tl_ops_constant_service.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_service new store list err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_service:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_service new store data, res=",res)
    end

    local data_rule_str, _ = cache_service:get(cache_rule_key);
    if not data_rule_str then
        local res, _ = cache_service:set(cache_rule_key, tl_ops_constant_service.rule.auto_load)
        if not res then
            tlog:err("tl_ops_sync_store_fields_service new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_service new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_service err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_service start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_service err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_service done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++健康检查数据同步+++++++++++++++--

-- 健康检查数据同步
local tl_ops_sync_store_fields_health = function ()

    local cache_key = tl_ops_constant_health.cache_key.options_list
    local demo = tl_ops_constant_health.demo

    local data_str, _ = cache_health:get(cache_key);
    if not data_str then
        local res, _ = cache_health:set(cache_key, cjson.encode(tl_ops_constant_health.options))
        if not res then
            tlog:err("tl_ops_sync_store_fields_health new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_health:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_health new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_health err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_health start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_health err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    for i = 1, #tl_ops_constant_health.options do
        local option = tl_ops_constant_health.options[i]
        local service_name = option.check_service_name
        if service_name then
            tl_ops_health_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("tl_ops_sync_store_fields_health done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++限流熔断数据同步+++++++++++++++--

-- 熔断数据同步
local tl_ops_sync_store_fields_limit = function ()
    local cache_key = tl_ops_constant_limit.fuse.cache_key.options_list
    local demo = tl_ops_constant_limit.fuse.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(tl_ops_constant_limit.fuse.options))
        if not res then
            tlog:err("tl_ops_sync_store_fields_limit new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_limit new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_limit err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_limit start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_limit err, res=",res,",new=",data)
        return tl_ops_rt.error
    end
    
    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("tl_ops_sync_store_fields_limit done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- 限流数据同步 token
local tl_ops_sync_store_fields_limit_token = function ()
    local cache_key = tl_ops_constant_limit.token.cache_key.options_list
    local demo = tl_ops_constant_limit.token.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(tl_ops_constant_limit.token.options))
        if not res then
            tlog:err("tl_ops_sync_store_fields_limit_token new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_limit_token new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_limit_token err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_limit_token start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_limit_token err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("tl_ops_sync_store_fields_limit_token done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- 限流数据同步 leak
local tl_ops_sync_store_fields_limit_leak = function ()
    local cache_key = tl_ops_constant_limit.leak.cache_key.options_list
    local demo = tl_ops_constant_limit.leak.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(tl_ops_constant_limit.leak.options))
        if not res then
            tlog:err("tl_ops_sync_store_fields_limit_leak new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_limit_leak new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_limit_leak err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_limit_leak start, old=",data)

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

    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end
    
    local res = cache_limit:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_store_fields_limit_leak err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_limit_leak done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++路由数据同步+++++++++++++++--

-- 路由配置数据同步
local tl_ops_sync_store_fields_balance = function ()

    local cache_key = tl_ops_constant_balance.cache_key.options
    local demo = tl_ops_constant_balance.demo

    local data_str, _ = cache_balance:get(cache_key);
    if not data_str then
        local res, _ = cache_balance:set(cache_key, cjson.encode(tl_ops_constant_balance.options))
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_balance new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_balance err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_balance err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- api策略数据同步
local tl_ops_sync_store_fields_balance_api = function ()
    local cache_key_list = tl_ops_constant_balance_api.cache_key.list;
    local cache_key_rule = tl_ops_constant_balance_api.cache_key.rule

    local demo = tl_ops_constant_balance_api.demo

    local data_str, _ = cache_balance_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_api:set(cache_key_list, cjson.encode(tl_ops_constant_balance.api.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_api:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_balance_api new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_api:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_api:set(cache_key_rule, tl_ops_constant_balance.api.rule)
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_api new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_balance_api new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_balance_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_api start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_balance_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_api done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- cookie策略数据同步
local tl_ops_sync_store_fields_balance_cookie = function ()
    local cache_key_list = tl_ops_constant_balance_cookie.cache_key.list
    local cache_key_rule = tl_ops_constant_balance_cookie.cache_key.rule

    local demo = tl_ops_constant_balance_cookie.demo

    local data_str, _ = cache_balance_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_cookie:set(cache_key_list, cjson.encode(tl_ops_constant_balance.cookie.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_cookie:get(cache_key_list);

        tlog:dbg("tl_ops_sync_store_fields_balance_cookie new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_cookie:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_cookie:set(cache_key_rule, tl_ops_constant_balance.cookie.rule)
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_cookie new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_balance_api new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_balance_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_cookie start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_balance_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_cookie done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- header策略数据同步
local tl_ops_sync_store_fields_balance_header = function ()
    local cache_key_list = tl_ops_constant_balance_header.cache_key.list
    local cache_key_rule = tl_ops_constant_balance_header.cache_key.rule

    local demo = tl_ops_constant_balance_header.demo

    local data_str, _ = cache_balance_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_header:set(cache_key_list, cjson.encode(tl_ops_constant_balance.header.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_header:get(cache_key_list);

        tlog:dbg("tl_ops_sync_store_fields_balance_header new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_header:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_header:set(cache_key_rule, tl_ops_constant_balance.header.rule)
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_header new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_balance_header new store rule, res=",res)
    end


    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_balance_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_header start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_balance_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_header done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- param策略数据同步
local tl_ops_sync_store_fields_balance_param = function ()
    local cache_key_list = tl_ops_constant_balance_param.cache_key.list
    local cache_key_rule = tl_ops_constant_balance_param.cache_key.rule

    local demo = tl_ops_constant_balance_param.demo

    local data_str, _ = cache_balance_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_param:set(cache_key_list, cjson.encode(tl_ops_constant_balance.param.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance_param:get(cache_key_list);

        tlog:dbg("tl_ops_sync_store_fields_balance_param new store data, res=",res)
    end

    local data_rule_str, _ = cache_balance_param:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_balance_param:set(cache_key_rule, tl_ops_constant_balance.param.rule)
        if not res then
            tlog:err("tl_ops_sync_store_fields_balance_param new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_balance_param new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_balance_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_param start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_balance_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_balance_param done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

--+++++++++++++++WAF数据同步+++++++++++++++--

-- waf配置数据同步
local tl_ops_sync_store_fields_waf = function ()
    tlog:dbg("xxxx : ",tl_ops_constant_waf)
    local cache_key = tl_ops_constant_waf.cache_key.options
    local demo = tl_ops_constant_waf.demo

    local data_str, _ = cache_waf:get(cache_key);
    if not data_str then
        local res, _ = cache_waf:set(cache_key, cjson.encode(tl_ops_constant_waf.options))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf:get(cache_key);

        tlog:dbg("tl_ops_sync_store_fields_waf new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- api waf规则数据同步
local tl_ops_sync_store_fields_waf_api = function ()
    local cache_key_list = tl_ops_constant_waf_api.cache_key.list;
    local cache_key_scope = tl_ops_constant_waf_api.cache_key.scope
    local cache_key_open = tl_ops_constant_waf_api.cache_key.open

    local demo = tl_ops_constant_waf_api.demo

    local data_str, _ = cache_waf_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_api:set(cache_key_list, cjson.encode(tl_ops_constant_waf.api.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_api:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_waf_api new store data, res=",res)
    end

    local data_scope, _ = cache_waf_api:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_api:set(cache_key_scope, tl_ops_constant_waf.api.scope)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_api new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_api new store scope, res=",res)
    end

    local data_open, _ = cache_waf_api:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_api:set(cache_key_open, tl_ops_constant_waf.api.open)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_api new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_api new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_api start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_api done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- ip waf规则数据同步
local tl_ops_sync_store_fields_waf_ip = function ()
    local cache_key_list = tl_ops_constant_waf_ip.cache_key.list;
    local cache_key_scope = tl_ops_constant_waf_ip.cache_key.scope
    local cache_key_open = tl_ops_constant_waf_ip.cache_key.open

    local demo = tl_ops_constant_waf_ip.demo

    local data_str, _ = cache_waf_ip:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_ip:set(cache_key_list, cjson.encode(tl_ops_constant_waf.ip.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_ip new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_ip:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_waf_ip new store data, res=",res)
    end

    local data_scope, _ = cache_waf_ip:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_ip:set(cache_key_scope, tl_ops_constant_waf.ip.scope)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_ip new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_ip new store scope, res=",res)
    end

    local data_open, _ = cache_waf_ip:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_ip:set(cache_key_open, tl_ops_constant_waf.ip.open)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_ip new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_ip new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf_ip err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_ip start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf_ip err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_ip done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- cookie waf规则数据同步
local tl_ops_sync_store_fields_waf_cookie = function ()
    local cache_key_list = tl_ops_constant_waf_cookie.cache_key.list;
    local cache_key_scope = tl_ops_constant_waf_cookie.cache_key.scope
    local cache_key_open = tl_ops_constant_waf_cookie.cache_key.open

    local demo = tl_ops_constant_waf_cookie.demo

    local data_str, _ = cache_waf_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cookie:set(cache_key_list, cjson.encode(tl_ops_constant_waf.cookie.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_cookie:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_waf_cookie new store data, res=",res)
    end

    local data_scope, _ = cache_waf_cookie:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_cookie:set(cache_key_scope, tl_ops_constant_waf.cookie.scope)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_cookie new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_cookie new store scope, res=",res)
    end

    local data_open, _ = cache_waf_cookie:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_cookie:set(cache_key_open, tl_ops_constant_waf.cookie.open)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_cookie new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_cookie new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_cookie start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_cookie done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- header waf规则数据同步
local tl_ops_sync_store_fields_waf_header = function ()
    local cache_key_list = tl_ops_constant_waf_header.cache_key.list;
    local cache_key_scope = tl_ops_constant_waf_header.cache_key.scope
    local cache_key_open = tl_ops_constant_waf_header.cache_key.open

    local demo = tl_ops_constant_waf_header.demo

    local data_str, _ = cache_waf_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_header:set(cache_key_list, cjson.encode(tl_ops_constant_waf.header.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_header:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_waf_header new store data, res=",res)
    end

    local data_scope, _ = cache_waf_header:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_header:set(cache_key_scope, tl_ops_constant_waf.header.scope)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_header new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_header new store scope, res=",res)
    end

    local data_open, _ = cache_waf_header:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_header:set(cache_key_open, tl_ops_constant_waf.header.open)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_header new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_header new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_header start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_header done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- param waf规则数据同步
local tl_ops_sync_store_fields_waf_param = function ()
    local cache_key_list = tl_ops_constant_waf_param.cache_key.list;
    local cache_key_scope = tl_ops_constant_waf_param.cache_key.scope
    local cache_key_open = tl_ops_constant_waf_param.cache_key.open

    local demo = tl_ops_constant_waf_param.demo

    local data_str, _ = cache_waf_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_param:set(cache_key_list, cjson.encode(tl_ops_constant_waf.param.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_param:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_waf_param new store data, res=",res)
    end

    local data_scope, _ = cache_waf_param:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_param:set(cache_key_scope, tl_ops_constant_waf.param.scope)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_param new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_param new store scope, res=",res)
    end

    local data_open, _ = cache_waf_param:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_param:set(cache_key_open, tl_ops_constant_waf.param.open)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_param new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_param new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_param start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_param done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end

-- cc waf规则数据同步
local tl_ops_sync_store_fields_waf_cc = function ()
    local cache_key_list = tl_ops_constant_waf_cc.cache_key.list;
    local cache_key_scope = tl_ops_constant_waf_cc.cache_key.scope
    local cache_key_open = tl_ops_constant_waf_cc.cache_key.open

    local demo = tl_ops_constant_waf_cc.demo

    local data_str, _ = cache_waf_cc:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cc:set(cache_key_list, cjson.encode(tl_ops_constant_waf.cc.list))
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_cc new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_waf_cc:get(cache_key_list)

        tlog:dbg("tl_ops_sync_store_fields_waf_cc new store data, res=",res)
    end

    local data_scope, _ = cache_waf_cc:get(cache_key_scope);
    if not data_scope then
        local res, _ = cache_waf_cc:set(cache_key_scope, tl_ops_constant_waf.cc.scope)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_cc new store scope err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_cc new store scope, res=",res)
    end

    local data_open, _ = cache_waf_cc:get(cache_key_open);
    if not data_open then
        local res, _ = cache_waf_cc:set(cache_key_open, tl_ops_constant_waf.cc.open)
        if not res then
            tlog:err("tl_ops_sync_store_fields_waf_cc new store open err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_store_fields_waf_cc new store open, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_store_fields_waf_cc err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_cc start, old=",data)

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
        tlog:err("tl_ops_sync_store_fields_waf_cc err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_store_fields_waf_cc done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end



function _M:tl_ops_sync_store_fields_module( module )

    if module == 'service' then
        return tl_ops_sync_store_fields_service()
    end

    if module == 'health' then
        return tl_ops_sync_store_fields_health()
    end

    if module == 'limit' then
        return tl_ops_sync_store_fields_limit()
    end

    if module == 'token' then
        return tl_ops_sync_store_fields_limit_token()
    end

    if module == 'leak' then
        return tl_ops_sync_store_fields_limit_leak()
    end

    if module == 'balance' then
        return tl_ops_sync_store_fields_balance()
    end

    if module == 'balance_api' then
        return tl_ops_sync_store_fields_balance_api()
    end

    if module == 'balance_cookie' then
        return tl_ops_sync_store_fields_balance_cookie()
    end

    if module == 'balance_header' then
        return tl_ops_sync_store_fields_balance_header()
    end

    if module == 'balance_param' then
        return tl_ops_sync_store_fields_balance_param()
    end

    if module == 'waf' then
        return tl_ops_sync_store_fields_waf()
    end

    if module == 'waf_api' then
        return tl_ops_sync_store_fields_waf_api()
    end

    if module == 'waf_ip' then
        return tl_ops_sync_store_fields_waf_ip()
    end
    
    if module == 'waf_header' then
        return tl_ops_sync_store_fields_waf_header()
    end

    if module == 'waf_cookie' then
        return tl_ops_sync_store_fields_waf_cookie()
    end

    if module == 'waf_param' then
        return tl_ops_sync_store_fields_waf_param()
    end

    if module == 'waf_cc' then
        return tl_ops_sync_store_fields_waf_cc()
    end
end


return _M