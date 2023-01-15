-- tl_ops_health_check_debug_open
-- en : get export health_check_debug open config
-- zn : 获取插件是否开启
-- @author iamtsm
-- @email 1905333456@qq.com

local cache         = require("cache.tl_ops_cache_core"):new("tl-ops-health-check-debug");
local constant      = require("plugins.tl_ops_health_check_debug.tl_ops_plugin_constant");
local cjson         = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Func = function()
    
    local str, _ = cache:get(constant.export.cache_key.health_check_debug);
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