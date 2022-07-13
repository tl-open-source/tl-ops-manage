-- tl_ops_waf
-- en : waf core api
-- zn : waf对外接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_waf_core           = require("waf.tl_ops_waf_core"):new();
local tl_ops_constant_waf_scope = require("constant.tl_ops_constant_waf_scope")

local _M = {}

-- 开启waf
function _M:init_global()

    tl_ops_waf_core:tl_ops_waf_global_core()
    
end

-- 开启waf
function _M:init_service(scope)

    tl_ops_waf_core:tl_ops_waf_service_core()
    
end

return _M
