-- tl_ops_api 
-- en : get balance service node config list
-- zn : 获取负载服务节点配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local cache = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local rule, _ = cache:get(tl_ops_constant_balance.service.rule.cache_key);
if not rule or rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found ,"not found rule", _);
    return;
end

local list, _ = cache:get(tl_ops_constant_balance.service.list.cache_key);
if not list or list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found ,"not found list", _);
    return;
end

local res_data = {}
res_data[tl_ops_constant_balance.service.rule.cache_key] = rule
res_data[tl_ops_constant_balance.service.list.cache_key] = cjson.decode(list)


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);