-- tl_ops_balance
-- en : balance core api
-- zn : 负载均衡对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local tl_ops_balance_core = require("balance.tl_ops_balance_core");

local _M = {}


-- 启动路由筛选
function _M:filter(ctx)
    local balance = tl_ops_balance_core:new();
    balance:tl_ops_balance_core_filter(ctx)
end


-- 启动路由转发
function _M:init(ctx)
    local balance = tl_ops_balance_core:new();
    balance:tl_ops_balance_core_balance(ctx)

end

return _M
