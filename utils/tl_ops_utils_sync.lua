-- tl_ops_utils
-- en : sync new fileds
-- zn : 同步由于功能迭代引起的模块字段变更。
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_api = require("constant.tl_ops_constant_api");
local tl_ops_constant_param = require("constant.tl_ops_constant_param");
local tl_ops_constant_header = require("constant.tl_ops_constant_header");
local tl_ops_constant_cookie = require("constant.tl_ops_constant_cookie");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");

local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local cache_limit = require("cache.tl_ops_cache"):new("tl-ops-limit");
local cache_health = require("cache.tl_ops_cache"):new("tl-ops-health");
local cache_api = require("cache.tl_ops_cache"):new("tl-ops-api");
local cache_param = require("cache.tl_ops_cache"):new("tl-ops-param");
local cache_header = require("cache.tl_ops_cache"):new("tl-ops-header");
local cache_cookie = require("cache.tl_ops_cache"):new("tl-ops-cookie");
local cache_balance = require("cache.tl_ops_cache"):new("tl-ops-balance");

local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")
local tl_ops_health_check_version = require("health.tl_ops_health_check_version")

local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_utils_sync");


-- 服务节点数据同步
local tl_ops_utils_sync_service = function ()

    local cache_key = tl_ops_constant_service.cache_key.service_list
    local cache_rule_key = tl_ops_constant_service.cache_key.service_rule
    local demo = tl_ops_constant_service.demo

    local data_str, _ = cache_service:get(cache_key);
    if not data_str then
        local res, _ = cache_service:set(cache_key, cjson.encode(tl_ops_constant_service.list))
        if not res then
            tlog:err("tl_ops_utils_sync_service new store list err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_service:get(cache_key);

        tlog:dbg("tl_ops_utils_sync_service new store data, res=",res)
    end

    local data_rule_str, _ = cache_service:get(cache_rule_key);
    if not data_rule_str then
        local res, _ = cache_service:set(cache_rule_key, tl_ops_constant_service.rule.auto_load)
        if not res then
            tlog:err("tl_ops_utils_sync_service new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_utils_sync_service new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_service err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_service start, old=",data)

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
        tlog:err("tl_ops_utils_sync_service err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_service done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- 健康检查数据同步
local tl_ops_utils_sync_health = function ()

    local cache_key = tl_ops_constant_health.cache_key.options_list
    local demo = tl_ops_constant_health.demo

    local data_str, _ = cache_health:get(cache_key);
    if not data_str then
        local res, _ = cache_health:set(cache_key, cjson.encode(tl_ops_constant_health.options))
        if not res then
            tlog:err("tl_ops_utils_sync_health new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_health:get(cache_key);

        tlog:dbg("tl_ops_utils_sync_health new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_health err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_health start, old=",data)

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
        tlog:err("tl_ops_utils_sync_health err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    for i = 1, #tl_ops_constant_health.options do
        local option = tl_ops_constant_health.options[i]
        local service_name = option.check_service_name
        if service_name then
            tl_ops_health_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("tl_ops_utils_sync_health done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- 熔断数据同步
local tl_ops_utils_sync_limit = function ()
    local cache_key = tl_ops_constant_limit.fuse.cache_key.options_list
    local demo = tl_ops_constant_limit.fuse.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(tl_ops_constant_limit.fuse.options))
        if not res then
            tlog:err("tl_ops_utils_sync_limit new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("tl_ops_utils_sync_limit new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_limit err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_limit start, old=",data)

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
        tlog:err("tl_ops_utils_sync_limit err, res=",res,",new=",data)
        return tl_ops_rt.error
    end
    
    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("tl_ops_utils_sync_limit done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- 限流数据同步
local tl_ops_utils_sync_limit_token = function ()
    local cache_key = tl_ops_constant_limit.token.cache_key.options_list
    local demo = tl_ops_constant_limit.token.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(tl_ops_constant_limit.token.options))
        if not res then
            tlog:err("tl_ops_utils_sync_limit_token new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("tl_ops_utils_sync_limit_token new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_limit_token err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_limit_token start, old=",data)

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
        tlog:err("tl_ops_utils_sync_limit_token err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end

    tlog:dbg("tl_ops_utils_sync_limit_token done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- 限流数据同步
local tl_ops_utils_sync_limit_leak = function ()
    local cache_key = tl_ops_constant_limit.leak.cache_key.options_list
    local demo = tl_ops_constant_limit.leak.demo

    local data_str, _ = cache_limit:get(cache_key);
    if not data_str then
        local res, _ = cache_limit:set(cache_key, cjson.encode(tl_ops_constant_limit.leak.options))
        if not res then
            tlog:err("tl_ops_utils_sync_limit_leak new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_limit:get(cache_key);

        tlog:dbg("tl_ops_utils_sync_limit_leak new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_limit_leak err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_limit_leak start, old=",data)

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
        tlog:err("tl_ops_utils_sync_limit_leak err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_limit_leak done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- 路由配置数据同步
local tl_ops_utils_sync_balance = function ()

    local cache_key = tl_ops_constant_balance.cache_key.options
    local demo = tl_ops_constant_balance.demo

    local data_str, _ = cache_balance:get(cache_key);
    if not data_str then
        local res, _ = cache_balance:set(cache_key, cjson.encode(tl_ops_constant_balance.options))
        if not res then
            tlog:err("tl_ops_utils_sync_balance new store err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_balance:get(cache_key);

        tlog:dbg("tl_ops_utils_sync_balance new store, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_balance err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_balance start, old=",data)

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
        tlog:err("tl_ops_utils_sync_balance err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_balance done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- api策略数据同步
local tl_ops_utils_sync_api = function ()
    local cache_key_list = tl_ops_constant_api.cache_key.list;
    local cache_key_rule = tl_ops_constant_api.cache_key.rule

    local demo = tl_ops_constant_api.demo

    local data_str, _ = cache_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_api:set(cache_key_list, cjson.encode(tl_ops_constant_balance.api.list))
        if not res then
            tlog:err("tl_ops_utils_sync_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_api:get(cache_key_list)

        tlog:dbg("tl_ops_utils_sync_api new store data, res=",res)
    end

    local data_rule_str, _ = cache_api:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_api:set(cache_key_rule, tl_ops_constant_balance.api.rule)
        if not res then
            tlog:err("tl_ops_utils_sync_api new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_utils_sync_api new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_api start, old=",data)

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

    local res = cache_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_utils_sync_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_api done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- cookie策略数据同步
local tl_ops_utils_sync_cookie = function ()
    local cache_key_list = tl_ops_constant_cookie.cache_key.list
    local cache_key_rule = tl_ops_constant_cookie.cache_key.rule

    local demo = tl_ops_constant_cookie.demo

    local data_str, _ = cache_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_cookie:set(cache_key_list, cjson.encode(tl_ops_constant_balance.cookie.list))
        if not res then
            tlog:err("tl_ops_utils_sync_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_cookie:get(cache_key_list);

        tlog:dbg("tl_ops_utils_sync_cookie new store data, res=",res)
    end

    local data_rule_str, _ = cache_cookie:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_cookie:set(cache_key_rule, tl_ops_constant_balance.cookie.rule)
        if not res then
            tlog:err("tl_ops_utils_sync_cookie new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_utils_sync_api new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_cookie start, old=",data)

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

    local res = cache_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_utils_sync_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_cookie done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- header策略数据同步
local tl_ops_utils_sync_header = function ()
    local cache_key_list = tl_ops_constant_header.cache_key.list
    local cache_key_rule = tl_ops_constant_header.cache_key.rule

    local demo = tl_ops_constant_header.demo

    local data_str, _ = cache_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_header:set(cache_key_list, cjson.encode(tl_ops_constant_balance.header.list))
        if not res then
            tlog:err("tl_ops_utils_sync_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_header:get(cache_key_list);

        tlog:dbg("tl_ops_utils_sync_header new store data, res=",res)
    end

    local data_rule_str, _ = cache_header:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_header:set(cache_key_rule, tl_ops_constant_balance.header.rule)
        if not res then
            tlog:err("tl_ops_utils_sync_header new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_utils_sync_header new store rule, res=",res)
    end


    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_header start, old=",data)

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

    local res = cache_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_utils_sync_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_header done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- param策略数据同步
local tl_ops_utils_sync_param = function ()
    local cache_key_list = tl_ops_constant_param.cache_key.list
    local cache_key_rule = tl_ops_constant_param.cache_key.rule

    local demo = tl_ops_constant_param.demo

    local data_str, _ = cache_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_param:set(cache_key_list, cjson.encode(tl_ops_constant_balance.param.list))
        if not res then
            tlog:err("tl_ops_utils_sync_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache_param:get(cache_key_list);

        tlog:dbg("tl_ops_utils_sync_param new store data, res=",res)
    end

    local data_rule_str, _ = cache_param:get(cache_key_rule);
    if not data_rule_str then
        local res, _ = cache_param:set(cache_key_rule, tl_ops_constant_balance.param.rule)
        if not res then
            tlog:err("tl_ops_utils_sync_param new store rule err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_utils_sync_param new store rule, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_utils_sync_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_param start, old=",data)

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

    local res = cache_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_utils_sync_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_utils_sync_param done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


-- 同步文件、字段
local tl_ops_utils_sync_module = function( module )

    if module == 'service' then
        return tl_ops_utils_sync_service()
    end

    if module == 'health' then
        return tl_ops_utils_sync_health()
    end

    if module == 'limit' then
        return tl_ops_utils_sync_limit()
    end

    if module == 'token' then
        return tl_ops_utils_sync_limit_token()
    end

    if module == 'leak' then
        return tl_ops_utils_sync_limit_leak()
    end

    if module == 'balance' then
        return tl_ops_utils_sync_balance()
    end

    if module == 'api' then
        return tl_ops_utils_sync_api()
    end

    if module == 'cookie' then
        return tl_ops_utils_sync_cookie()
    end

    if module == 'header' then
        return tl_ops_utils_sync_header()
    end

    if module == 'param' then
        return tl_ops_utils_sync_param()
    end

end


return {
    tl_ops_utils_sync_module = tl_ops_utils_sync_module
}