-- tl_ops_api 
-- en : get limit fuse options
-- zn : 获取熔断限流检查配置信息
-- @author iamtsm
-- @email 1905333456@qq.com


local cache                 = require("cache.tl_ops_cache_core"):new("tl-ops-limit");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local tl_ops_rt             = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func     = require("utils.tl_ops_utils_func");
local cjson                 = require("cjson.safe");
cjson.encode_empty_table_as_object(false)

local Router = function() 
    local fuse_list_str, _ = cache:get(tl_ops_constant_limit.fuse.cache_key.options_list);
    if not fuse_list_str or fuse_list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "fuse not found list", _);
        return;
    end

    local token_list_str, _ = cache:get(tl_ops_constant_limit.token.cache_key.options_list);
    if not token_list_str or token_list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "token not found list", _);
        return;
    end

    local leak_list_str, _ = cache:get(tl_ops_constant_limit.leak.cache_key.options_list);
    if not leak_list_str or leak_list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "leak not found list", _);
        return;
    end

    local res_data = {}
    res_data[tl_ops_constant_limit.fuse.cache_key.options_list] = cjson.decode(fuse_list_str)
    res_data[tl_ops_constant_limit.leak.cache_key.options_list] = cjson.decode(leak_list_str)
    res_data[tl_ops_constant_limit.token.cache_key.options_list] = cjson.decode(token_list_str)


    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);

 end
 
return Router
