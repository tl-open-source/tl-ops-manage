-- tl_ops_balance_core_param
-- en : balance core param impl
-- zn : 根据请求参数匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                         = require("cjson.safe");
local cache_param                   = require("cache.tl_ops_cache_core"):new("tl-ops-balance-param");
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_param = require("constant.tl_ops_constant_balance_param");
local tl_ops_constant_health        = require("constant.tl_ops_constant_health")
local balance_count_param           = require("balance.count.tl_ops_balance_count_param")
local shared                        = ngx.shared.tlopsbalance


-- 获取命中的param路由项
local tl_ops_balance_param_get_matcher_param = function(param_list_table, rule, rule_match_mode)
    local matcher_list = param_list_table[rule]

    if not matcher_list then
        return nil
    end 

    local args = ngx.req.get_uri_args()

    -- 获取当前host
    local cur_host = ngx.var.host;

    for index, obj in pairs(matcher_list) do
        repeat
            if rule_match_mode == tl_ops_constant_balance_param.mode.host then
                -- 如果是优先host规则匹配，先剔除不属于当前host的规则
                if obj.host == nil or obj.host == '' then
                    break
                end
                if obj.host ~= "*" and obj.host ~= cur_host then
                    break
                end
            end
            if not obj or not obj.key then
                break
            end
            
            if not args then
                break
            end
            
            for arg_k ,arg_v in pairs(args) do
                if arg_k and arg_k == obj.key then
                    for _, value in pairs(obj.value) do
                        if arg_v == value then
                            return obj
                        end
                    end
                end
            end

            break
        until true
    end

    return nil
end


local tl_ops_balance_param_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- 规则匹配模式
    local rule_match_mode, _ = cache_param:get(tl_ops_constant_balance_param.cache_key.rule_match_mode);
    if not rule_match_mode then
        -- 默认以host优先匹配
        rule_match_mode = tl_ops_constant_balance_param.mode.host;
    end

    -- param路由策略
    local param_rule, _ = cache_param:get(tl_ops_constant_balance_param.cache_key.rule);
    if not param_rule then
        return nil, nil, nil, nil, rule_match_mode
    end
    
    -- param配置列表
    local param_list, _ = cache_param:get(tl_ops_constant_balance_param.cache_key.list);
    if not param_list then
        return nil, nil, nil, nil, rule_match_mode
    end

    local param_list_table = cjson.decode(param_list);
    if not param_list_table then
        return nil, nil, nil, nil, rule_match_mode
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的param
    if param_rule == tl_ops_constant_balance_param.rule.point then
        matcher = tl_ops_balance_param_get_matcher_param(
            param_list_table, tl_ops_constant_balance_param.rule.point, rule_match_mode
        );
    elseif param_rule == tl_ops_constant_balance_param.rule.random then
        matcher = tl_ops_balance_param_get_matcher_param(
            param_list_table, tl_ops_constant_balance_param.rule.random, rule_match_mode
        );
    end

    if not matcher or type(matcher) ~= 'table' then
        return nil, nil, nil, nil, rule_match_mode
    end

    local service_list = service_list_table[matcher.service]
    local node_id = matcher.node  -- lua index start 1

    local host = matcher.host
    if not host or host == nil then
        host = ""
    end

    -- 指定节点
    if param_rule == tl_ops_constant_balance_param.rule.point then
        if node_id ~= nil then
            node = service_list[tonumber(node_id) + 1]            
        else
            return nil, nil, nil, host, rule_match_mode
        end
    -- 服务内随机
    elseif param_rule == tl_ops_constant_balance_param.rule.random then
        local request_uri = tl_ops_utils_func:get_req_uri();
        math.randomseed(#request_uri)
        node_id = tonumber(math.random(0,1) % #service_list_table[matcher.service]) + 1
        node = service_list[node_id]
    end

    -- 命中统计
    balance_count_param.tl_ops_balance_count_incr_param_succ(matcher.service,node_id, matcher.id);
    
    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, matcher.service, node_id)
    local node_state , _ = shared:get(key)
    
    return node, node_state, node_id, host, rule_match_mode
end


return {
    tl_ops_balance_param_service_matcher = tl_ops_balance_param_service_matcher
}