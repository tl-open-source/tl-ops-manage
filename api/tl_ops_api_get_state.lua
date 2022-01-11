-- tl_ops_api 
-- en : get server current state
-- zn : 获取状态数据
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local cache = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_health_state");
local shared = ngx.shared.tlopsbalance


----返回的cache state
local cache_state = {
    service = {},
    configs = {}
}


---- service list
local list_str, err = cache:get(tl_ops_constant_balance.service.list.cache_key);
if not list_str or list_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found ,"not found list", err);
    return;
end
local service_list = cjson.decode(list_str)

for service_name, nodes in pairs(service_list) do
    cache_state.service[service_name] = {}

    ---- service级别cache
    local lock_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.lock, service_name))
    if not lock_cache then
        lock_cache = false ----"lock cache nil"
    end
    local version_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, service_name))
    if not version_cache then
        version_cache = 0 ----"version cache nil"
    end
 
    ---- node级别cache
    for i = 1, #nodes do
        local node_id = i-1
        local node = nodes[i]

        local state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, node.service, node_id))
        if not state_cache then
            state_cache = 0 ----"state cache nil"
        end
        local failed_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, node.service, node_id))
        if not failed_cache then
            failed_cache = 0 ----"failed cache nil"
        end
        local success_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, node.service, node_id))
        if not success_cache then
            success_cache = 0 ----"success cache nil"
        end

        cache_state.service[service_name][node.name] = {
            state = state_cache,
            failed = failed_cache,
            success = success_cache,
            lock = lock_cache,
            version = version_cache,
        }
    end

end


---- options list
local options_str, _ = cache:get(tl_ops_constant_health.cache_key.options_config);
if not options_str or options_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
    return;
end
local options_list = cjson.decode(options_str)
cache_state.configs['options_list'] = options_list

local service_options_version_cache, err = shared:get(tl_ops_constant_health.cache_key.service_options_version)
if not service_options_version_cache then
    service_options_version_cache = false ----"options version nil"
end
cache_state.configs['service_options_version'] = service_options_version_cache


-- all timers
local timers_str = shared:get(tl_ops_constant_health.cache_key.timers)
if not timers_str then
    timers_str = "{}" ----"timers nil"
end
local timer_list = cjson.decode(timers_str)
cache_state.configs['timer_list'] = timer_list

-- for i = 1, #options_list do
--     local option = options_list[i]
--     local service_name = option.check_service_name

--     option['service_options_version'] = service_options_version_cache
-- end


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", cache_state);