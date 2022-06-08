-- tl_ops_header 
-- en : get balance header config list
-- zn : 获取路由header配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-header");
local tl_ops_constant_header = require("constant.tl_ops_constant_header");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local rule, _ = cache:get(tl_ops_constant_header.cache_key.rule);
if not rule or rule == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found rule", _);
    return;
end

local list_str, _ = cache:get(tl_ops_constant_header.cache_key.list);
if not list_str or list_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
    return;
end


local res_data = {}
res_data[tl_ops_constant_header.cache_key.rule] = rule
res_data[tl_ops_constant_header.cache_key.list] = cjson.decode(list_str)

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);