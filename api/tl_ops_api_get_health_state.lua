-- tl_ops_api 
-- en : get health check current state
-- zn : 获取健康检测状态数据
-- @author iamtsm
-- @email 1905333456@qq.com


local ngx = require("ngx")
local cjson = require("cjson");
local cache = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_heath_state");

local shared = ngx.shared.tlopsbalance

local list, err = cache:get(tl_ops_constant_balance.service.list.cache_key);
if not list or list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found ,"not found list", err);
    return;
end

local service_list = cjson.decode(list)

---- 获取所有cache
local health_options = tl_ops_constant_health.options
local health_cache_key = tl_ops_constant_health.cache_key

----返回的cache date
local cache_data = {}

for i = 1, #health_options do
    local option = health_options[i]
    local check_service_name = option.check_service_name;

    ---- service级别cache
    local lock_cache = shared:get(tl_ops_utils_func:gen_peer_key(health_cache_key.lock, check_service_name))
    if not lock_cache then
        lock_cache = "lock cache nil"
    end
    local version_cache = shared:get(tl_ops_utils_func:gen_peer_key(health_cache_key.version, check_service_name))
    if not version_cache then
        version_cache = "version cache nil"
    end
    cache_data[check_service_name] = {
        lock = lock_cache,
        version = version_cache
    }

    ---- 拿到对应的service
    local service = service_list[check_service_name]
    for i = 1, #service do
        local peer_id = i-1
        local peer = service[i]
        local peer_name = peer.name

        tlog:dbg(peer)

        ---- peer级别cache
        local state_cache = shared:get(tl_ops_utils_func:gen_peer_key(health_cache_key.state, peer.service, peer_id))
        if not state_cache then
            state_cache = "state cache nil"
        end
        local failed_cache = shared:get(tl_ops_utils_func:gen_peer_key(health_cache_key.failed, peer.service, peer_id))
        if not failed_cache then
            failed_cache = "failed cache nil"
        end
        local success_cache = shared:get(tl_ops_utils_func:gen_peer_key(health_cache_key.success, peer.service, peer_id))
        if not success_cache then
            success_cache = "success cache nil"
        end

        cache_data[check_service_name][peer_name] = {
            state = state_cache,
            failed = failed_cache,
            success = success_cache
        }

    end

end


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", cache_data);