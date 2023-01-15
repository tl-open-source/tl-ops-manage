-- tl_ops_auth_sync
-- en : sync auth config list
-- zn : 同步、预热登录权限相关数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_auth")
local cache                 = require("cache.tl_ops_cache_core"):new("tl-ops-auth")
local constant              = require("plugins.tl_ops_auth.tl_ops_plugin_constant")
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



local sync_fields_list_config = function()

    local cache_key_list = constant.cache_key.list;

    local demo = constant.demo.list

    local data_str, _ = cache:get(cache_key_list);
    if not data_str then
        local res, _ = cache:set(cache_key_list, cjson.encode(constant.list))
        if not res then
            tlog:err("auth list sync_fields new store data err, res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache:get(cache_key_list)

        tlog:dbg("auth list sync_fields new store data, res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("auth sync_fields err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth list sync_fields start, old=",data)

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
        tlog:err("auth list sync_fields err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth list sync_fields done, new=",data,",add_keys=",add_keys)
    
    return tl_ops_rt.ok
end


local sync_fields_login_config = function()
    local cache_key = constant.cache_key.login
    local constant_data = constant.login
    local demo = constant.demo.login

    local data_str, _ = cache:get(cache_key);
    if not data_str then
        local res, _ = cache:set(cache_key, cjson.encode(constant_data))
        if not res then
            tlog:err("auth login sync_fields new store err, cache_key=",cache_key,",res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache:get(cache_key);

        tlog:dbg("auth login sync_fields new store,  cache_key=",cache_key,",res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("auth login sync_fields err,  cache_key=",cache_key,",old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth login sync_fields start,  cache_key=",cache_key,",old=",data)

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

    local res = cache:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("auth login sync_fields err,  cache_key=",cache_key,",res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth login sync_fields done,  cache_key=",cache_key,",new=",data,",add_keys=",add_keys)

    return tl_ops_rt.ok
end



-- 同步插件对外数据
local sync_fields_export = function ()
    local cache_key = constant.export.cache_key.auth
    local constant_data = constant.export.auth
    local demo = constant.export.demo

    local data_str, _ = cache:get(cache_key);
    if not data_str then
        local res, _ = cache:set(cache_key, cjson.encode(constant_data))
        if not res then
            tlog:err("auth sync_fields_export new store err, cache_key=",cache_key,",res=",res)
            return tl_ops_rt.error
        end

        data_str, _ = cache:get(cache_key);

        tlog:dbg("auth sync_fields_export new store,  cache_key=",cache_key,",res=",res)
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("auth sync_fields_export err,  cache_key=",cache_key,",old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth sync_fields_export start,  cache_key=",cache_key,",old=",data)

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

    local res = cache:set(cache_key, cjson.encode(data))
    if not res then
        tlog:err("auth sync_fields_export err,  cache_key=",cache_key,",res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth sync_fields_export done,  cache_key=",cache_key,",new=",data,",add_keys=",add_keys)
    
    return tl_ops_rt.ok
end


-- 静态配置数据同步
local sync_data = function ()
    local cache_key_list = constant.cache_key.list

    local data_str, _ = cache:get(cache_key_list);
    if not data_str then
        local res, _ = cache:set(cache_key_list, cjson.encode(constant.list))
        if not res then
            tlog:err("auth sync_data new store data err, res=",res)
            return tl_ops_rt.error
        end

        tlog:dbg("auth sync_data new store data, res=",res)
        return tl_ops_rt.ok
    end

    local data = cjson.decode(data_str);
    if not data and type(data) ~= 'table' then
        tlog:err("auth sync_data err, old=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth sync_data start, old=",data)

    -- 静态配置
    local constant_data = constant.list

    -- 获取需要同步的配置
    local add = sync_data_need_sync(constant_data, data)
    for i = 1, #add do 
        table.insert(data, add[i])
    end

    local res = cache:set(cache_key_list, cjson.encode(data))
    if not res then
        tlog:err("auth sync_data err, res=",res,",new=",data)
        return tl_ops_rt.error
    end

    tlog:dbg("auth sync_data done, new=",data)

    return tl_ops_rt.ok
end



-- 字段数据同步
local sync_fields = function ()
    
    -- 身份列表 数据
    sync_fields_list_config()

    -- 登录配置 数据
    sync_fields_login_config()

    -- 对外配置  数据
    sync_fields_export()

    return tl_ops_rt.ok
end



return {
    sync_data = sync_data,
    sync_fields = sync_fields
}