-- tl_ops_plugins_manage
-- en : get plugins config
-- zn : 获取插件配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-plugins-manage")
local tl_ops_constant_plugins_manage    = require("constant.tl_ops_constant_plugins_manage")
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func")
local cjson                             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function(ctx)
    local list_str, _ = cache:get(tl_ops_constant_plugins_manage.cache_key.list);
    if not list_str or list_str == nil then
        return tl_ops_rt.not_found, "not found list", _
    end

    local list = cjson.decode(list_str)

    for _, plugin in ipairs(list) do
        local name = plugin.name
        local status, constant = pcall(require, "plugins.tl_ops_" .. name .. ".tl_ops_plugin_constant")
        if status then
            if constant and type(constant) == 'table' then
                plugin['get'] = constant.export.tlops_api.get
                plugin['set'] = constant.export.tlops_api.set
            end
        end
    end

    local res_data = {}
    res_data[tl_ops_constant_plugins_manage.cache_key.list] = list

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}

