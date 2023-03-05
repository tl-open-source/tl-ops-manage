-- tl_ops_page_proxy_get
-- en : get page_proxy config list
-- zn : 获取page_proxy配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-page-proxy");
local constant                  = require("plugins.tl_ops_page_proxy.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function()
    
    local list_str, _ = cache:get(constant.cache_key.list);
    if not list_str or list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found list", _);
        return;
    end
    
    
    local res_data = {}
    res_data[constant.cache_key.list] = cjson.decode(list_str)
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router