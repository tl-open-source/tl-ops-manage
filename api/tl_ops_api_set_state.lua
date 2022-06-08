-- tl_ops_set_state
-- en : set node state
-- zn : 更新服务/节点状态
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local snowflake = require("lib.snowflake");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health")
local tl_ops_health_check_version = require("health.tl_ops_health_check_version")
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");

local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_state");
local shared = ngx.shared.tlopsbalance


local tl_ops_state_cmd, _ = tl_ops_utils_func:get_req_post_args_by_name("cmd", 1);
if not tl_ops_state_cmd or tl_ops_state_cmd == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err1", _);
    return;
end


local cmd_status = false;

-- 暂停自检
if tl_ops_state_cmd == 'pause-health-check' then

    local tl_ops_state_service, _ = tl_ops_utils_func:get_req_post_args_by_name("service", 1);
    if not tl_ops_state_service or tl_ops_state_service == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err2", _);
        return;
    end

    local uncheck_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.uncheck, tl_ops_state_service)
	local res, _ = shared:set(uncheck_key, true)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set uncheck true failed ",_);
        return;
    end
    
    cmd_status = true;
end


-- 重启自检
if tl_ops_state_cmd == 'un-pause-health-check' then
    
    local tl_ops_state_service, _ = tl_ops_utils_func:get_req_post_args_by_name("service", 1);
    if not tl_ops_state_service or tl_ops_state_service == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err3", _);
        return;
    end

    local uncheck_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.uncheck, tl_ops_state_service)
	local res, _ = shared:set(uncheck_key, false)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set uncheck false failed ",_);
        return;
    end
    
    cmd_status = true;
end


-- 下线服务节点
if tl_ops_state_cmd == 'offline-service-node' then
    
    local tl_ops_state_service, _ = tl_ops_utils_func:get_req_post_args_by_name("service", 1);
    if not tl_ops_state_service or tl_ops_state_service == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err4", _);
        return;
    end

    local tl_ops_state_node_id, _ = tl_ops_utils_func:get_req_post_args_by_name("node_index", 1);
    if not tl_ops_state_node_id or tl_ops_state_node_id == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err5", _);
        return;
    end

    -- local success_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, tl_ops_state_service, tl_ops_state_node_id)
	-- res, _ = shared:get(success_key)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health get success count failed ",_);
    --     return;
    -- end
    
    -- local failed_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, tl_ops_state_service, tl_ops_state_node_id)
	-- res, _ = shared:get(failed_key)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health get failed count failed ",_);
    --     return;
    -- end

    local state_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, tl_ops_state_service, tl_ops_state_node_id)
	local res, _ = shared:get(state_key)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health get state failed ",_);
        return;
    end

    local uncheck_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.uncheck, tl_ops_state_service)
    res, _ = shared:set(uncheck_key, true)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set uncheck false failed ",_);
        return;
    end

    res, _ = shared:set(state_key, false)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set state false failed ",_);
        return;
    end

    -- 通知conf更新
    tl_ops_health_check_version.incr_service_version(tl_ops_state_service)

    -- res, _ = shared:set(success_key, 0)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set success 0 failed ",_);
    --     return;
    -- end

    -- res, _ = shared:set(failed_key, 0)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set failed 0 failed ",_);
    --     return;
    -- end

    cmd_status = true;
end

-- 上线服务所有节点
if tl_ops_state_cmd == 'online-service-node' then
    
    local tl_ops_state_service, _ = tl_ops_utils_func:get_req_post_args_by_name("service", 1);
    if not tl_ops_state_service or tl_ops_state_service == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err4", _);
        return;
    end

    local tl_ops_state_node_id, _ = tl_ops_utils_func:get_req_post_args_by_name("node_index", 1);
    if not tl_ops_state_node_id or tl_ops_state_node_id == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err5", _);
        return;
    end

    -- local success_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, tl_ops_state_service, tl_ops_state_node_id)
	-- res, _ = shared:get(success_key)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health get success count failed ",_);
    --     return;
    -- end
    
    -- local failed_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, tl_ops_state_service, tl_ops_state_node_id)
	-- res, _ = shared:get(failed_key)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health get failed count failed ",_);
    --     return;
    -- end


    local uncheck_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.uncheck, tl_ops_state_service)
    local res, _ = shared:set(uncheck_key, false)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set uncheck false failed ",_);
        return;
    end

    local state_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, tl_ops_state_service, tl_ops_state_node_id)
    res, _ = shared:set(state_key, true)
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set state false failed ",_);
        return;
    end

    -- res, _ = shared:set(success_key, 0)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set success 0 failed ",_);
    --     return;
    -- end

    -- res, _ = shared:set(failed_key, 0)
    -- if not res then
    --     tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"health set failed 0 failed ",_);
    --     return;
    -- end

    cmd_status = true;
end

local res_data = {}
res_data[tl_ops_state_cmd] = cmd_status


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data)