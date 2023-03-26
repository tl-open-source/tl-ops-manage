-- tl_ops_set_sync_cluster_export
-- en : set export sync_cluster config
-- zn : 更新sync_cluster插件配置管理
-- @author iamtsm
-- @email 1905333456@qq.com`

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-sync-cluster");
local constant                  = require("plugins.tl_ops_sync_cluster.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local sync_cluster, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.export.cache_key.sync_cluster, 1);
    if sync_cluster then
        local res, _ = cache:set(constant.export.cache_key.sync_cluster, cjson.encode(sync_cluster));
        if not res then
            return tl_ops_rt.error, "set sync_cluster err ", _
        end
    end

    local res_data = {}
    res_data[constant.export.cache_key.sync_cluster] = sync_cluster

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}