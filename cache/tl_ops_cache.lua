-- tl_ops_cache
-- en : cache manager
-- zn : 对外缓存管理工具
--      六种模式，000分别代表dict,redis,store, 例如 : 101代表开启dict,store模式
-- @author iamtsm
-- @email 1905333456@qq.com

local cache_redis = require("cache.tl_ops_cache_redis"):new();
local cache_dict = require("cache.tl_ops_cache_dict"):new();
local constant_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_env = require("tl_ops_manage_env")

-- 是否开启redis
local use_redis = tl_ops_env.cache.redis;


local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end
 
local _M = new_tab(0, 50)
_M._VERSION = '0.02'
local mt = { __index = _M }


function _M:new(business)
    local cache_store = require("cache.tl_ops_cache_store"):new(business);
    return setmetatable({
        business = business,
        cache_store = cache_store
    }, mt)
end



--[[
    store 模式 
]]
function _M:get001( key )
    if key == nil then
        return nil;
    end

    -- load from store
    local res_store ,_ = self.cache_store:get(key);
    if res_store and res_store ~= nil then
        return res_store;
    end

    return nil , "failed get " .. key;
end

function _M:set001(key, value)
    if key == nil then
        return nil;
    end
    
    -- set store
    local set_store ,_ = self.cache_store:set(key, value);
    if not set_store then
        return nil, "failed set to store in 001 " .. key;
    end

    return constant_rt.ok;
end

function _M:del001(key)
    if key == nil then
        return nil;
    end

    -- del store
    local del_store ,_ = self.cache_store:del(key);
    if not del_store then
        return nil, "failed to del store in 001 " .. key;
    end

    return constant_rt.ok;
end


--[[
    redis 模式 
]]
function _M:get010( key )
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end
    
    if key == nil then
        return nil;
    end

    -- load from redis
    local res_redis ,_ = cache_redis:get(key);
    if res_redis and res_redis ~= nil then
        return res_redis;
    end

    return nil , "failed get " .. key;
end

function _M:set010(key, value)
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end
    
    if key == nil then
        return nil;
    end
    
    -- set redis
    local set_redis ,_ = cache_redis:set(key, value);
    if not set_redis then
        return nil, "failed set to redis in 010 " .. key;
    end

    return constant_rt.ok;
end

function _M:del010(key)
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- del redis
    local del_redis ,_ = cache_dict:del(key);
    if not del_redis then
        return nil, "failed to del redis in 010 " .. key;
    end

    return constant_rt.ok;
end


--[[
    redis-store 模式 
]]
function _M:get011( key )
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- load from redis
    local res_redis ,_ = cache_redis:get(key);
    if res_redis and res_redis ~= nil then
        return res_redis;
    end


    -- load from store
    local res_store ,_ = self.cache_store:get(key);
    if res_store and res_store ~= nil then
        
        -- set to redis 
        local set_res ,_ = cache_redis:set(key, res_store);
        if not set_res then
            return nil, "failed set to redis in 011 " .. key;
        end

        return res_store;
    end

    return nil , "failed get " .. key;
end

function _M:set011(key, value)
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

    if key == nil then
        return nil;
    end
    
    -- set store
    local set_store ,_ = self.cache_store:set(key, value);
    if not set_store then
        return nil, "failed set to store in 011 " .. key;
    end


    -- set redis
    local set_redis ,_ = cache_redis:set(key, value);
    if not set_redis then
        return nil, "failed set to redis in 011 " .. key;
    end


    return constant_rt.ok;
end

function _M:del011(key)
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- del store
    local del_store ,_ = self.cache_store:del(key);
    if not del_store then
        return nil, "failed to del store in 011 " .. key;
    end

    -- del redis
    local del_redis ,_ = cache_dict:del(key);
    if not del_redis then
        return nil, "failed to del redis in 011" .. key;
    end

    return constant_rt.ok;
end


--[[
    dict 模式
]]
function _M:get100( key )
    if key == nil then
        return nil;
    end

    -- load from dict
    local res_dict ,_ = cache_dict:get(key);
    if res_dict and res_dict ~= nil then
        return res_dict;
    end

    return nil , "failed get " .. key;
end

function _M:set100(key, value)
    if key == nil then
        return nil;
    end

    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict in 100 " .. key;
    end


    return constant_rt.ok;
end

function _M:del100(key)
    if key == nil then
        return nil;
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict in 100 " .. key;
    end
    

    return constant_rt.ok;
end


--[[
    dict-store模式
]]
function _M:get101( key )
    if key == nil then
        return nil;
    end

    -- load from dict
    local res_dict ,_ = cache_dict:get(key);
    if res_dict and res_dict ~= nil then
        return res_dict;
    end

    -- load from store
    local res_store ,_ = self.cache_store:get(key);
    if res_store and res_store ~= nil then

        -- set to dict 
        local set_res ,_ = cache_dict:set(key, res_store);
        if not set_res then
            return nil, "failed set to dict in 101 " .. key;
        end

        return res_store;
    end

    return nil , "failed get " .. key;
end

function _M:set101(key, value)
    if key == nil then
        return nil;
    end
    
    -- set store
    local set_store ,_ = self.cache_store:set(key, value);
    if not set_store then
        return nil, "failed set to store in 101 " .. key;
    end


    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict in 101" .. key;
    end


    return constant_rt.ok;
end

function _M:del101(key)
    if key == nil then
        return nil;
    end

    -- del store
    local del_store ,_ = self.cache_store:del(key);
    if not del_store then
        return nil, "failed to del store in 101 " .. key;
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict in 101 " .. key;
    end
    

    return constant_rt.ok;
end


--[[
    dict-redis 模式 
]]
function _M:get110( key )
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

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
            return nil, "failed set to dict in 110 " .. key;
        end
        return res_redis;
    end

    return nil , "failed get " .. key;
end

function _M:set110(key, value)
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- set redis
    local set_redis ,_ = cache_redis:set(key, value);
    if not set_redis then
        return nil, "failed set to redis in 110 " .. key;
    end

    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict in 110 " .. key;
    end

    return constant_rt.ok;
end

function _M:del110(key)
    if not use_redis then
        return nil , "un open redis cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- del redis
    local del_redis ,_ = cache_dict:del(key);
    if not del_redis then
        return nil, "failed to del redis in 110 " .. key;
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict in 110 " .. key;
    end
    

    return constant_rt.ok;
end



--[[
    dict-redis-store 模式 
]]
function _M:get( key )
    if key == nil then
        return nil;
    end

    -- load from dict
    local res_dict ,_ = cache_dict:get(key);
    if res_dict and res_dict ~= nil then
        return res_dict;
    end

    

    if use_redis then
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
    end

    -- load from store
    local res_store ,_ = self.cache_store:get(key);
    if res_store and res_store ~= nil then
        
        if use_redis then
            -- set to redis 
            local set_res ,_ = cache_redis:set(key, res_store);
            if not set_res then
                return nil, "failed set to redis by store res " .. key;
            end
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

function _M:set(key, value)
    if key == nil then
        return nil;
    end
    
    -- set store
    local set_store ,_ = self.cache_store:set(key, value);
    if not set_store then
        return nil, "failed set to store " .. key;
    end

    if use_redis then
        -- set redis
        local set_redis ,_ = cache_redis:set(key, value);
        if not set_redis then
            return nil, "failed set to redis after set store " .. key;
        end
    end

    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict after set redis" .. key;
    end


    return constant_rt.ok;
end

function _M:del(key)
    if key == nil then
        return nil;
    end

    -- del store
    local del_store ,_ = self.cache_store:del(key);
    if not del_store then
        return nil, "failed to del store " .. key;
    end

    if use_redis then
        -- del redis
        local del_redis ,_ = cache_dict:del(key);
        if not del_redis then
            return nil, "failed to del redis after del store" .. key;
        end
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict after set redis" .. key;
    end
    

    return constant_rt.ok;
end



return _M;