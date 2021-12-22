-- tl_ops_api 
-- en : set balance service node config list
-- zn : 更新负载服务节点配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local cache = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local tl_ops_service_list,err = tl_ops_utils_func:get_req_post_args_by_name("tl_ops_service_list", 1);
if not tl_ops_service_list or tl_ops_service_list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err", err);
    return;
end

local tl_ops_service_rule,err = tl_ops_utils_func:get_req_post_args_by_name("tl_ops_service_rule", 1);
if not rule or rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err", err);
    return;
end


local cache_list, err = cache:set(tl_ops_constant_balance.service.list.cache_key, cjson.encode(tl_ops_service_list));
if not cache_list then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err", err)
    return;
end


local cache_rule, err = cache:set(tl_ops_constant_balance.service.rule.cache_key, rule);
if not cache_rule then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", err)
    return;
end

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", "")