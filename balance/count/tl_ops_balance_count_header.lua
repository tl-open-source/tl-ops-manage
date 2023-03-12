
-- tl_ops_balance_count_header
-- en : balance count state with header
-- zn : header路由次数统计器
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                             = require("cjson.safe")
local cache_balance_header              = require("cache.tl_ops_cache_core"):new("tl-ops-balance-header")
local cache_balance_count               = require("cache.tl_ops_cache_core"):new("tl-ops-balance-count");
local tlog                              = require("utils.tl_ops_utils_log"):new("tl_ops_balance_count")
local tl_ops_constant_balance_header    = require("constant.tl_ops_constant_balance_header")
local tl_ops_constant_balance_count     = require("constant.tl_ops_constant_balance_count")
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func")
local shared                            = ngx.shared.tlopsbalance

-- 以header为粒度统计
local tl_ops_balance_count_header = function( )

    local rule, _ = cache_balance_header:get(tl_ops_constant_balance_header.cache_key.rule);
    if not rule or rule == nil then
        tlog:err("balance header count rule nil, break")
        return;
    end
    
    local list_str, _ = cache_balance_header:get(tl_ops_constant_balance_header.cache_key.list);
    if not list_str or list_str == nil then
        tlog:err("balance header count list nil, break")
        return;
    end

    local list = cjson.decode(list_str);
    if not list or list == nil then
        tlog:err("balance header count list decode nil, break")
        return;
    end

    local header_rule_list = list[rule];
    if not header_rule_list or header_rule_list == nil then
        tlog:err("balance header count header_rule_list nil, break")
        return;
    end

    for _, header in ipairs(header_rule_list) do
        repeat
            local id = header.id;
            local service_name = header.service;
            local node_id = header.node;

            if not id then
                tlog:err("balance header count header id nil, header=",header);
                break
            end
            if not service_name then
                tlog:err("balance header count header service_name nil, header=", header);
                break
            end
            if rule == tl_ops_constant_balance_header.rule.point then
                if node_id == nil or node_id == '' then
                    tlog:err("balance header count header node_id nil, header=", header);
                    break
                end
            end

            local cur_count_key = tl_ops_utils_func:gen_node_key( tl_ops_constant_balance_count.cache_key.header_req_succ, service_name, node_id, id)
            local cur_succ_count = shared:get(cur_count_key)
            if not cur_succ_count then
                cur_succ_count = 0
            end

            if cur_succ_count == 0 then
                tlog:dbg("balance header count not need sync , succ=",cur_succ_count,",rule=",rule,",id=",id);
            else
                -- push to list
                local counting_list_key = tl_ops_utils_func:gen_node_key( tl_ops_constant_balance_count.cache_key.header_counting_list, service_name, node_id, id )
                local counting_list = cache_balance_count:get001(counting_list_key)
                if not counting_list then
                    counting_list = {}
                else
                    counting_list = cjson.decode(counting_list)
                end

                counting_list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_succ_count

                local ok, _ = cache_balance_count:set001(counting_list_key, cjson.encode(counting_list))
                if not ok then
                    tlog:err("balance header success count async err ,counting_list_key=",counting_list_key,",cur_succ_count=",cur_succ_count,",err=",_)
                end

                -- rest cur_succ_count
                ok, _ = shared:set(cur_count_key, 0)
                if not ok then
                    tlog:err("balance header success count reset err ,cur_count_key=",cur_count_key,",cur_succ_count=",cur_succ_count,",err=",_)
                end

                tlog:dbg("balance header count async ok ,counting_list_key=",counting_list_key,",counting_list=",counting_list)
            end

            break
        until true
    end
end


-- header路由成功次数增加
local tl_ops_balance_count_incr_header_succ = function ( service_name, node_id, api_rule_id )
    local succ_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance_count.cache_key.header_req_succ, service_name, node_id, api_rule_id)
    local success_count = shared:get(succ_key)
    if not success_count then
        shared:set(succ_key, 0);
    end
    shared:incr(succ_key, 1)
end


return {
    tl_ops_balance_count_header = tl_ops_balance_count_header,
    tl_ops_balance_count_incr_header_succ = tl_ops_balance_count_incr_header_succ
}