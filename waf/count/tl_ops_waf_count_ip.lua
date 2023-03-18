-- tl_ops_waf_count_ip
-- en : waf count ip impl
-- zn : waf-ip级别统计实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                             = require("cjson.safe")
local tlog                              = require("utils.tl_ops_utils_log"):new("tl_ops_waf_count")
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func")
local tl_ops_constant_waf_count         = require("constant.tl_ops_constant_waf_count")
local tl_ops_constant_waf_ip            = require("constant.tl_ops_constant_waf_ip")
local cache_waf_ip                      = require("cache.tl_ops_cache_core"):new("tl-ops-waf-ip")
local cache_waf_count                   = require("cache.tl_ops_cache_core"):new("tl-ops-waf-count")
local shared                            = ngx.shared.tlopswaf


local tl_ops_waf_count_ip_core = function( service_name, node_id, id )

    local cur_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.ip_req_succ, service_name, node_id, id)
    local cur_count = shared:get(cur_count_key)
    if not cur_count then
        cur_count = 0
    end

    if cur_count == 0 then
        tlog:dbg("waf ip count dont need async , cur_count=",cur_count,",service_name=",service_name,",node_id=",node_id,",cur_count_key=",cur_count_key)
    else
        local list_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.ip_counting_list, service_name, node_id)
        local list = cache_waf_count:get001(list_key)
        if not list then
            list = {}
        else
            list = cjson.decode(list)
        end

        list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
        
        local ok, _ = cache_waf_count:set001(list_key, cjson.encode(list))
        if not ok then
            tlog:err("waf ip success count async err ,list_key=",list_key,",cur_count=",cur_count,",err=",_)
        end

        -- rest cur_count
        ok, _ = shared:set(cur_count_key, 0)
        if not ok then
            tlog:err("waf ip succ count reset err ,cur_count_key=",cur_count_key,",cur_count=",cur_count)
        end

        tlog:dbg("waf ip count async ok ,list_key=",list_key,",list=",list)
    end
end

local tl_ops_waf_count_ip = function(  )

    -- 统计全局拦截
    tl_ops_waf_count_ip_core();

    -- 统计规则下拦截
    local waf_list_str, _ = cache_waf_ip:get(tl_ops_constant_waf_ip.cache_key.list);
    if not waf_list_str or waf_list_str == nil then
        tlog:err("waf ip count list nil, break")
        return;
    end

    local waf_list = cjson.decode(waf_list_str);
    if not waf_list or waf_list == nil then
        tlog:err("waf ip count list decode nil, break")
        return;
    end

    for _, ip in ipairs(waf_list) do
        repeat
            local id = ip.id;
            local service_name = ip.service;
            -- 由于暂时只支持到服务级别的waf，node_id给默认值0即可
            local node_id = 0;

            if not id then
                tlog:err("waf ip count ip id nil, ip=",ip);
                break
            end
            if not service_name then
                tlog:err("waf ip count ip service_name nil, ip=", ip);
                break
            end
            if node_id== nil or node_id == '' then
                tlog:err("waf ip count ip node_id nil, ip=", ip);
                break
            end

            tl_ops_waf_count_ip_core(service_name, node_id, id)
            break
        until true
    end
end


-- ip拦截成功次数增加
local tl_ops_waf_count_incr_ip_succ = function( service_name, node_id, api_rule_id )
    local succ_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.ip_req_succ, service_name, node_id, api_rule_id)
    local success_count = shared:get(succ_key)
    if not success_count then
        shared:set(succ_key, 0);
    end
    shared:incr(succ_key, 1)
end


return {
    tl_ops_waf_count_ip = tl_ops_waf_count_ip,
    tl_ops_waf_count_incr_ip_succ = tl_ops_waf_count_incr_ip_succ
}