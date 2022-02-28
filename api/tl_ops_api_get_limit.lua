-- tl_ops_api 
-- en : get limit fuse options
-- zn : 获取熔断限流检查配置信息
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local cache = require("cache.tl_ops_cache"):new("tl-ops-limit");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local list_str, _ = cache:get(tl_ops_constant_limit.fuse.cache_key.options_list);
if not list_str or list_str == nil then
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
    return;
end


local res_data = {}
res_data[tl_ops_constant_limit.fuse.cache_key.options_list] = cjson.decode(list_str)


tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
