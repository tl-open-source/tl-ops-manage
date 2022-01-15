-- tl_ops_cache
-- en : cache manager
-- zn : 对外缓存管理工具
-- @author iamtsm
-- @email 1905333456@qq.com


local cache_store = nil;
local cache_redis = require("cache.tl_ops_cache_redis"):new();
local cache_dict = require("cache.tl_ops_cache_dict"):new();
local constant_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;


local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end
 
local _M = new_tab(0, 50)
_M._VERSION = '0.01'
local mt = { __index = _M }


function _M:new(business)
    cache_store = require("cache.tl_ops_cache_store"):new(business);
    return setmetatable({}, mt)
end


---- get
function _M:get( key )
    if key == nil then
        return nil;
    end

    -- load from dict
    local res_dict ,_ = cache_dict:get(key);
    if res_dict and res_dict ~= nil then
        return res_dict;
    end

    -- load from redis
    local res_redis ,_ = cache_redis:get(key);
    if res_redis and res_redis ~= nil then
        -- set to dict 
        local set_res ,_ = cache_dict:set(key, res_redis);
        if not set_res then
            return nil, "failed set to dict by redis res " .. key;
        end
        return res_redis;
    end


    -- load from store
    local res_store ,_ = cache_store:get(key);
    if res_store and res_store ~= nil then
        
        -- set to redis 
        local set_res ,_ = cache_redis:set(key, res_store);
        if not set_res then
            return nil, "failed set to redis by store res " .. key;
        end

        -- set to dict 
        local set_res ,_ = cache_dict:set(key, res_store);
        if not set_res then
            return nil, "failed set to dict by redis res " .. key;
        end

        return res_store;
    end

    return nil , "failed get " .. key;
end


---- set
function _M:set(key, value)
    if key == nil then
        return nil;
    end
    
    -- set store
    local set_store ,_ = cache_store:set(key, value);
    if not set_store then
        return nil, "failed set to store " .. key;
    end


    -- set redis
    local set_redis ,_ = cache_redis:set(key, value);
    if not set_redis then
        return nil, "failed set to redis after set store " .. key;
    end


    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict after set redis" .. key;
    end


    return constant_rt.ok;
end


---- del
function _M:del(key)
    if key == nil then
        return nil;
    end

    -- del store
    local del_store ,_ = cache_store:del(key);
    if not del_store then
        return nil, "failed to del store " .. key;
    end

    -- del redis
    local del_redis ,_ = cache_dict:del(key);
    if not del_redis then
        return nil, "failed to del redis after del store" .. key;
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict after set redis" .. key;
    end
    

    return constant_rt.ok;
end


return _M;