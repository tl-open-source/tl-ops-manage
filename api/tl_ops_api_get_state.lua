-- tl_ops_api 
-- en : get server current state
-- zn : 获取状态数据
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_health_state");
local shared = ngx.shared.tlopsbalance


----返回的cache state
local cache_state = {
    service = {}, health = {}, limit = {}, balance = {}
}

local limit_options_str, _ = cache_service:get(tl_ops_constant_limit.fuse.cache_key.options_list);
if not limit_options_str or limit_options_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
    return;
end
local limit_options_list = cjson.decode(limit_options_str)


---- 服务相关状态
local list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
if not list_str or list_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found ,"not found list", _);
    return;
end
local service_list = cjson.decode(list_str)


for service_name, nodes in pairs(service_list) do
    ---- service级别cache
    local health_lock_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.lock, service_name))
    if not health_lock_cache then
        health_lock_cache = false ----"lock cache nil"
    end
    local health_version_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, service_name))
    if not health_version_cache then
        health_version_cache = 0 ----"version cache nil"
    end

    local limit_state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name))
    if not limit_state_cache then
        limit_state_cache = 0 ----"state cache nil"
    end
    local limit_version_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_version, service_name))
    if not limit_version_cache then
        limit_version_cache = 0 ----"version cache nil"
    end

    cache_state.service[service_name] = {
        health_lock = health_lock_cache,
        health_version = health_version_cache,
        limit_state = limit_state_cache,
        limit_version = limit_version_cache,
    }
    cache_state.service[service_name].nodes = { }

    if nodes == nil then
		nodes = cjson.encode("{}")
	end
 
    ---- node级别cache
    for i = 1, #nodes do
        local node_id = i-1
        local node = nodes[i]

        local health_node_state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, node.service, node_id))
        if not health_node_state_cache then
            health_node_state_cache = false ----"state cache nil"
        end
        local health_node_failed_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, node.service, node_id))
        if not health_node_failed_cache then
            health_node_failed_cache = 0 ----"failed cache nil"
        end
        local health_node_success_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, node.service, node_id))
        if not health_node_success_cache then
            health_node_success_cache = 0 ----"success cache nil"
        end

        local limit_node_state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, node.service, node_id))
        if not limit_node_state_cache then
            limit_node_state_cache = 0 ----"state cache nil"
        end

		local limit_node_success_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, node.service, node_id))
		if not limit_node_success_cache then
			limit_node_success_cache = 0 ----"success cache nil"
		end

		local limit_node_failed_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail,  node.service, node_id))
		if not limit_node_failed_cache then
			limit_node_failed_cache = 0 ----"failed cache nil"
		end

        local count_name = "tl-ops-balance-count-" .. tl_ops_constant_balance.count.interval;
        local cache_balance_count = require("cache.tl_ops_cache"):new(count_name);
        local balance_success_cache = cache_balance_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.balance_5min_success, node.service, node_id)) 
        if not balance_success_cache then
            balance_success_cache = "{}"
        end

        cache_state.service[service_name].nodes[node.name] = {
            health_state = health_node_state_cache,
            health_failed = health_node_failed_cache,
            health_success = health_node_success_cache,
            limit_state = limit_node_state_cache,
            limit_success = limit_node_success_cache,
            limit_failed = limit_node_failed_cache,
            balance_success =  cjson.decode(balance_success_cache),
        }
    end

end



---- 健康检查相关状态
local health_options_str, _ = cache_service:get(tl_ops_constant_health.cache_key.options_list);
if not health_options_str or health_options_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
    return;
end
local health_options_list = cjson.decode(health_options_str)

local service_options_version_cache, _ = shared:get(tl_ops_constant_health.cache_key.service_options_version)
if not service_options_version_cache then
    service_options_version_cache = false ----"options version nil"
end

local timers_str = shared:get(tl_ops_constant_health.cache_key.timers)
if not timers_str then
    timers_str = "{}" ----"timers nil"
end
local timer_list = cjson.decode(timers_str)

cache_state.health['timer_list'] = timer_list
cache_state.health['options_version'] = service_options_version_cache
cache_state.health['options_list'] = health_options_list



---- 限流相关状态
local limit_options_str, _ = cache_service:get(tl_ops_constant_limit.fuse.cache_key.options_list);
if not limit_options_str or limit_options_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
    return;
end
local limit_options_list = cjson.decode(limit_options_str)

local pre_time = shared:get(tl_ops_constant_limit.global_token.cache_key.pre_time)
if not pre_time then
    pre_time = "nil" ----"pre_time nil"
end
local token_bucket = shared:get(tl_ops_constant_limit.global_token.cache_key.token_bucket)
if not token_bucket then
    token_bucket = "nil" ----"token_bucket nil"
end
local warm = shared:get(tl_ops_constant_limit.global_token.cache_key.warm)
if not warm then
    warm = "nil" ----"warm nil"
end
local lock = shared:get(tl_ops_constant_limit.global_token.cache_key.lock)
if not lock then
    lock = "nil" ----"lock nil"
end
cache_state.limit['pre_time'] = pre_time
cache_state.limit['token_bucket'] = token_bucket
cache_state.limit['warm'] = warm
cache_state.limit['lock'] = lock
cache_state.limit['option_list'] = limit_options_list
-- cache_state.limit['token'] = tl_ops_limit_token_bucket:tl_ops_limit_token( 10 * 1024 )


---- 路由相关
local balance_pre_time = shared:get(tl_ops_constant_balance.cache_key.balance_pre_time)
if not balance_pre_time then
    balance_pre_time = "nil" ----"balance_pre_time nil"
end
cache_state.balance['pre_time'] = balance_pre_time
cache_state.balance['dict_keys'] = shared:get_keys(1024)
cache_state.balance['count_interval'] = tl_ops_constant_balance.count.interval


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", cache_state);