-- tl_ops_plugins_manage
-- en : set plugins config
-- zn : 更新插件配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-plugins-manage");
local snowflake                         = require("lib.snowflake");
local tl_ops_constant_plugins_manage    = require("constant.tl_ops_constant_plugins_manage");
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local plugin_load                       = require("plugins.tl_ops_plugin_load"):new();
local cjson                             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function(ctx)

    local change = "success"

    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_plugins_manage.cache_key.list, 1);
    if not list or list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"pm args err1", _);
        return;
    end

    local del_plugin_id = nil

    -- 更新生成id
    for index, plugin in ipairs(list) do
        if not plugin.id or plugin.id == nil or plugin.id == '' then
            plugin.id = snowflake.generate_id( 100 )
        end

        -- 新增插件
        if plugin.add and plugin.add == true then

            local new_plugin_data = plugin_load:tl_ops_plugin_load_by_name(plugin.name);
            if not new_plugin_data then
                tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "plugin load err ",new_plugin_data)
                return
            end

            -- 插件配置不存在
            if not new_plugin_data.constant then
                tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "plugin constant err ",status)
                return
            end

            -- 插件代码不存在
            if not new_plugin_data.func then
                tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "plugin core func err ",status)
                return
            end

            -- 插件开关不存在
            if not new_plugin_data.open_func then
                tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "plugin open func err ",status)
                return
            end

            -- 插件api不存在
            if not new_plugin_data.api_func then
                tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "plugin api func err ",status)
                return
            end

            table.insert( ctx.tlops_plugins, new_plugin_data);

            plugin.add = nil
        end

        -- 卸载插件
        if plugin.del and plugin.del == true then

            local plugins = ctx.tlops_plugins

            local new_plugins = plugin_load:tl_ops_plugin_unload_by_name(plugins, plugin.name);

            ctx.tlops_plugins = new_plugins;

            plugin.del = nil

            del_plugin_id = index
        end
    end

    -- 删除插件
    if del_plugin_id and del_plugin_id > 0 then
        table.remove(list, del_plugin_id)
    end

    local res, _ = cache:set(tl_ops_constant_plugins_manage.cache_key.list, cjson.encode(list));
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
        return;
    end
    
    local res_data = {}
    res_data[tl_ops_constant_plugins_manage.cache_key.list] = list

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, change, res_data)

 end
 

return Router