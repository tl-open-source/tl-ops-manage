-- tl_ops_set_grpc_export
-- en : set export grpc config
-- zn : 更新grpc插件配置管理
-- @author iamtsm
-- @email 1905333456@qq.com`

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-grpc");
local constant                  = require("plugins.tl_ops_grpc.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 

    local grpc, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.export.cache_key.grpc, 1);
    if grpc then
        local res, _ = cache:set(constant.export.cache_key.grpc, cjson.encode(grpc));
        if not res then
            tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set grpc err ", _)
            return;
        end
    end
    
    local res_data = {}
    res_data[constant.export.cache_key.grpc] = grpc

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data)
 end
 
return Router
