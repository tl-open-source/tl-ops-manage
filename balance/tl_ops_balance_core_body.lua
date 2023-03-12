-- tl_ops_balance_core_body
-- en : balance core body impl
-- zn : 根据请求参数匹配路由的具体实现
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson                         = require("cjson.safe");
local cache_body                    = require("cache.tl_ops_cache_core"):new("tl-ops-balance-body");
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_body  = require("constant.tl_ops_constant_balance_body");
local tl_ops_match_mode             = require("constant.tl_ops_constant_comm").tl_ops_match_mode;
local tl_ops_constant_health        = require("constant.tl_ops_constant_health")
local balance_count_body            = require("balance.count.tl_ops_balance_count_body")
local shared                        = ngx.shared.tlopsbalance
local find                          = ngx.re.find


-- 处理匹配逻辑
local tl_ops_balance_body_matcher_mode = function (matcher, body, obj)
    local match_mode = obj.match_mode
    if not match_mode then
        match_mode = tl_ops_match_mode.reg
    end
    -- 正则匹配模式
    if match_mode == tl_ops_match_mode.reg or match_mode == tl_ops_match_mode.regi or match_mode == tl_ops_match_mode.regid then
        local from, to , _ = find(body , obj.body , match_mode);
        if from and to then
            local sub = string.sub(body, from, to)
            if sub then
                if not matcher or not matcher.body then
                    matcher = obj
                end
                if matcher.body and #sub > #matcher.body then
                    matcher = obj
                end
            end
        end
    end
    -- 全文匹配
    if match_mode == tl_ops_match_mode.all then
        if body == obj.body then
            matcher = obj;
        end
    end

    return matcher
end

-- 获取命中的body路由项
local tl_ops_balance_body_get_matcher_body = function(body_list_table, rule, rule_match_mode)
    local matcher = nil;
    local matcher_list = body_list_table[rule]

    if not matcher_list then
        return nil
    end 

    ngx.req.read_body()

    local body = ngx.req.get_body_data()

    -- 获取当前host
    local cur_host = ngx.var.host;

    for i, obj in pairs(matcher_list) do
        repeat
            if rule_match_mode == tl_ops_constant_balance_body.mode.host then
                -- 如果是优先host规则匹配，先剔除不属于当前host的规则
                if obj.host == nil or obj.host == '' then
                    break
                end
                if obj.host ~= "*" and obj.host ~= cur_host then
                    break
                end
            end

            matcher = tl_ops_balance_body_matcher_mode(matcher, body, obj)
            break
        until true
    end

    return matcher
end


local tl_ops_balance_body_service_matcher = function(service_list_table)
    local matcher = nil
    local node = nil

    -- 规则匹配模式
    local rule_match_mode, _ = cache_body:get(tl_ops_constant_balance_body.cache_key.rule_match_mode);
    if not rule_match_mode then
        -- 默认以host先匹配
        rule_match_mode = tl_ops_constant_balance_body.mode.host;
    end

    -- body路由策略
    local body_rule, _ = cache_body:get(tl_ops_constant_balance_body.cache_key.rule);
    if not body_rule then
        return nil, nil, nil, nil, rule_match_mode
    end
    
    -- body配置列表
    local body_list, _ = cache_body:get(tl_ops_constant_balance_body.cache_key.list);
    if not body_list then
        return nil, nil, nil, nil, rule_match_mode
    end

    local body_list_table = cjson.decode(body_list);
    if not body_list_table then
        return nil, nil, nil, nil, rule_match_mode
    end
    
    -- 根据路由当前策略进行路由, 返回正则命中的body
    if body_rule == tl_ops_constant_balance_body.rule.point then
        matcher = tl_ops_balance_body_get_matcher_body(
            body_list_table, tl_ops_constant_balance_body.rule.point, rule_match_mode
        );
    elseif body_rule == tl_ops_constant_balance_body.rule.random then
        matcher = tl_ops_balance_body_get_matcher_body(
            body_list_table, tl_ops_constant_balance_body.rule.random, rule_match_mode
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
    if body_rule == tl_ops_constant_balance_body.rule.point then
        if node_id ~= nil then
            node = service_list[tonumber(node_id) + 1]            
        else
            return nil, nil, nil, host, rule_match_mode
        end
    -- 服务内随机
    elseif body_rule == tl_ops_constant_balance_body.rule.random then
        local request_uri = tl_ops_utils_func:get_req_uri();
        math.randomseed(#request_uri)
        node_id = tonumber(math.random(0,1) % #service_list_table[matcher.service]) + 1
        node = service_list[node_id]
    end

    -- 命中统计
    balance_count_body.tl_ops_balance_count_incr_body_succ(matcher.service,node_id, matcher.id);

    -- 获取当前节点健康状态
    local key = tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, matcher.service, node_id)
    local node_state , _ = shared:get(key)
    
    return node, node_state, node_id, host, rule_match_mode
end


return {
    tl_ops_balance_body_service_matcher = tl_ops_balance_body_service_matcher
}