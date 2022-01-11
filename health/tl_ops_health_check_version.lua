-- tl_ops_health
-- en : health check notify version 
-- zn : 健康检查配置变动版本通知
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_health_check_version");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local cache_dict = ngx.shared.tlopsbalance;

local _M = {
	_VERSION = '0.01'
}


---- 更新当前service的状态版本，用于通知其他worker进程同步最新conf
local tl_ops_health_check_version_incr_service_version = function( service_name )
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, service_name)
    local service_version, err = cache_dict:get(key)

    if not service_version then
        service_version, err = cache_dict:add(key, 1);
        if not service_version then 
            tlog:err(" failed to publish new service_version:" , err)
        end
    else 
        service_version, err = cache_dict:incr(key, 1);
        if not service_version then 
            tlog:err(" failed to publish new service_version:" , err)
        end
    end

    
    tlog:dbg("service_version key=" , key, ", service_version=",service_version)

    return service_version
end


---- 对service_options_version更新，通知timer检查是否有新增service
local tl_ops_health_check_version_incr_service_option_version = function(  )
    local res, _ = cache_dict:set(tl_ops_constant_health.cache_key.service_options_version, true)

    tlog:dbg("service_option_version key=" , key, ", service_option_version=",res)

    if not res then
        tlog:err(" set service_options_version err " , _)
    end
end

_M = {
    incr_service_version = tl_ops_health_check_version_incr_service_version,
    incr_service_option_version = tl_ops_health_check_version_incr_service_option_version
}


return _M;