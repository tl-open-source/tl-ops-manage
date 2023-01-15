-- tl_ops_template_get_export
-- en : get export template config
-- zn : 获取template插件配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-template");
local constant                  = require("plugins.tl_ops_template.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function()
    
    local str, _ = cache:get(constant.export.cache_key.template);
    if not str or str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found template", _);
        return;
    end

    local res_data = {}
    res_data[constant.export.cache_key.template] = cjson.decode(str)
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router