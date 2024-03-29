-- tl_ops_test_open
-- en : get export test open config
-- zn : 获取插件是否开启
-- @author iamtsm
-- @email 1905333456@qq.com

local cache         = require("cache.tl_ops_cache_core"):new("tl-ops-test");
local constant      = require("plugins.tl_ops_test.tl_ops_plugin_constant");
local cjson         = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Func = function()
    
    local str, _ = cache:get101(constant.export.cache_key.test);
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