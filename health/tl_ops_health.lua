-- tl_ops_health
-- en : health check api
-- zn : 健康检查对外接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_health_check               = require("health.tl_ops_health_check");
local tl_ops_health_check_dynamic_conf  = require("health.tl_ops_health_check_dynamic_conf")
local tl_ops_constant_health            = require("constant.tl_ops_constant_health")
local tl_ops_health_check_version       = require("health.tl_ops_health_check_version")

local _M = {}

function _M:init(  )

    --给定配置启动健康检查，支持动态加载已有服务变更配置
    local health_check = tl_ops_health_check:new( 
        tl_ops_constant_health.options,  tl_ops_constant_health.service
    );
    health_check:tl_ops_health_check_start();

    
    --动态加载新增配置
    tl_ops_health_check_dynamic_conf.dynamic_conf_add_start()
    

    --默认初始化一次version
    for i = 1, #tl_ops_constant_health.options do
        local option = tl_ops_constant_health.options[i]
        local service_name = option.check_service_name
        if service_name then
            tl_ops_health_check_version.incr_service_version(service_name)
        end
    end
	
	tl_ops_health_check_version.incr_service_option_version()

end


return _M
