-- tl_ops_utils
-- en : logs
-- zn : 日志
-- @author iamtsm
-- @email 1905333456@qq.com

local ngx = require "ngx"
local cjson_safe = require("cjson.safe")
local tl_ops_constant_log = require("constant.tl_ops_constant_log")

local _M = {
	debug = 1,
	std = 2,
	error = 3
}

local function get_table_msg(t)
	local content = "["
	for k, v in pairs(t) do
		local msg
		if type(v) == "table" then
			msg = get_table_msg(v)
		else
			msg = tostring(v)
		end
		content = content .. k .. "=" .. msg .. ";"
	end
	return content .. "]"
end


local function concate_msg(t)
	local content = ""
	for _, v in pairs(t) do
		if type(v) == "table" then
			content = content .. get_table_msg(v)
		else
			content = content .. tostring(v)
		end
	end
	return content
end


local function log(self, level,  ... )
	local log_file_name = self.dir .. os.date("%Y%m%d%H", ngx.now()) .. "_" .. self.module .. ".log"
	local t = { ... }
	local msg = concate_msg(t)
	local time = os.date("%Y-%m-%d %H:%M:%S", ngx.now())

    local log_file, _ = io.open(log_file_name, "a")
    if not log_file then
    	ngx.log(ngx.ERR, "failed to open file:", log_file_name, ";err=", _)
        return
	end
	
	if not self.format_json then ---- 一行输出log
		local log_line_inline = cjson_safe.encode({
			time = time,module = self.module,level = level,msg = msg
		})
		log_file:write(log_line_inline .. ",\n")
	else ---- json格式化输出log
		local log_line_json = "{\n\t'time':" .. cjson_safe.encode(time) .. ",'module':" .. cjson_safe.encode(self.module) .. 
							",'level':" .. cjson_safe.encode(level) .. ",\n\t'msg':" .. cjson_safe.encode(msg) .. "\n},\n";
		log_file:write(log_line_json)
	end

    log_file:flush()
    log_file:close()
end


---- 输出log到ngx中
function _M:ngx_debug( ... )
	ngx.log(ngx.DEBUG, self.module, ...)
end


---- 输出log到自定义文件中
function _M:dbg(...)
	if self.level > _M.debug then
		return
	end
	log(self, "debug", ...)
end

function _M:err(...)
	if self.level > _M.error then
		return
	end
	log(self, "error", ...)
end


function _M:new(module)
	self.__index = self
	
  	return setmetatable({
		level = _M.debug,
		module = module,
		dir = tl_ops_constant_log.log_dir,
		format_json = tl_ops_constant_log.format_json
	}, self)
end

return _M