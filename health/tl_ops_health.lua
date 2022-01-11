-- tl_ops_health
-- en : health check api
-- zn : 健康检查对外接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_health_check = require("health.tl_ops_health_check");
local tl_ops_health_check_dynamic_conf = require("health.tl_ops_health_check_dynamic_conf")
local tl_ops_constant_health = require("constant.tl_ops_constant_health");

local _M = {}

function _M:init(  )

    --给定配置启动健康检查，支持动态加载已有服务变更配置
    local health_check = tl_ops_health_check:new( 
        tl_ops_constant_health.options,  tl_ops_constant_health.service
    );
    health_check:tl_ops_health_check_start();

    --动态加载新增配置
    tl_ops_health_check_dynamic_conf.tl_ops_health_check_dynamic_conf_add_start()

end


return _M
