-- tl_ops_cache
-- en : store cache , cache3
-- zn : 自行实现本地文件缓存 缓存实现三级缓存
-- @author iamtsm
-- @email 1905333456@qq.com


local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_cache_store");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
 
local _M = tl_ops_utils_func:new_tab(0, 20)
_M._VERSION = '0.02'
local mt = { __index = _M }


function _M:new(business, store_full)
    local cache_store = require("utils.tl_ops_utils_store"):new(business, store_full);
    return setmetatable({
        business = business,
        cache_store = cache_store
    }, mt)
end


-- get
function _M:get( key )
    if key == nil then
        return nil;
    end

    local store = self.cache_store:read( key );
	
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
    
    self.cache_store:store(key , value);

    tlog:dbg("set cache store ok key=" .. key)

    return 0;
end


--del
function _M:del(key)
    if key == nil then
        return nil;
    end

    -- set seek to 4GB 等价删除索引
    self.cache_store:store_index(key, 4 * 1024 * 1024 * 1024)

    tlog:dbg("del cache store ok key=" .. key)

    return 0;
end


return _M;