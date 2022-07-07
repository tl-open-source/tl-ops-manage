-- tl_ops_limit
-- en : sliding window 
-- zn : 滑动窗口流控
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson             = require("cjson.safe");
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_limit_sliding_window");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local _M = {
    _VERSION = '0.02'
}
local mt = { __index = _M }



function _M:new( options )
	return setmetatable({options = options}, mt)
end



-- sliding init
function _M:init()


end



-- sliding?
function _M:tl_ops_limit_sliding( )
    
end