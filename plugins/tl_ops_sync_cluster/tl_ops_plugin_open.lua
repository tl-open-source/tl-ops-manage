-- tl_ops_sync_cluster_open
-- en : get export sync_cluster open config
-- zn : 获取插件是否开启
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                     = require("cache.tl_ops_cache_core"):new("tl-ops-sync-cluster");
local constant                  = require("plugins.tl_ops_sync_cluster.tl_ops_plugin_constant");
local constant_sync_cluster     = require("plugins.tl_ops_sync_cluster.tl_ops_plugin_constant")
local cjson                     = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Func = function()

    -- 只要开启同步集群，插件开关，其中一个，就代表开关开启
    if constant_sync_cluster.open then
        return true
    end

    local str, _ = cache:get101(constant.export.cache_key.sync_cluster);
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