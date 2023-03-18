-- tl_ops_waf_count_service
-- en : waf count service impl
-- zn : waf-service级别统计实现, 主要目的是方便查询多规则下的详情信息汇总
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                             = require("cjson.safe")
local tlog                              = require("utils.tl_ops_utils_log"):new("tl_ops_waf_count")
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func")
local tl_ops_constant_waf_count         = require("constant.tl_ops_constant_waf_count")
local tl_ops_constant_service           = require("constant.tl_ops_constant_service")
local cache_service                     = require("cache.tl_ops_cache_core"):new("tl-ops-service")
local cache_waf_count                   = require("cache.tl_ops_cache_core"):new("tl-ops-waf-count")
local shared                            = ngx.shared.tlopswaf


local tl_ops_waf_count_service_core = function( service_name, mode)

    local cur_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_req_succ, service_name, mode)
    local cur_count = shared:get(cur_count_key)
    if not cur_count then
        cur_count = 0
    end

    if cur_count == 0 then
        tlog:dbg("waf service count dont need async , cur_count=",cur_count,",service_name=",service_name,",cur_count_key=",cur_count_key)
    else
        local list_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, mode)
        local list = cache_waf_count:get001(list_key)
        if not list then
            list = {}
        else
            list = cjson.decode(list)
        end

        list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count

        local ok, _ = cache_waf_count:set001(list_key, cjson.encode(list))
        if not ok then
            tlog:err("waf service success count async err ,list_key=",list_key,",cur_count=",cur_count,",err=",_)
        end

        -- rest cur_count
        ok, _ = shared:set(cur_count_key, 0)
        if not ok then
            tlog:err("waf service succ count reset err ,cur_count_key=",cur_count_key,",cur_count=",cur_count)
        end

        tlog:dbg("waf service count async ok ,list_key=",list_key,",list=",list)
    end
end


local tl_ops_waf_count_service = function(  )

    -- 统计服务下拦截
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str or service_list_str == nil then
        tlog:err("waf service count list nil, break")
        return;
    end

    local service_list = cjson.decode(service_list_str);
    if not service_list or service_list == nil then
        tlog:err("waf service count list decode nil, break")
        return;
    end

    for service_name, _ in pairs(service_list) do
        repeat
            if not service_name then
                tlog:err("waf service count service service_name nil, service=", service_name);
                break
            end

            tl_ops_waf_count_service_core(service_name, "ip");
            tl_ops_waf_count_service_core(service_name, "cc");
            tl_ops_waf_count_service_core(service_name, "api");
            tl_ops_waf_count_service_core(service_name, "header");
            tl_ops_waf_count_service_core(service_name, "cookie");
            tl_ops_waf_count_service_core(service_name, "param");
            break
        until true
    end
end


-- service拦截成功次数增加
local tl_ops_waf_count_incr_service_succ = function( service_name, mode)
    local succ_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_req_succ, service_name, mode)
        local success_count = shared:get(succ_key)
    if not success_count then
        shared:set(succ_key, 0);
    end
    shared:incr(succ_key, 1)
end


return {
    tl_ops_waf_count_service = tl_ops_waf_count_service,
    tl_ops_waf_count_incr_service_succ = tl_ops_waf_count_incr_service_succ
}