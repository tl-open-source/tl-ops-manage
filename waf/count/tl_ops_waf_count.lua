-- tl_ops_waf_count
-- en : waf count core api
-- zn : waf统计对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local tl_ops_waf_count_core     = require("waf.count.tl_ops_waf_count_core");
local tl_ops_constant_waf       = require("constant.tl_ops_constant_waf");
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local shared                    = ngx.shared.tlopswaf;

local _M = {}


function _M:init( )
    -- 启动路由统计
    local waf_count = tl_ops_waf_count_core:new();
    waf_count:tl_ops_waf_count_timer_start()
end


-- incr waf count
function _M:tl_ops_waf_count_incr_key(cache_key, service_name, node_id)
    local key = cache_key
    if service_name ~= nil or node_id ~= nil then
        key = tl_ops_utils_func:gen_node_key(cache_key, service_name, node_id)
    end

    local count = shared:get(key)
    if not count then
        shared:set(key, 0);
    end
    shared:incr(key, 1)
end



return _M