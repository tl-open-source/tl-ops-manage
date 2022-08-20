-- tl_ops_cache
-- en : redis cache , cache2
-- zn : redis 缓存实现二级自定义缓存
-- @author iamtsm
-- @email 1905333456@qq.com

local cache_redis       = require("lib.iredis"):new();
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_cache_cus");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local _M = tl_ops_utils_func:new_tab(0, 20)
_M._VERSION = '0.02'
local mt = { __index = _M }


-- get
function _M:get( key )
    if key == nil then
        return nil;
    end

    local res ,_ = cache_redis:get(key);
    if not res then
        return nil, "failed to get " .. key .. " from redis";
    end

    tlog:dbg("get cache redis ok key=" .. key)

    return res;
end


--set
function _M:set(key, value)
    if key == nil then
        return nil;
    end
    
    local res ,_ = cache_redis:set(key, value);
    if not res then
        return nil, "failed to set " .. key .. " from redis";
    end

    tlog:dbg("set cache redis ok key=" .. key)

    return 0;
end


--del
function _M:del(key)
    if key == nil then
        return nil;
    end

    local res ,_ = cache_redis:del(key);
    if not res then
        return nil, "failed to del " .. key .. " from redis";
    end

    tlog:dbg("del cache redis ok key=" .. key)

    return res;
end


function _M:new()
    return setmetatable({}, mt)
end


return _M;