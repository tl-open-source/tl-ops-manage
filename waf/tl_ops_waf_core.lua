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
local tl_ops_waf_count			= require("waf.count.tl_ops_waf_count");
local tl_ops_constant_waf		= require("constant.tl_ops_constant_waf");
local cache_waf					= require("cache.tl_ops_cache_core"):new("tl-ops-waf");
local cjson						= require("cjson.safe");
local tl_ops_utils_func			= require("utils.tl_ops_utils_func");
local tl_ops_manage_env			= require("tl_ops_manage_env")
local tl_ops_err_content        = require("err.tl_ops_err_content")
local shared					= ngx.shared.tlopsbalance


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
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_ip)
		tl_ops_err_content:err_content_rewrite_to_waf("g-ip", tl_ops_constant_waf.cache_key.waf_ip)
        return
	end

	waf = tl_ops_waf_core_api.tl_ops_waf_core_api_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_api)
		tl_ops_err_content:err_content_rewrite_to_waf("g-api", tl_ops_constant_waf.cache_key.waf_api)
        return
	end

	waf = tl_ops_waf_core_cc.tl_ops_waf_core_cc_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_cc)
		tl_ops_err_content:err_content_rewrite_to_waf("g-cc", tl_ops_constant_waf.cache_key.waf_cc)
        return
	end

	waf = tl_ops_waf_core_header.tl_ops_waf_core_header_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_header)
		tl_ops_err_content:err_content_rewrite_to_waf("g-header", tl_ops_constant_waf.cache_key.waf_header)
        return
	end

	waf = tl_ops_waf_core_cookie.tl_ops_waf_core_cookie_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_cookie)
		tl_ops_err_content:err_content_rewrite_to_waf("g-cookie", tl_ops_constant_waf.cache_key.waf_cookie)
        return
	end

	waf = tl_ops_waf_core_param.tl_ops_waf_core_param_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_param)
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
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_ip, service_name)
		tl_ops_err_content:err_content_rewrite_to_waf("s-ip", tl_ops_constant_waf.cache_key.waf_ip)
        return
	end
	
	waf = tl_ops_waf_core_api.tl_ops_waf_core_api_filter_service_pass(service_name)
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_api, service_name)
		tl_ops_err_content:err_content_rewrite_to_waf("s-api", tl_ops_constant_waf.cache_key.waf_api)
        return
	end

	waf = tl_ops_waf_core_cc.tl_ops_waf_core_cc_filter_service_pass(service_name)
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_cc, service_name)
		tl_ops_err_content:err_content_rewrite_to_waf("s-cc", tl_ops_constant_waf.cache_key.waf_cc)
        return
	end

	waf = tl_ops_waf_core_header.tl_ops_waf_core_header_filter_service_pass(service_name)
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_header, service_name)
		tl_ops_err_content:err_content_rewrite_to_waf("s-header", tl_ops_constant_waf.cache_key.waf_header)
        return
	end

	waf = tl_ops_waf_core_cookie.tl_ops_waf_core_cookie_filter_service_pass(service_name)
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_cookie, service_name)
		tl_ops_err_content:err_content_rewrite_to_waf("s-cookie", tl_ops_constant_waf.cache_key.waf_cookie)
        return
	end

	waf = tl_ops_waf_core_param.tl_ops_waf_core_param_filter_service_pass(service_name)
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_param, service_name)
		tl_ops_err_content:err_content_rewrite_to_waf("s-param", tl_ops_constant_waf.cache_key.waf_param)
        return
	end

	return true
end


function _M:new()
	return setmetatable({}, mt)
end


return _M