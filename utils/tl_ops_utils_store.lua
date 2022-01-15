-- tl_ops_utils
-- en : store
-- zn : 自实现简要文件存储
-- @author iamtsm
-- @email 1905333456@qq.com

local ngx = require "ngx"
local cjson = require("cjson.safe")
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_utils_store");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;

local _M = {}

---- store json index file
---- 写索引文件
function _M:store_index( key , seek)
	---- 最大支持4GB
	if seek > 4 * 1024 * 1024 * 1024 then
		tlog:err("not allowed seek store-index : " .. seek)
		return
	end
	---- add index
	local content = self:read_index();
	if not content or content == nil then
		content = {}
	end
	content[key] = seek;

	local store_file_name = self.path .. self.business .. ".tlindex"
    local store_file_io, _ = io.open(store_file_name, "w+")  ---- 覆盖index
    if not store_file_io then
    	tlog:err("failed to open file in store-index: " .. store_file_name)
        return
	end

	local content_json = cjson.encode(content)
    store_file_io:write(content_json .. "\n")
    store_file_io:flush()
    store_file_io:close()
end


---- store json file
---- 写内容文件
function _M:store( key,  ... )
	local store_file_name = self.path .. self.business .. ".tlstore"
	local store_file_io, _ = io.open(store_file_name, "a+")  ---- 追加内容
    if not store_file_io then
    	tlog:err("failed to open file in store: " .. store_file_name)
        return
	end

	---- store index
	local file_size = store_file_io:seek("end");
	if file_size == 0 then
		self:store_index(key ,0)
	else
		self:store_index(key ,file_size)
	end
	
	local store_data = {
        time = os.date("%Y-%m-%d %H:%M:%S", ngx.now()),
        business = self.business,
        value = tl_ops_utils_func:data_to_string( {...} )
	}
    local store_data_encode = cjson.encode(store_data)
	
    store_file_io:write(store_data_encode .. "\n")
    store_file_io:flush()
    store_file_io:close()
end


---- read json index file
---- 读索引文件
function _M:read_index( key )
	local store_file_name = self.path .. self.business .. ".tlindex"
	local store_file_io, _ = io.open(store_file_name, "r")
    if not store_file_io then
    	tlog:err("failed to open file in read: " .. store_file_name)
        return
	end

	local content_json = store_file_io:read('*all')	---- 所有内容
	
	local content = cjson.decode(content_json);

	if key and type(key) == 'string' and key ~= '' then  ---- 返回 seek
		return content[key] ,nil
	end

	store_file_io:close()
    return content	----返回 {key:seek,...}
end


---- read json file
---- 写内容文件
function _M:read( key )
	local store_file_name = self.path .. self.business .. ".tlstore"
	local store_file_io, _ = io.open(store_file_name, "r")
    if not store_file_io then
    	tlog:err("failed to open file in read: " .. store_file_name)
        return
	end

	local key_seek, _ = self:read_index(key);

	store_file_io:seek("set", key_seek);

	local content_json = store_file_io:read('*l')	---- 读一行
	local content = cjson.decode(content_json);

	store_file_io:close()
    return content, nil
end



function _M:new(business)
	local current_path = tl_ops_utils_func:get_current_dir_path('/utils', '/store/');
	local store_conf = {
		path = current_path,
		business = business
	}
 	setmetatable(store_conf, self)
	self.__index = self
	 
  	return store_conf
end

return _M