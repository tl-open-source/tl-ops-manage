-- tl_ops_api 
-- en : set balance api config list
-- zn : 更新负载api配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local tl_ops_api_list_url, err = tl_ops_utils_func:get_req_post_args_by_name("tl_ops_api_list_url", 1);
if not tl_ops_api_list_url or tl_ops_api_list_url == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err1", err);
    return;
end

local tl_ops_api_list_resource,err = tl_ops_utils_func:get_req_post_args_by_name("tl_ops_api_list_resource", 1);
if not tl_ops_api_list_resource or tl_ops_api_list_resource == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err2", err);
    return;
end

local tl_ops_api_list_random, err = tl_ops_utils_func:get_req_post_args_by_name("tl_ops_api_list_random", 1);
if not tl_ops_api_list_random or tl_ops_api_list_random == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err3", err);
    return;
end

local tl_ops_api_rule,err = tl_ops_utils_func:get_req_post_args_by_name("tl_ops_api_rule", 1);
if not tl_ops_api_rule or tl_ops_api_rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err4", err);
    return;
end

local request_data = {
    tl_ops_api_list_url = tl_ops_api_list_url,
    tl_ops_api_list_resource = tl_ops_api_list_resource,
    tl_ops_api_list_random = tl_ops_api_list_random
}

local cache_list, err = cache:set(tl_ops_constant_balance.api.list.cache_key, cjson.encode(request_data));
if not cache_list then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", err)
    return;
end


local cache_rule, err = cache:set(tl_ops_constant_balance.api.rule.cache_key, tl_ops_api_rule);
    if not cache_rule then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", err)
        return;
    end
end

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", "")