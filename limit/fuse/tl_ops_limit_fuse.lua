-- tl_ops_limit
-- en : limit fuse check api
-- zn : 限流熔断对外接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_limit_fuse_check_dynamic_conf = require("limit.fuse.tl_ops_limit_fuse_check_dynamic_conf")
local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")
local tl_ops_limit_fuse_check = require("limit.fuse.tl_ops_limit_fuse_check")

local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local _M = {}

function _M:init(  )

    -- 给定配置启动限流熔断检查，支持动态加载已有服务变更配置
    local limit_fuse = tl_ops_limit_fuse_check:new( 
        tl_ops_constant_limit.fuse.options,  tl_ops_constant_limit.fuse.service
    );
    limit_fuse:tl_ops_limit_fuse_start();

    
    -- 启动动态新增配置检测
    tl_ops_limit_fuse_check_dynamic_conf.dynamic_conf_add_start()
    

    -- 默认初始化一次version
    for i = 1, #tl_ops_constant_limit.fuse.options do
        local option = tl_ops_constant_limit.fuse.options[i]
        local service_name = option.service_name
        if service_name then
            tl_ops_limit_fuse_check_version.incr_service_version(service_name)
        end
    end
    
    -- 启动动态检测配置版本
	tl_ops_limit_fuse_check_version.incr_service_option_version()

end


return _M
