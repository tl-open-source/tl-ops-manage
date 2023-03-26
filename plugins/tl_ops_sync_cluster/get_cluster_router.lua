-- tl_ops_get_cluster
-- en : get cluster list
-- zn : 获取集群节点列表
-- @author iamtsm
-- @email 1905333456@qq.com

local constant                  = require("plugins.tl_ops_sync_cluster.tl_ops_plugin_constant")
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local res_data = {}

    res_data[constant.cache_key.current] = constant.current
    res_data[constant.cache_key.other] = constant.other

    return tl_ops_rt.ok, "success", res_data
end

local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}