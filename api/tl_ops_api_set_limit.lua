-- tl_ops_api 
-- en : set limit fuse config
-- zn : 更新熔断限流检查配置信息
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local cache = require("cache.tl_ops_cache"):new("tl-ops-limit");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")


local tl_ops_limit_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_limit.fuse.cache_key.options_list, 1);
if not tl_ops_limit_list or tl_ops_limit_list == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"args err1", _);
    return;
end

local cache_list, _ = cache:set(tl_ops_constant_limit.fuse.cache_key.options_list, cjson.encode(tl_ops_limit_list));
if not cache_list then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
    return;
end

---- 对service version更新，通知worker更新所有conf
for _, option in ipairs(tl_ops_limit_list) do
    tl_ops_limit_fuse_check_version.incr_service_version(option.service_name);
end


local res_data = {}
res_data[tl_ops_constant_limit.fuse.cache_key.options_list] = tl_ops_limit_list

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
