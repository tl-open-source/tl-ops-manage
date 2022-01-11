-- tl_ops_api 
-- en : set balance api config list
-- zn : 更新负载api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-api");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local tl_ops_api_rule, err = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.api.rule.cache_key, 1);
if not tl_ops_api_rule or tl_ops_api_rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err1", err);
    return;
end

local tl_ops_api_list, err = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance.api.list.cache_key, 1);
if not tl_ops_api_list or tl_ops_api_list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err2", err);
    return;
end

---- 获取当前策略
local tl_ops_api_list_single, err = tl_ops_api_list[tl_ops_api_rule];
if not tl_ops_api_list_single or tl_ops_api_list_single == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err3", err);
    return;
end
---- 更新生成id
for _, api in ipairs(tl_ops_api_list_single) do
    api.id = snowflake.generate_id( 100 )
    api.updatetime = ngx.localtime()
end
---- 放回
tl_ops_api_list[tl_ops_api_rule] = tl_ops_api_list_single;


local cache_list, err = cache:set(tl_ops_constant_balance.api.list.cache_key, cjson.encode(tl_ops_api_list));
if not cache_list then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", err)
    return;
end


local cache_rule, err = cache:set(tl_ops_constant_balance.api.rule.cache_key, tl_ops_api_rule);
if not cache_rule then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", err)
    return;
end

local res_data = {}
res_data[tl_ops_constant_balance.api.rule.cache_key] = tl_ops_api_rule
res_data[tl_ops_constant_balance.api.list.cache_key] = tl_ops_api_list


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", res_data)