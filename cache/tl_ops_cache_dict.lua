-- tl_ops_cache
-- en : ngx shared dict cache , cache1
-- zn : ngx shared 共享内存实现一级缓存
-- @author iamtsm
-- @email 1905333456@qq.com

local cache_dict = ngx.shared.tlopsbalance;
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_cache_dict");


local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end


local _M = new_tab(0, 50)
_M._VERSION = '0.02'
local mt = { __index = _M }


-- get
function _M:get( key )
    if key == nil then
        return nil;
    end

    local res ,_ = cache_dict:get(key);
    if not res then
        return nil, "failed to get " .. key .. " from dict";
    end

    tlog:dbg("get cache dict ok key=" .. key)

    return res;
end


--set
function _M:set(key, value)
    if key == nil then
        return nil;
    end
    
    local res ,_ = cache_dict:set(key, value);
    if not res then
        return nil, "failed to set " .. key .. " from dict";
    end

    tlog:dbg("set cache dict ok key=" .. key)

    return 0;
end

--del
function _M:del(key)
    if key == nil then
        return nil;
    end

    local res ,_ = cache_dict:del(key);
    if not res then
        return nil, "failed to del " .. key .. " from dict";
    end

    tlog:dbg("del cache dict ok key=" .. key)

    return res;
end


function _M:new()
    return setmetatable({}, mt)
end


return _M;