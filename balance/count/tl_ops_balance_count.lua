-- tl_ops_balance
-- en : balance count core api
-- zn : 路由统计对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local tl_ops_balance_count_core = require("balance.count.tl_ops_balance_count_core");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local shared = ngx.shared.tlopsbalance;

local _M = {}


function _M:init( )
    -- 启动路由统计
    local balance_count = tl_ops_balance_count_core:new();
    balance_count:tl_ops_balance_count_timer_start()
end


-- incr balance failed count
function _M:tl_ops_balance_count_incr_fail(service_name, node_id)
    local faild_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_fail, service_name, node_id)
    local failed_count = shared:get(faild_key)
    if not failed_count then
        shared:set(faild_key, 0);
    end
    shared:incr(faild_key, 1)
end


-- incr balance succ count
function _M:tl_ops_balance_count_incr_succ(service_name, node_id)
    local succ_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_succ,service_name, node_id)
    local success_count = shared:get(succ_key)
    if not success_count then
        shared:set(succ_key, 0);
    end
    shared:incr(succ_key, 1)
end


return _M
