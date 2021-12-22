-- tl_ops_cache
-- en : store cache , cache3
-- zn : 自行实现本地文件缓存 缓存实现三级缓存
-- @author iamtsm
-- @email 1905333456@qq.com


local cache_store = nil;
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_cache_store");


local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end
 
local _M = new_tab(0, 50)
_M._VERSION = '0.01'
local mt = { __index = _M }


function _M:new(business)
    cache_store = require("utils.tl_ops_utils_store"):new(business);
    return setmetatable({}, mt)
end


-- get
function _M:get( key )
    if key == nil then
        return nil;
    end

    local store = cache_store:read( key );
	
	if not store or store == nil then
		return nil, "failed to get " .. key  .. " from store";
    end

    tlog:dbg("get cache store ok key=" .. key)
    
	return store.value
end


--set
function _M:set(key, value)
    if key == nil then
        return nil;
    end
    
    cache_store:store(key , value);

    tlog:dbg("set cache store ok key=" .. key)

    return 0;
end


--del
function _M:del(key)
    if key == nil then
        return nil;
    end

    ---- set seek to 4GB 等价删除索引
    cache_store:store_index(key, 4 * 1024 * 1024 * 1024) 

    tlog:dbg("del cache store ok key=" .. key)

    return 0;
end


return _M;