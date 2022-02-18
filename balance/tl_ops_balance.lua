-- tl_ops_balance
-- en : balance core api
-- zn : 负载均衡对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local tl_ops_balance_core = require("balance.tl_ops_balance_core");
local tl_ops_balance_count = require("balance.tl_ops_balance_count")

local _M = {}


function _M:init( )

    -- 启动路由
    local balance = tl_ops_balance_core:new();
    balance:tl_ops_balance_api_balance()

end

return _M
