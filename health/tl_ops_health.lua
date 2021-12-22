-- tl_ops_health
-- en : health check api
-- zn : 健康检查对外接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_health_check = require("health.tl_ops_health_check");

local _M = {}

function _M:init( )
    local heath_check = tl_ops_health_check:new(
        tl_ops_constant_health.options,
        tl_ops_constant_health.service
    );

    heath_check:tl_ops_heath_start();
end


return _M
