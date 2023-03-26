-- tl_ops_set_template_export
-- en : set export template config
-- zn : 更新template插件配置管理
-- @author iamtsm
-- @email 1905333456@qq.com`

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-template");
local constant                  = require("plugins.tl_ops_template.tl_ops_plugin_constant");
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt;
local tl_ops_utils_func         = tlops.utils
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local template, _ = tl_ops_utils_func:get_req_post_args_by_name(constant.export.cache_key.template, 1);
    if template then
        local res, _ = cache:set(constant.export.cache_key.template, cjson.encode(template));
        if not res then
            return tl_ops_rt.error, "set template err ", _
        end
    end

    local res_data = {}
    res_data[constant.export.cache_key.template] = template

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}