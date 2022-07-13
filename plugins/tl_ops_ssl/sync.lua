-- tl_ops_ssl_sync
-- en : sync ssl config list
-- zn : 同步、预热ssl数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_ssl")
local cache                 = require("cache.tl_ops_cache_core"):new("tl-ops-ssl")
local tl_ops_constant_ssl   = require("plugins.tl_ops_ssl.tl_ops_constant_ssl")
local tl_ops_rt             = tlops.constant.comm.tl_ops_rt
local cjson                 = require("cjson.safe")
cjson.encode_empty_table_as_object(false)


-- 静态文件中的未同步到store的配置数据
local sync_data_need_sync = function (constant_data, store_data)
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


-- 静态配置数据同步
local sync_data = function ()
    local cache_key_list = tl_ops_constant_ssl.cache_key.list

    local data_str, _ = cache:get(cache_key_list);
    if not data_str then
        local res, _ = cache:set(cache_key_list, cjson.encode(tl_ops_constant_ssl.list))
        if not res then
            tlog:err("ssl sync_data new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("ssl sync_data new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("ssl sync_data err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("ssl sync_data start, old=",data)

    -- 静态配置
    local constant_data = tl_ops_constant_ssl.list

    -- 获取需要同步的配置
    local add = sync_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("ssl sync_data err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("ssl sync_data done, new=",data)

    return tl_ops_rt.ok
end




-- 字段数据同步
local sync_fields = function ()
    local cache_key_list = tl_ops_constant_ssl.cache_key.list;

    local demo = tl_ops_constant_ssl.demo

    local data_str, _ = cache:get(cache_key_list);
    if not data_str then
        local res, _ = cache:set(cache_key_list, cjson.encode(tl_ops_constant_ssl.list))
        if not res then
            tlog:err("ssl sync_fields new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache:get(cache_key_list)

        tlog:dbg("ssl sync_fields new store data, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("ssl sync_fields err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("ssl sync_fields start, old=",data)

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

    local res = cache:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("ssl sync_fields err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("ssl sync_fields done, new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end


return {
    sync_data = sync_data,
    sync_fields = sync_fields
}