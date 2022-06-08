-- tl_ops_balance
-- en : balance count core api
-- zn : 路由统计对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local tl_ops_balance_count_core = require("balance.count.tl_ops_balance_count_core");

local _M = {}


function _M:init( )

    -- 启动路由统计
    local balance_count = tl_ops_balance_count_core:new();
    balance_count:tl_ops_balance_count_timer_start()

end

return _M
