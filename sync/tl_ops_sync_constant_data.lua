-- tl_ops_sync_constant_data
-- en : sync constant data to shared dict
-- zn : 同步在文件中的静态配置到共享内存中，和store的数据进行合并
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

-- balance
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_balance_api = require("constant.tl_ops_constant_balance_api");
local tl_ops_constant_balance_param = require("constant.tl_ops_constant_balance_param");
local tl_ops_constant_balance_header = require("constant.tl_ops_constant_balance_header");
local tl_ops_constant_balance_cookie = require("constant.tl_ops_constant_balance_cookie");
local cache_balance_api = require("cache.tl_ops_cache"):new("tl-ops-balance-api");
local cache_balance_param = require("cache.tl_ops_cache"):new("tl-ops-balance-param");
local cache_balance_header = require("cache.tl_ops_cache"):new("tl-ops-balance-header");
local cache_balance_cookie = require("cache.tl_ops_cache"):new("tl-ops-balance-cookie");


-- waf
local tl_ops_constant_waf = require("constant.tl_ops_constant_waf");
local tl_ops_constant_waf_ip = require("constant.tl_ops_constant_waf_ip");
local tl_ops_constant_waf_api = require("constant.tl_ops_constant_waf_api");
local tl_ops_constant_waf_cc = require("constant.tl_ops_constant_waf_cc");
local tl_ops_constant_waf_header = require("constant.tl_ops_constant_waf_header");
local tl_ops_constant_waf_cookie = require("constant.tl_ops_constant_waf_cookie");
local tl_ops_constant_waf_param = require("constant.tl_ops_constant_waf_param");
local cache_waf_api = require("cache.tl_ops_cache"):new("tl-ops-waf-api");
local cache_waf_ip = require("cache.tl_ops_cache"):new("tl-ops-waf-ip");
local cache_waf_cookie = require("cache.tl_ops_cache"):new("tl-ops-waf-cookie");
local cache_waf_header = require("cache.tl_ops_cache"):new("tl-ops-waf-header");
local cache_waf_cc = require("cache.tl_ops_cache"):new("tl-ops-waf-cc");
local cache_waf_param = require("cache.tl_ops_cache"):new("tl-ops-waf-param");


-- utils
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_sync_constant_data");


local _M = {
    _VERSION = '0.01'
}
local mt = { __index = _M }


function _M:new( )
	return setmetatable({}, mt)
end



--+++++++++++++++路由策略数据同步合并，预热+++++++++++++++--


-- 路由策略静态配置数据
local tl_ops_sync_constant_data_balance = function ()


    return tl_ops_rt.ok
end



--+++++++++++++++WAF策略数据同步合并，预热+++++++++++++++--






function _M:tl_ops_sync_constant_data_module( module )

    if module == 'balance_api' then
        return tl_ops_sync_constant_data_balance_api()
    end

    if module == 'balance_cookie' then
        return tl_ops_sync_constant_data_balance_cookie()
    end

    if module == 'balance_header' then
        return tl_ops_sync_constant_data_balance_header()
    end

    if module == 'balance_param' then
        return tl_ops_sync_constant_data_balance_param()
    end

    if module == 'waf_api' then
        return tl_ops_sync_constant_data_waf_api()
    end

    if module == 'waf_ip' then
        return tl_ops_sync_constant_data_waf_ip()
    end
    
    if module == 'waf_header' then
        return tl_ops_sync_constant_data_waf_header()
    end

    if module == 'waf_cookie' then
        return tl_ops_sync_constant_data_waf_cookie()
    end

    if module == 'waf_param' then
        return tl_ops_sync_constant_data_waf_param()
    end

    if module == 'waf_cc' then
        return tl_ops_sync_constant_data_waf_cc()
    end
end


return _M