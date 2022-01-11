-- tl_ops_limit
-- en : token bucket
-- zn : 令牌流控
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_limit_token_bucket");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end


local _M = {
    _VERSION = '0.01'
}
local mt = { __index = _M }



function _M:new( options )
	return setmetatable({options = options}, mt)
end



---- token bucket init
function _M:init()


end



---- get token
function _M:tl_ops_limit_token( )
    
end