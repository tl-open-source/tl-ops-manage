-- tl_ops_balance_count_node
-- en : balance count state with node
-- zn : 节点路由次数统计器
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                         = require("cjson.safe")
local tlog                          = require("utils.tl_ops_utils_log"):new("tl_ops_balance_count")
local cache_service                 = require("cache.tl_ops_cache_core"):new("tl-ops-service")
local tl_ops_utils_func             = require("utils.tl_ops_utils_func")
local cache_balance_count           = require("cache.tl_ops_cache_core"):new("tl-ops-balance-count", true);
local tl_ops_constant_balance_count = require("constant.tl_ops_constant_balance_count")
local tl_ops_constant_service       = require("constant.tl_ops_constant_service")
local shared                        = ngx.shared.tlopsbalance

-- 以节点为粒度统计
local tl_ops_balance_count_node = function ( )

    local service_list = nil
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str then
        -- use default
        service_list = tl_ops_constant_service.list
    else
        service_list = cjson.decode(service_list_str);
    end

    for service_name, nodes in pairs(service_list) do
        repeat
            if nodes == nil then
                tlog:err("balance node count nodes nil, break service_name=",service_name)
                break
            end
        
            for i = 1, #nodes do
                local node_id = i-1
                local cur_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance_count.cache_key.node_req_succ, service_name, node_id)
                local cur_succ_count = shared:get(cur_succ_count_key)
                if not cur_succ_count then
                    cur_succ_count = 0
                end
    
                local cur_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance_count.cache_key.node_req_fail, service_name, node_id)
                local cur_fail_count = shared:get(cur_fail_count_key)
                if not cur_fail_count then
                    cur_fail_count = 0
                end
    
                local cur_count = cur_succ_count + cur_fail_count
                if cur_count == 0 then
                    tlog:dbg("balance node count not need sync , succ=",cur_succ_count,",fail=",cur_fail_count,",service_name=",service_name,",node_id=",node_id)
                else
                    -- push to list
                    local list_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance_count.cache_key.node_counting_list, service_name, node_id)
                    local list = cache_balance_count:get001(list_key)
                    if not list then
                        list = {}
                    else
                        list = cjson.decode(list)
                    end
    
                    list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
                    
                    local ok, _ = cache_balance_count:set001(list_key, cjson.encode(list))
                    if not ok then
                        tlog:err("balance node success count async err ,list_key=",list_key,",cur_count=",cur_count,",err=",_)
                    end
    
                    -- rest cur_count
                    ok, _ = shared:set(cur_succ_count_key, 0)
                    if not ok then
                        tlog:err("balance node succ count reset err ,cur_succ_count_key=",cur_succ_count_key,",cur_succ_count=",cur_succ_count)
                    end
                    ok, _ = shared:set(cur_fail_count_key, 0)
                    if not ok then
                        tlog:err("balance node fail count reset err ,cur_fail_count_key=",cur_fail_count_key,",cur_fail_count=",cur_fail_count)
                    end
    
                    tlog:dbg("balance node count async ok ,list_key=",list_key,",list=",list)
                end
            end

            break
        until true
    end
end


-- node路由失败次数增加
 local tl_ops_balance_count_incr_node_fail = function( service_name, node_id )
    local faild_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance_count.cache_key.node_req_fail, service_name, node_id)
    local failed_count = shared:get(faild_key)
    if not failed_count then
        shared:set(faild_key, 0);
    end
    shared:incr(faild_key, 1)
end


-- node路由成功次数增加
local tl_ops_balance_count_incr_node_succ = function( service_name, node_id )
    local succ_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance_count.cache_key.node_req_succ,service_name, node_id)
    local success_count = shared:get(succ_key)
    if not success_count then
        shared:set(succ_key, 0);
    end
    shared:incr(succ_key, 1)
end


return {
    tl_ops_balance_count_node = tl_ops_balance_count_node,
    tl_ops_balance_count_incr_node_fail = tl_ops_balance_count_incr_node_fail,
    tl_ops_balance_count_incr_node_succ = tl_ops_balance_count_incr_node_succ
}