-- tl_ops_cache
-- en : cus cache , cache2
-- zn : 自定义缓存实现二级缓存
-- @author iamtsm
-- @email 1905333456@qq.com

local require           = require
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_cache_cus");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_manage_env = require("tl_ops_manage_env")
local use_cus           = tl_ops_manage_env.cache.cus;


local _M = tl_ops_utils_func:new_tab(0, 10)
_M._VERSION = '0.02'
local mt = { __index = _M }


-- get
function _M:get( key )
    return self.cus:get(key)
end


--set
function _M:set(key, value)
    self.cus:set(key, value);
    return 0
end


--del
function _M:del(key)
    self.cus:del(key);
    return 0;
end


function _M:new()
    if not use_cus or use_cus == 'none' then
        return nil
    end

    local status, cus = pcall(require, "cache.tl_ops_cache_" .. use_cus)
    if status then
        if cus and type(cus) == 'table' then
            if type(cus.new) ~= 'function' then
                return nil
            end
            if type(cus.get) ~= 'function' then
                return nil
            end
            if type(cus.set) ~= 'function' then
                return nil
            end
            if type(cus.del) ~= 'function' then
                return nil
            end
        end
    end

    tlog:dbg("use cus new ok, cus=" .. use_cus)

    return setmetatable({cus = cus}, mt)
end


return _M;