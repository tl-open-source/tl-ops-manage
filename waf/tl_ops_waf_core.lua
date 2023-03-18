-- tl_ops_waf
-- en : waf core impl
-- zn : waf核心实现， waf流程 : ip > api > cc > header > cookie > param
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_waf_core_api		= require("waf.tl_ops_waf_core_api");
local tl_ops_waf_core_ip		= require("waf.tl_ops_waf_core_ip");
local tl_ops_waf_core_cc		= require("waf.tl_ops_waf_core_cc");
local tl_ops_waf_core_header	= require("waf.tl_ops_waf_core_header");
local tl_ops_waf_core_cookie	= require("waf.tl_ops_waf_core_cookie");
local tl_ops_waf_core_param		= require("waf.tl_ops_waf_core_param");
local tl_ops_constant_waf		= require("constant.tl_ops_constant_waf");
local tl_ops_manage_env			= require("tl_ops_manage_env")
local tl_ops_err_content        = require("err.tl_ops_err_content")
local waf_count_service         = require("waf.count.tl_ops_waf_count_service")


local _M = {
	_VERSION = '0.01'
}
local mt = { __index = _M }


-- 全局waf核心流程
function _M:tl_ops_waf_global_core()

	-- 关闭
	if not tl_ops_manage_env.waf.open then
		return true
	end

	local waf = tl_ops_waf_core_ip.tl_ops_waf_core_ip_filter_global_pass()
	if not waf then
		tl_ops_err_content:err_content_rewrite_to_waf("g-ip", tl_ops_constant_waf.cache_key.waf_ip)
        return
	end

	waf = tl_ops_waf_core_api.tl_ops_waf_core_api_filter_global_pass()
	if not waf then
		tl_ops_err_content:err_content_rewrite_to_waf("g-api", tl_ops_constant_waf.cache_key.waf_api)
        return
	end

	waf = tl_ops_waf_core_cc.tl_ops_waf_core_cc_filter_global_pass()
	if not waf then
		tl_ops_err_content:err_content_rewrite_to_waf("g-cc", tl_ops_constant_waf.cache_key.waf_cc)
        return
	end

	waf = tl_ops_waf_core_header.tl_ops_waf_core_header_filter_global_pass()
	if not waf then
		tl_ops_err_content:err_content_rewrite_to_waf("g-header", tl_ops_constant_waf.cache_key.waf_header)
        return
	end

	waf = tl_ops_waf_core_cookie.tl_ops_waf_core_cookie_filter_global_pass()
	if not waf then
		tl_ops_err_content:err_content_rewrite_to_waf("g-cookie", tl_ops_constant_waf.cache_key.waf_cookie)
        return
	end

	waf = tl_ops_waf_core_param.tl_ops_waf_core_param_filter_global_pass()
	if not waf then
		tl_ops_err_content:err_content_rewrite_to_waf("g-param", tl_ops_constant_waf.cache_key.waf_param)
        return
	end

	return true
end


-- 服务waf核心流程
function _M:tl_ops_waf_service_core(service_name)
	-- 关闭
	if not tl_ops_manage_env.waf.open then
		return true
	end
	
	local waf = tl_ops_waf_core_ip.tl_ops_waf_core_ip_filter_service_pass(service_name)
	if not waf then
		waf_count_service.tl_ops_waf_count_incr_service_succ(service_name, "ip");
		tl_ops_err_content:err_content_rewrite_to_waf("s-ip", tl_ops_constant_waf.cache_key.waf_ip)
        return
	end
	
	waf = tl_ops_waf_core_api.tl_ops_waf_core_api_filter_service_pass(service_name)
	if not waf then
		waf_count_service.tl_ops_waf_count_incr_service_succ(service_name, "api");
		tl_ops_err_content:err_content_rewrite_to_waf("s-api", tl_ops_constant_waf.cache_key.waf_api)
        return
	end

	waf = tl_ops_waf_core_cc.tl_ops_waf_core_cc_filter_service_pass(service_name)
	if not waf then
		waf_count_service.tl_ops_waf_count_incr_service_succ(service_name, "cc");
		tl_ops_err_content:err_content_rewrite_to_waf("s-cc", tl_ops_constant_waf.cache_key.waf_cc)
        return
	end

	waf = tl_ops_waf_core_header.tl_ops_waf_core_header_filter_service_pass(service_name)
	if not waf then
		waf_count_service.tl_ops_waf_count_incr_service_succ(service_name, "header");
		tl_ops_err_content:err_content_rewrite_to_waf("s-header", tl_ops_constant_waf.cache_key.waf_header)
        return
	end

	waf = tl_ops_waf_core_cookie.tl_ops_waf_core_cookie_filter_service_pass(service_name)
	if not waf then
		waf_count_service.tl_ops_waf_count_incr_service_succ(service_name, "cookie");
		tl_ops_err_content:err_content_rewrite_to_waf("s-cookie", tl_ops_constant_waf.cache_key.waf_cookie)
        return
	end

	waf = tl_ops_waf_core_param.tl_ops_waf_core_param_filter_service_pass(service_name)
	if not waf then
		waf_count_service.tl_ops_waf_count_incr_service_succ(service_name, "param");
		tl_ops_err_content:err_content_rewrite_to_waf("s-param", tl_ops_constant_waf.cache_key.waf_param)
        return
	end

	return true
end


function _M:new()
	return setmetatable({}, mt)
end


return _M