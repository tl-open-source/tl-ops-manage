-- tl_ops_waf_count
-- en : waf count core impl
-- zn : waf统计实现
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson                     = require("cjson.safe")
local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_waf_count")
local tl_ops_utils_func         = require("utils.tl_ops_utils_func")
local tl_ops_constant_waf       = require("constant.tl_ops_constant_waf")
local tl_ops_constant_service   = require("constant.tl_ops_constant_service")
local cache_service             = require("cache.tl_ops_cache_core"):new("tl-ops-service")
local tl_ops_manage_env         = require("tl_ops_manage_env")
local shared                    = ngx.shared.tlopswaf


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 需要提前定义，定时器访问不了
local tl_ops_waf_count_timer



local tl_ops_waf_count_keys = function(waf_interval_success_key, service_name, node_id)

    local req_ip_key = tl_ops_constant_waf.cache_key.req_ip
    if service_name ~= nil or node_id ~= nil then
        req_ip_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_ip, service_name, node_id)
    end
    local req_ip_count = shared:get(req_ip_key)
    if not req_ip_count then
        req_ip_count = 0
    end

    local req_api_key = tl_ops_constant_waf.cache_key.req_api
    if service_name ~= nil or node_id ~= nil then
        req_api_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_api, service_name, node_id)
    end
    local req_api_count = shared:get(req_api_key)
    if not req_api_count then
        req_api_count = 0
    end

    local req_cc_key = tl_ops_constant_waf.cache_key.req_cc
    if service_name ~= nil or node_id ~= nil then
        req_cc_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_cc, service_name, node_id)
    end
    local req_cc_count = shared:get(req_cc_key)
    if not req_cc_count then
        req_cc_count = 0
    end

    local req_cookie_key = tl_ops_constant_waf.cache_key.req_cookie
    if service_name ~= nil or node_id ~= nil then
        req_cookie_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_cookie, service_name, node_id)
    end
    local req_cookie_count = shared:get(req_cookie_key)
    if not req_cookie_count then
        req_cookie_count = 0
    end

    local req_header_key = tl_ops_constant_waf.cache_key.req_header
    if service_name ~= nil or node_id ~= nil then
        req_header_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_header, service_name, node_id)
    end
    local req_header_count = shared:get(req_header_key)
    if not req_header_count then
        req_header_count = 0
    end

    local req_param_key = tl_ops_constant_waf.cache_key.req_param
    if service_name ~= nil or node_id ~= nil then
        req_param_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_param, service_name, node_id)
    end
    local req_param_count = shared:get(req_param_key)
    if not req_param_count then
        req_param_count = 0
    end

    local cur_count = req_ip_count + req_api_count + req_cc_count + req_cookie_count + req_header_count + req_param_count
    if cur_count == 0 then
        tlog:dbg("waf count dont need async , cur_count=",cur_count,",service_name=",service_name,",node_id=",node_id)
    else
        -- push to list
        local key = tl_ops_utils_func:gen_node_key(waf_interval_success_key, service_name, node_id)
        local waf_interval_success = cache_waf_count:get001(key)
        if not waf_interval_success then
            waf_interval_success = {}
        else
            waf_interval_success = cjson.decode(waf_interval_success)
        end

        waf_interval_success[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
        local ok, _ = cache_waf_count:set001(key, cjson.encode(waf_interval_success))
        if not ok then
            tlog:err("waf success count async err ,key=",key,",cur_count=",cur_count,",err=",_)
        end

        -- rest cur_count
        local ok, _ = shared:set(req_ip_key, 0)
        if not ok then
            tlog:err("waf req_ip_key count reset err ,req_ip_key=",req_ip_key,",cur_count=",cur_count)
        end
        ok, _ = shared:set(req_api_key, 0)
        if not ok then
            tlog:err("waf req_api_key count reset err ,req_api_key=",req_api_key,",cur_count=",cur_count)
        end
        ok, _ = shared:set(req_cc_key, 0)
        if not ok then
            tlog:err("waf req_cc_key count reset err ,req_cc_key=",req_cc_key,",cur_count=",cur_count)
        end
        ok, _ = shared:set(req_cookie_key, 0)
        if not ok then
            tlog:err("waf req_cookie_key count reset err ,req_cookie_key=",req_cookie_key,",cur_count=",cur_count)
        end
        ok, _ = shared:set(req_header_key, 0)
        if not ok then
            tlog:err("waf req_header_key count reset err ,req_header_key=",req_header_key,",cur_count=",cur_count)
        end
        ok, _ = shared:set(req_param_key, 0)
        if not ok then
            tlog:err("waf req_param_key count reset err ,req_param_key=",req_param_key,",cur_count=",cur_count)
        end

        tlog:dbg("waf count async ok ,key=",key,",waf_interval_success=",waf_interval_success)
    end

end


-- 统计器 ： 持久化数据
local tl_ops_waf_count = function()
    local lock_key = tl_ops_constant_waf.cache_key.lock
    local lock_time = tl_ops_constant_waf.count.interval - 0.01
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    local service_list = nil
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str then
        -- use default
        service_list = tl_ops_constant_service.list
    else
        service_list = cjson.decode(service_list_str);
    end
    

    -- 控制细度 ，以周期为分割，仅用store持久
    local count_name = "tl-ops-waf-count-" .. tl_ops_constant_waf.count.interval;
    local cache_waf_count = require("cache.tl_ops_cache_core"):new(count_name);

    for service_name, nodes in pairs(service_list) do
        if nodes == nil then
            tlog:err("nodes nil")
            return
        end
        -- 服务级别waf
        tl_ops_waf_count_keys(tl_ops_constant_waf.cache_key.waf_interval_success, service_name, nil)
    end
    -- 全局级别waf
    tl_ops_waf_count_keys(tl_ops_constant_waf.cache_key.waf_interval_success, nil, nil)
end



-- 统计waf次数周期默认为5min，可调整配置
tl_ops_waf_count_timer = function(premature, args)
	if premature then
		return
    end

	local ok, _ = pcall(tl_ops_waf_count)
	if not ok then
		tlog:err("failed to pcall : " ,  _)
    end

	local ok, _ = ngx.timer.at(tl_ops_constant_waf.count.interval, tl_ops_waf_count_timer, args)
	if not ok then
		tlog:err("failed to create timer: " , _)
    end

end

-- 启动
function _M:tl_ops_waf_count_timer_start() 
    if not tl_ops_manage_env.waf.counting then
        tlog:err("waf counting not open " ,_)
        return
    end

	local ok, _ = ngx.timer.at(0, tl_ops_waf_count_timer, nil)
	if not ok then
		tlog:err("failed to run default args , create timer failed " ,_)
		return nil
    end
end


function _M:new()
	return setmetatable({}, mt)
end


return _M