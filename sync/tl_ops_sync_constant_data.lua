-- tl_ops_sync_constant_data
-- en : sync constant data to shared dict
-- zn : 同步在文件中的静态配置到共享内存中，和store的数据进行合并
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

-- balance
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_balance_api = require("constant.tl_ops_constant_balance_api");
local tl_ops_constant_balance_param = require("constant.tl_ops_constant_balance_param");
local tl_ops_constant_balance_header = require("constant.tl_ops_constant_balance_header");
local tl_ops_constant_balance_cookie = require("constant.tl_ops_constant_balance_cookie");
local cache_balance_api = require("cache.tl_ops_cache"):new("tl-ops-balance-api");
local cache_balance_param = require("cache.tl_ops_cache"):new("tl-ops-balance-param");
local cache_balance_header = require("cache.tl_ops_cache"):new("tl-ops-balance-header");
local cache_balance_cookie = require("cache.tl_ops_cache"):new("tl-ops-balance-cookie");


-- waf
local tl_ops_constant_waf = require("constant.tl_ops_constant_waf");
local tl_ops_constant_waf_ip = require("constant.tl_ops_constant_waf_ip");
local tl_ops_constant_waf_api = require("constant.tl_ops_constant_waf_api");
local tl_ops_constant_waf_cc = require("constant.tl_ops_constant_waf_cc");
local tl_ops_constant_waf_header = require("constant.tl_ops_constant_waf_header");
local tl_ops_constant_waf_cookie = require("constant.tl_ops_constant_waf_cookie");
local tl_ops_constant_waf_param = require("constant.tl_ops_constant_waf_param");
local cache_waf_api = require("cache.tl_ops_cache"):new("tl-ops-waf-api");
local cache_waf_ip = require("cache.tl_ops_cache"):new("tl-ops-waf-ip");
local cache_waf_cookie = require("cache.tl_ops_cache"):new("tl-ops-waf-cookie");
local cache_waf_header = require("cache.tl_ops_cache"):new("tl-ops-waf-header");
local cache_waf_cc = require("cache.tl_ops_cache"):new("tl-ops-waf-cc");
local cache_waf_param = require("cache.tl_ops_cache"):new("tl-ops-waf-param");

-- utils
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_sync_constant_data");


local _M = {
    _VERSION = '0.01'
}
local mt = { __index = _M }


function _M:new( )
	return setmetatable({}, mt)
end


-- 静态文件中的未同步到store的配置数据
local tl_ops_sync_constant_data_need_sync = function (constant_data, store_data)
    local add = {}
    for i = 1, #constant_data do
        local synced = false
        for j = 1, #store_data do
            if constant_data[i]['id'] == store_data[j]['id'] then
                synced = true
                break
            end
        end
        if not synced then
            table.insert(add, constant_data[i])
        end
    end
    return add
end


--+++++++++++++++路由策略数据同步合并，预热+++++++++++++++--


-- api策略静态配置数据
local tl_ops_sync_constant_data_balance_api = function () 
    local cache_key_list = tl_ops_constant_balance_api.cache_key.list

    local data_str, _ = cache_balance_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_api:set(cache_key_list, cjson.encode(tl_ops_constant_balance.api.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_balance_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_balance_api new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_balance_api err, old=",data)
        return tl_ops_rt.error
    end

    -- 静态配置
    local constant_data = tl_ops_constant_balance.api.list

    -- 获取需要同步的配置
    local add_point = tl_ops_sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = tl_ops_sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_balance_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_api done, new=",data)

    return tl_ops_rt.ok
end

-- cookie策略静态配置数据
local tl_ops_sync_constant_data_balance_cookie = function ()
    local cache_key_list = tl_ops_constant_balance_cookie.cache_key.list

    local data_str, _ = cache_balance_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_cookie:set(cache_key_list, cjson.encode(tl_ops_constant_balance.cookie.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_balance_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_balance_cookie new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_balance_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_cookie start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_balance.cookie.list

    -- 获取需要同步的配置
    local add_point = tl_ops_sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = tl_ops_sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_balance_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_cookie done, new=",data)

    return tl_ops_rt.ok
end

-- header策略静态配置数据
local tl_ops_sync_constant_data_balance_header = function ()
    local cache_key_list = tl_ops_constant_balance_header.cache_key.list

    local data_str, _ = cache_balance_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_header:set(cache_key_list, cjson.encode(tl_ops_constant_balance.header.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_balance_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_balance_header new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_balance_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_header start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_balance.header.list

    -- 获取需要同步的配置
    local add_point = tl_ops_sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = tl_ops_sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_balance_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_header done, new=",data)

    return tl_ops_rt.ok
end

-- param策略静态配置数据
local tl_ops_sync_constant_data_balance_param = function ()
    local cache_key_list = tl_ops_constant_balance_param.cache_key.list

    local data_str, _ = cache_balance_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_param:set(cache_key_list, cjson.encode(tl_ops_constant_balance.param.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_balance_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_balance_param new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_balance_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_param start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_balance.param.list

    -- 获取需要同步的配置
    local add_point = tl_ops_sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = tl_ops_sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_balance_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_balance_param done, new=",data)

    return tl_ops_rt.ok
end



--+++++++++++++++WAF策略数据同步合并，预热+++++++++++++++--

-- waf ip策略静态配置数据
local tl_ops_sync_constant_data_waf_ip = function ()
    local cache_key_list = tl_ops_constant_waf_ip.cache_key.list

    local data_str, _ = cache_waf_ip:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_ip:set(cache_key_list, cjson.encode(tl_ops_constant_waf.ip.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_waf_ip new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_waf_ip new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_waf_ip err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_ip start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_waf.ip.list

    -- 获取需要同步的配置
    local add = tl_ops_sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_ip:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_waf_ip err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_ip done, new=",data)

    return tl_ops_rt.ok
end

-- waf api策略静态配置数据
local tl_ops_sync_constant_data_waf_api = function ()
    local cache_key_list = tl_ops_constant_waf_api.cache_key.list

    local data_str, _ = cache_waf_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_api:set(cache_key_list, cjson.encode(tl_ops_constant_waf.api.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_waf_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_waf_api new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_waf_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_api start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_waf.api.list

    -- 获取需要同步的配置
    local add = tl_ops_sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_waf_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_api done, new=",data)

    return tl_ops_rt.ok
end

-- waf cookie策略静态配置数据
local tl_ops_sync_constant_data_waf_cookie = function ()
    local cache_key_list = tl_ops_constant_waf_cookie.cache_key.list

    local data_str, _ = cache_waf_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cookie:set(cache_key_list, cjson.encode(tl_ops_constant_waf.cookie.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_waf_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_waf_cookie new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_waf_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_cookie start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_waf.cookie.list

    -- 获取需要同步的配置
    local add = tl_ops_sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_waf_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_cookie done, new=",data)

    return tl_ops_rt.ok
end

-- waf header策略静态配置数据
local tl_ops_sync_constant_data_waf_header = function ()
    local cache_key_list = tl_ops_constant_waf_header.cache_key.list

    local data_str, _ = cache_waf_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_header:set(cache_key_list, cjson.encode(tl_ops_constant_waf.header.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_waf_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_waf_header new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_waf_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_header start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_waf.header.list

    -- 获取需要同步的配置
    local add = tl_ops_sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_waf_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_header done, new=",data)

    return tl_ops_rt.ok
end

-- waf param策略静态配置数据
local tl_ops_sync_constant_data_waf_param = function ()
    local cache_key_list = tl_ops_constant_waf_param.cache_key.list

    local data_str, _ = cache_waf_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_param:set(cache_key_list, cjson.encode(tl_ops_constant_waf.param.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_waf_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_waf_param new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_waf_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_param start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_waf.param.list

    -- 获取需要同步的配置
    local add = tl_ops_sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_waf_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_param done, new=",data)

    return tl_ops_rt.ok
end

-- waf cc策略静态配置数据
local tl_ops_sync_constant_data_waf_cc = function ()
    local cache_key_list = tl_ops_constant_waf_cc.cache_key.list

    local data_str, _ = cache_waf_cc:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cc:set(cache_key_list, cjson.encode(tl_ops_constant_waf.cc.list))
        if not res then
            tlog:err("tl_ops_sync_constant_data_waf_cc new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("tl_ops_sync_constant_data_waf_cc new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("tl_ops_sync_constant_data_waf_cc err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_cc start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_waf.cc.list

    -- 获取需要同步的配置
    local add = tl_ops_sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_cc:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("tl_ops_sync_constant_data_waf_cc err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("tl_ops_sync_constant_data_waf_cc done, new=",data)

    return tl_ops_rt.ok
end




function _M:tl_ops_sync_constant_data_module( module )

    if module == 'balance-api' then
        return tl_ops_sync_constant_data_balance_api()
    end

    if module == 'balance-cookie' then
        return tl_ops_sync_constant_data_balance_cookie()
    end

    if module == 'balance-header' then
        return tl_ops_sync_constant_data_balance_header()
    end

    if module == 'balance-param' then
        return tl_ops_sync_constant_data_balance_param()
    end

    if module == 'waf-api' then
        return tl_ops_sync_constant_data_waf_api()
    end

    if module == 'waf-ip' then
        return tl_ops_sync_constant_data_waf_ip()
    end
    
    if module == 'waf-header' then
        return tl_ops_sync_constant_data_waf_header()
    end

    if module == 'waf-cookie' then
        return tl_ops_sync_constant_data_waf_cookie()
    end

    if module == 'waf-param' then
        return tl_ops_sync_constant_data_waf_param()
    end

    if module == 'waf-cc' then
        return tl_ops_sync_constant_data_waf_cc()
    end
end


return _M