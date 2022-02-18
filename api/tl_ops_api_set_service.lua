-- tl_ops_api 
-- en : set balance service node config list
-- zn : 更新路由服务节点配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_health = require("constant.tl_ops_constant_health");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local tl_ops_health_check_version = require("health.tl_ops_health_check_version")


local tl_ops_balance_service_rule,_ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.service_rule, 1);
if not tl_ops_balance_service_rule or tl_ops_balance_service_rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err1", _);
    return;
end

local tl_ops_balance_service_list,_ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.cache_key.service_list, 1);
if not tl_ops_balance_service_list or tl_ops_balance_service_list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err2", _);
    return;
end

local new_service_name ,_ = tl_ops_utils_func:get_req_post_args_by_name('new_service_name', 1);
if new_service_name == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err3", _);
    return;
end

---- 更新生成id
for key,_ in pairs(tl_ops_balance_service_list) do
    for _, service in ipairs(tl_ops_balance_service_list[key]) do
        service.id = snowflake.generate_id( 100 )
        service.updatetime = ngx.localtime()
    end
end


local cache_list, _ = cache:set(tl_ops_constant_balance.cache_key.service_list, cjson.encode(tl_ops_balance_service_list));
if not cache_list then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err", _)
    return;
end


local cache_rule, _ = cache:set(tl_ops_constant_balance.cache_key.service_rule, tl_ops_balance_service_rule);
if not cache_rule then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", _)
    return;
end


local is_add_service , _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_health.cache_key.service_options_version, 1);
if is_add_service and is_add_service == true then
    ---- 对service_options_version更新，通知timer检查是否有新增service
    tl_ops_health_check_version.incr_service_option_version();
end

---- 对service version更新，通知worker更新所有conf
for service_name , _ in pairs(tl_ops_balance_service_list) do
    tl_ops_health_check_version.incr_service_version(service_name);
end


---- 新增service逻辑分支
if new_service_name ~= '' then
    ---- 同步健康检查配置
    local health_list_str, _ = cache:get(tl_ops_constant_health.cache_key.options_list);
    if not health_list_str or health_list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found health list", _);
        return;
    end
    local health_list_table = cjson.decode(health_list_str);
    local new_service_health_option = tl_ops_constant_health.options[1];
    new_service_health_option.check_service_name = new_service_name
    table.insert(health_list_table, new_service_health_option)

    local health_res, _ = cache:set(tl_ops_constant_health.cache_key.options_list, cjson.encode(health_list_table));
    if not health_res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "init health conf err ", _)
        return;
    end

    ---- 同步熔断限流配置
    local limit_list_str, _ = cache:get(tl_ops_constant_limit.fuse.cache_key.options_list);
    if not limit_list_str or limit_list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found limit list", _);
        return;
    end
    local limit_list_table = cjson.decode(limit_list_str);
    local new_service_limit_option = tl_ops_constant_limit.fuse.options[1];
    new_service_limit_option.service_name = new_service_name
    table.insert(limit_list_table, new_service_limit_option)

    local limit_res, _ = cache:set(tl_ops_constant_limit.fuse.cache_key.options_list, cjson.encode(limit_list_table));
    if not limit_res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "init limit conf err ", _)
        return;
    end
end



local res_data = {}
res_data[tl_ops_constant_balance.cache_key.service_rule] = tl_ops_balance_service_rule
res_data[tl_ops_constant_balance.cache_key.service_list] = tl_ops_balance_service_list


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data)