-- tl_ops_api
-- en : version fields update 
-- zn : 版本迭代更新字段同步器
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_utils_sync = require("utils.tl_ops_utils_sync"):new();


local Router = function() 
    local res_data = {}

    res_data["service"] = tl_ops_utils_sync:tl_ops_utils_sync_module('service');
    res_data["health"] = tl_ops_utils_sync:tl_ops_utils_sync_module('health');
    res_data["limit"] = tl_ops_utils_sync:tl_ops_utils_sync_module('limit');
    res_data["token"] = tl_ops_utils_sync:tl_ops_utils_sync_module('token');
    res_data["leak"] = tl_ops_utils_sync:tl_ops_utils_sync_module('leak');
    res_data["balance"] = tl_ops_utils_sync:tl_ops_utils_sync_module('balance');
    res_data["balance_api"] = tl_ops_utils_sync:tl_ops_utils_sync_module('balance_api');
    res_data["balance_cookie"] = tl_ops_utils_sync:tl_ops_utils_sync_module('balance_cookie');
    res_data["balance_header"] = tl_ops_utils_sync:tl_ops_utils_sync_module('balance_header');
    res_data["balance_param"] = tl_ops_utils_sync:tl_ops_utils_sync_module('balance_param');
    res_data["waf"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf');
    res_data["waf_ip"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf_ip');
    res_data["waf_api"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf_api');
    res_data["waf_cc"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf_cc');
    res_data["waf_header"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf_header');
    res_data["waf_cookie"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf_cookie');
    res_data["waf_param"] = tl_ops_utils_sync:tl_ops_utils_sync_module('waf_param');
    
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
 end
 
return Router

 