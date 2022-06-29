-- tl_ops_sync
-- en : sync data , load data to memory
-- zn : 同步数据接口，预热数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_sync_store_fields = require("sync.tl_ops_sync_store_fields"):new();
local tl_ops_sync_constant_data = require("sync.tl_ops_sync_constant_data"):new();
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_sync");


local _M = {}


function _M:init( )

    -- 数据文件。字段同步
    local sync_data = {}
    sync_data["service"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('service');
    sync_data["health"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('health');
    sync_data["limit"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('limit');
    sync_data["token"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('token');
    sync_data["leak"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('leak');
    sync_data["balance"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('balance');
    sync_data["balance_api"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('balance_api');
    sync_data["balance_cookie"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('balance_cookie');
    sync_data["balance_header"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('balance_header');
    sync_data["balance_param"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('balance_param');
    sync_data["waf"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf');
    sync_data["waf_ip"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf_ip');
    sync_data["waf_api"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf_api');
    sync_data["waf_cc"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf_cc');
    sync_data["waf_header"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf_header');
    sync_data["waf_cookie"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf_cookie');
    sync_data["waf_param"] = tl_ops_sync_store_fields:tl_ops_sync_store_fields_module('waf_param');

    tlog:dbg("tl_ops_sync tl_ops_sync_store_fields done , res=",sync_data)
    

    -- 数据合并，预热
    -- local warm_data = {}
    -- warm_data["balance_api"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('balance_api');
    -- warm_data["balance_cookie"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('balance_cookie');
    -- warm_data["balance_header"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('balance_header');
    -- warm_data["balance_param"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('balance_param');
    -- warm_data["waf_ip"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('waf_ip');
    -- warm_data["waf_api"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('waf_api');
    -- warm_data["waf_cc"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('waf_cc');
    -- warm_data["waf_header"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('waf_header');
    -- warm_data["waf_cookie"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('waf_cookie');
    -- warm_data["waf_param"] = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module('waf_param');

    -- tlog:dbg("tl_ops_sync tl_ops_sync_constant_data done , res=",warm_data)
end

return _M
