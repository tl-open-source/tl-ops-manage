-- tl_ops_set_page_proxy_export
-- en : set export page_proxy config
-- zn : 更新page_proxy插件配置管理
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-page-proxy");
local constant                  = require("plugins.tl_ops_page_proxy.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local page_proxy, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.export.cache_key.page_proxy, 1);
    if page_proxy then
        local res, _ = cache:set(constant.export.cache_key.page_proxy, cjson.encode(page_proxy));
        if not res then
            return tl_ops_rt.error, "set page_proxy err ", _
        end
    end

    local res_data = {}
    res_data[constant.export.cache_key.page_proxy] = page_proxy

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}