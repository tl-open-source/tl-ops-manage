-- tl_ops_cache
-- en : cache manager
-- zn : 对外缓存管理工具
--      六种模式，000分别代表dict,cus,store, 例如 : 101代表开启dict,store模式
-- @author iamtsm
-- @email 1905333456@qq.com

local cache_cus         = require("cache.tl_ops_cache_cus"):new();
local cache_dict        = require("cache.tl_ops_cache_dict"):new();
local constant_rt       = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_manage_env = require("tl_ops_manage_env")
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local use_cus           = tl_ops_manage_env.cache.cus;
local use_cus_name      = use_cus.name;


local _M = tl_ops_utils_func:new_tab(0, 20)
_M._VERSION = '0.02'
local mt = { __index = _M }


function _M:new(business, store_full)
    local cache_store = require("cache.tl_ops_cache_store"):new(business, store_full);
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
    cus 模式 
]]
function _M:get010( key )
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end
    
    if key == nil then
        return nil;
    end

    -- load from cus
    local res_cus ,_ = cache_cus:get(key);
    if res_cus and res_cus ~= nil then
        return res_cus;
    end

    return nil , "failed get " .. key;
end

function _M:set010(key, value)
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end
    
    if key == nil then
        return nil;
    end
    
    -- set cus
    local set_cus ,_ = cache_cus:set(key, value);
    if not set_cus then
        return nil, "failed set to cus in 010 " .. key;
    end

    return constant_rt.ok;
end

function _M:del010(key)
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- del cus
    local del_cus ,_ = cache_dict:del(key);
    if not del_cus then
        return nil, "failed to del cus in 010 " .. key;
    end

    return constant_rt.ok;
end


--[[
    cus-store 模式 
]]
function _M:get011( key )
    if not use_cus or use_cus == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- load from cus
    local res_cus ,_ = cache_cus:get(key);
    if res_cus and res_cus ~= nil then
        return res_cus;
    end


    -- load from store
    local res_store ,_ = self.cache_store:get(key);
    if res_store and res_store ~= nil then
        
        -- set to cus 
        local set_res ,_ = cache_cus:set(key, res_store);
        if not set_res then
            return nil, "failed set to cus in 011 " .. key;
        end

        return res_store;
    end

    return nil , "failed get " .. key;
end

function _M:set011(key, value)
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end
    
    -- set store
    local set_store ,_ = self.cache_store:set(key, value);
    if not set_store then
        return nil, "failed set to store in 011 " .. key;
    end


    -- set cus
    local set_cus ,_ = cache_cus:set(key, value);
    if not set_cus then
        return nil, "failed set to cus in 011 " .. key;
    end


    return constant_rt.ok;
end

function _M:del011(key)
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- del store
    local del_store ,_ = self.cache_store:del(key);
    if not del_store then
        return nil, "failed to del store in 011 " .. key;
    end

    -- del cus
    local del_cus ,_ = cache_dict:del(key);
    if not del_cus then
        return nil, "failed to del cus in 011" .. key;
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
    dict-cus 模式 
]]
function _M:get110( key )
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- load from dict
    local res_dict ,_ = cache_dict:get(key);
    if res_dict and res_dict ~= nil then
        return res_dict;
    end

    -- load from cus
    local res_cus ,_ = cache_cus:get(key);
    if res_cus and res_cus ~= nil then
        -- set to dict 
        local set_res ,_ = cache_dict:set(key, res_cus);
        if not set_res then
            return nil, "failed set to dict in 110 " .. key;
        end
        return res_cus;
    end

    return nil , "failed get " .. key;
end

function _M:set110(key, value)
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- set cus
    local set_cus ,_ = cache_cus:set(key, value);
    if not set_cus then
        return nil, "failed set to cus in 110 " .. key;
    end

    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict in 110 " .. key;
    end

    return constant_rt.ok;
end

function _M:del110(key)
    if not use_cus or not use_cus_name or use_cus_name == 'none' then
        return nil , "un open cus cache " .. key;
    end

    if key == nil then
        return nil;
    end

    -- del cus
    local del_cus ,_ = cache_dict:del(key);
    if not del_cus then
        return nil, "failed to del cus in 110 " .. key;
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict in 110 " .. key;
    end
    

    return constant_rt.ok;
end



--[[
    dict-cus-store 模式 
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

    if use_cus and use_cus_name and use_cus_name ~= 'none' then
        -- load from cus
        local res_cus ,_ = cache_cus:get(key);
        if res_cus and res_cus ~= nil then
            -- set to dict 
            local set_res ,_ = cache_dict:set(key, res_cus);
            if not set_res then
                return nil, "failed set to dict by cus res " .. key;
            end
            return res_cus;
        end
    end

    -- load from store
    local res_store ,_ = self.cache_store:get(key);
    if res_store and res_store ~= nil then

        if use_cus and use_cus_name and use_cus_name ~= 'none' then
            -- set to cus 
            local set_res ,_ = cache_cus:set(key, res_store);
            if not set_res then
                return nil, "failed set to cus by store res " .. key;
            end
        end

        -- set to dict 
        local set_res ,_ = cache_dict:set(key, res_store);
        if not set_res then
            return nil, "failed set to dict by cus res " .. key;
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

    if use_cus and use_cus_name and use_cus_name ~= 'none' then
        -- set cus
        local set_cus ,_ = cache_cus:set(key, value);
        if not set_cus then
            return nil, "failed set to cus after set store " .. key;
        end
    end

    -- set dict
    local set_dict ,_ = cache_dict:set(key, value);
    if not set_dict then
        return nil, "failed set to dict after set cus" .. key;
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

    if use_cus and use_cus_name and use_cus_name ~= 'none' then
        -- del cus
        local del_cus ,_ = cache_dict:del(key);
        if not del_cus then
            return nil, "failed to del cus after del store" .. key;
        end
    end

    -- del dict
    local del_dict ,_ = cache_dict:del(key);
    if not del_dict then
        return nil, "failed to del dict after set cus" .. key;
    end
    

    return constant_rt.ok;
end



return _M;