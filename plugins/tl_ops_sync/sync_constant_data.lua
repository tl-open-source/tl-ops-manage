-- sync_constant_data
-- en : sync constant data to shared dict
-- zn : 同步在文件中的静态配置到共享内存中，和store的数据进行合并
-- @author iamtsm
-- @email 1905333456@qq.com

-- constant
local constant_service          =   tlops.constant.service
local constant_health           =   tlops.constant.health
local constant_limit            =   tlops.constant.limit
local constant_balance          =   tlops.constant.balance
local constant_balance_api      =   tlops.constant.balance_api
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
local tl_ops_rt                 =   tlops.constant.comm.tl_ops_rt;
-- cache
local cache_service             =   tlops.cache.service
local cache_limit               =   tlops.cache.limit
local cache_health              =   tlops.cache.health
local cache_balance_api         =   tlops.cache.balance_api
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
-- utils
local utils                     =   tlops.utils
local cjson                     =   require("cjson.safe");
cjson.encode_empty_table_as_object(false)
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync_constant_data");


local _M = {
    _VERSION = '0.01'
}


-- 静态文件中的未同步到store的配置数据
local sync_constant_data_need_sync = function (constant_data, store_data)
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
local sync_constant_data_balance_api = function () 
    local cache_key_list = constant_balance_api.cache_key.list

    local data_str, _ = cache_balance_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_api:set(cache_key_list, cjson.encode(constant_balance.api.list))
        if not res then
            tlog:err("sync_constant_data_balance_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_balance_api new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_balance_api err, old=",data)
        return tl_ops_rt.error
    end

    -- 静态配置
    local constant_data = constant_balance.api.list

    -- 获取需要同步的配置
    local add_point = sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_balance_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_api done, new=",data)

    return tl_ops_rt.ok
end

-- cookie策略静态配置数据
local sync_constant_data_balance_cookie = function ()
    local cache_key_list = constant_balance_cookie.cache_key.list

    local data_str, _ = cache_balance_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_cookie:set(cache_key_list, cjson.encode(constant_balance.cookie.list))
        if not res then
            tlog:err("sync_constant_data_balance_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_balance_cookie new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_balance_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_cookie start, old=",data)

    -- 静态配置
    local constant_data = constant_balance.cookie.list

    -- 获取需要同步的配置
    local add_point = sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_balance_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_cookie done, new=",data)

    return tl_ops_rt.ok
end

-- header策略静态配置数据
local sync_constant_data_balance_header = function ()
    local cache_key_list = constant_balance_header.cache_key.list

    local data_str, _ = cache_balance_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_header:set(cache_key_list, cjson.encode(constant_balance.header.list))
        if not res then
            tlog:err("sync_constant_data_balance_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_balance_header new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_balance_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_header start, old=",data)

    -- 静态配置
    local constant_data = constant_balance.header.list

    -- 获取需要同步的配置
    local add_point = sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_balance_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_header done, new=",data)

    return tl_ops_rt.ok
end

-- param策略静态配置数据
local sync_constant_data_balance_param = function ()
    local cache_key_list = constant_balance_param.cache_key.list

    local data_str, _ = cache_balance_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_balance_param:set(cache_key_list, cjson.encode(constant_balance.param.list))
        if not res then
            tlog:err("sync_constant_data_balance_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_balance_param new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_balance_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_param start, old=",data)

    -- 静态配置
    local constant_data = constant_balance.param.list

    -- 获取需要同步的配置
    local add_point = sync_constant_data_need_sync(constant_data.point, data.point)
    for i = 1, #add_point do 
        table.insert(data.point, add_point[i])
    end

    -- 获取需要同步的配置
    local add_random = sync_constant_data_need_sync(constant_data.random, data.random)
    for i = 1, #add_random do 
        table.insert(data.random, add_random[i])
    end

    local res = cache_balance_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_balance_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_balance_param done, new=",data)

    return tl_ops_rt.ok
end



--+++++++++++++++WAF策略数据同步合并，预热+++++++++++++++--

-- waf ip策略静态配置数据
local sync_constant_data_waf_ip = function ()
    local cache_key_list = constant_waf_ip.cache_key.list

    local data_str, _ = cache_waf_ip:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_ip:set(cache_key_list, cjson.encode(constant_waf.ip.list))
        if not res then
            tlog:err("sync_constant_data_waf_ip new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_waf_ip new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_waf_ip err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_ip start, old=",data)

    -- 静态配置
    local constant_data = constant_waf.ip.list

    -- 获取需要同步的配置
    local add = sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_ip:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_waf_ip err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_ip done, new=",data)

    return tl_ops_rt.ok
end

-- waf api策略静态配置数据
local sync_constant_data_waf_api = function ()
    local cache_key_list = constant_waf_api.cache_key.list

    local data_str, _ = cache_waf_api:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_api:set(cache_key_list, cjson.encode(constant_waf.api.list))
        if not res then
            tlog:err("sync_constant_data_waf_api new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_waf_api new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_waf_api err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_api start, old=",data)

    -- 静态配置
    local constant_data = constant_waf.api.list

    -- 获取需要同步的配置
    local add = sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_api:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_waf_api err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_api done, new=",data)

    return tl_ops_rt.ok
end

-- waf cookie策略静态配置数据
local sync_constant_data_waf_cookie = function ()
    local cache_key_list = constant_waf_cookie.cache_key.list

    local data_str, _ = cache_waf_cookie:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cookie:set(cache_key_list, cjson.encode(constant_waf.cookie.list))
        if not res then
            tlog:err("sync_constant_data_waf_cookie new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_waf_cookie new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_waf_cookie err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_cookie start, old=",data)

    -- 静态配置
    local constant_data = constant_waf.cookie.list

    -- 获取需要同步的配置
    local add = sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_cookie:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_waf_cookie err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_cookie done, new=",data)

    return tl_ops_rt.ok
end

-- waf header策略静态配置数据
local sync_constant_data_waf_header = function ()
    local cache_key_list = constant_waf_header.cache_key.list

    local data_str, _ = cache_waf_header:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_header:set(cache_key_list, cjson.encode(constant_waf.header.list))
        if not res then
            tlog:err("sync_constant_data_waf_header new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_waf_header new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_waf_header err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_header start, old=",data)

    -- 静态配置
    local constant_data = constant_waf.header.list

    -- 获取需要同步的配置
    local add = sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_header:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_waf_header err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_header done, new=",data)

    return tl_ops_rt.ok
end

-- waf param策略静态配置数据
local sync_constant_data_waf_param = function ()
    local cache_key_list = constant_waf_param.cache_key.list

    local data_str, _ = cache_waf_param:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_param:set(cache_key_list, cjson.encode(constant_waf.param.list))
        if not res then
            tlog:err("sync_constant_data_waf_param new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_waf_param new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_waf_param err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_param start, old=",data)

    -- 静态配置
    local constant_data = constant_waf.param.list

    -- 获取需要同步的配置
    local add = sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_param:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_waf_param err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_param done, new=",data)

    return tl_ops_rt.ok
end

-- waf cc策略静态配置数据
local sync_constant_data_waf_cc = function ()
    local cache_key_list = constant_waf_cc.cache_key.list

    local data_str, _ = cache_waf_cc:get(cache_key_list);
    if not data_str then
        local res, _ = cache_waf_cc:set(cache_key_list, cjson.encode(constant_waf.cc.list))
        if not res then
            tlog:err("sync_constant_data_waf_cc new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("sync_constant_data_waf_cc new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("sync_constant_data_waf_cc err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_cc start, old=",data)

    -- 静态配置
    local constant_data = constant_waf.cc.list

    -- 获取需要同步的配置
    local add = sync_constant_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache_waf_cc:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("sync_constant_data_waf_cc err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("sync_constant_data_waf_cc done, new=",data)

    return tl_ops_rt.ok
end




function _M:sync_constant_data_module( module )

    if module == 'balance-api' then
        return sync_constant_data_balance_api()
    end

    if module == 'balance-cookie' then
        return sync_constant_data_balance_cookie()
    end

    if module == 'balance-header' then
        return sync_constant_data_balance_header()
    end

    if module == 'balance-param' then
        return sync_constant_data_balance_param()
    end

    if module == 'waf-api' then
        return sync_constant_data_waf_api()
    end

    if module == 'waf-ip' then
        return sync_constant_data_waf_ip()
    end
    
    if module == 'waf-header' then
        return sync_constant_data_waf_header()
    end

    if module == 'waf-cookie' then
        return sync_constant_data_waf_cookie()
    end

    if module == 'waf-param' then
        return sync_constant_data_waf_param()
    end

    if module == 'waf-cc' then
        return sync_constant_data_waf_cc()
    end
end


return _M