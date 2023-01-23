-- tl_ops_sync_open
-- en : get export sync open config
-- zn : 获取插件是否开启
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                 = require("cache.tl_ops_cache_core"):new("tl-ops-sync");
local constant              = require("plugins.tl_ops_sync.tl_ops_plugin_constant");
local sync_constant         = require("plugins.tl_ops_sync.tl_ops_plugin_constant")
local cjson                 = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Func = function()

    -- 只要开启同步字段，同步静态数据，插件开关，其中一个，就代表开关开启
    local sync_fields_env = sync_constant.fields
    if sync_fields_env.open then
        return true
    end

    local sync_data_env = sync_constant.data
    if sync_data_env.open then
        return true
    end

    local str, _ = cache:get101(constant.export.cache_key.sync);
    if not str or str == nil then
        return false;
    end

    local data = cjson.decode(str);
    if not data then
        return false
    end
    
    return data.open
end

return Func