-- tl_ops_balance_core_api
-- en : balance core api impl
-- zn : 根据api匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                         = require("cjson.safe");
local cache_api                     = require("cache.tl_ops_cache_core"):new("tl-ops-balance-api");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_api   = require("constant.tl_ops_constant_balance_api");
local tl_ops_constant_health        = require("constant.tl_ops_constant_health")
local shared                        = ngx.shared.tlopsbalance
local find                          = ngx.re.find

local tl_ops_balance_api_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- 获取当前url
    local request_uri = tl_ops_utils_func:get_req_uri();

    -- api路由策略
    local api_rule, _ = cache_api:get(tl_ops_constant_balance_api.cache_key.rule);
    if not api_rule then
        return nil, nil, nil, nil
    end
    
    -- api配置列表
    local api_list, _ = cache_api:get(tl_ops_constant_balance_api.cache_key.list);
    if not api_list then
        return nil, nil, nil, nil
    end
    
    local api_list_table = cjson.decode(api_list);
    if not api_list_table then
        return nil, nil, nil, nil
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的api
    if api_rule == tl_ops_constant_balance_api.rule.point then
        local point = api_list_table.point

        for i, obj in pairs(point) do
            local from, to , _ = find(request_uri , obj.url , 'joi');
            if from and to then
                local sub = string.sub(request_uri, from, to)
                if sub then
                    if not matcher or not matcher.url then
                        matcher = obj
                    end
                    if matcher.url and #sub > #matcher.url then
                        matcher = obj
                    end
                end
            end
        end
    elseif api_rule == tl_ops_constant_balance_api.rule.random then
        local random = api_list_table.random

        for i, obj in pairs(random) do
            local from, to , _ = find(request_uri , obj.url , 'joi');
            if from and to then
                local sub = string.sub(request_uri, from, to)
                if sub then
                    if not matcher or not matcher.url then
                        matcher = obj
                    end
                    if matcher.url and #sub > #matcher.url then
                        matcher = obj
                    end
                end
            end
        end
    end

    if not matcher or type(matcher) ~= 'table' then
        return nil, nil, nil, nil
    end

    local service_list = service_list_table[matcher.service]
    local node_id = matcher.node  -- lua index start 1

    local host = matcher.host
    if not host or host == nil then
        host = ""
    end

    -- 指定节点
    if api_rule == tl_ops_constant_balance_api.rule.point then
        if node_id ~= nil then
            node = service_list[tonumber(node_id) + 1]            
        else
            return nil, nil, nil, host
        end
    -- 服务内随机
    elseif api_rule == tl_ops_constant_balance_api.rule.random then
        math.randomseed(#request_uri)
        node_id = tonumber(math.random(0,1) % #service_list_table[matcher.service]) + 1
        node = service_list[node_id]
    end

    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, matcher.service, node_id)
    local node_state , _ = shared:get(key)


    -- 需要重写url
    local rewrite_url = matcher.rewrite_url
    if rewrite_url and rewrite_url ~= '' then
        ngx.req.set_uri(rewrite_url, false)
    end
    
    return node, node_state, node_id, host
end


return {
    tl_ops_balance_api_service_matcher = tl_ops_balance_api_service_matcher
}