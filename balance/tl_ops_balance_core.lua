-- tl_ops_balance
-- en : balance core impl
-- zn : 路由的具体实现，根据用户自定义的service , 自动检查服务节点状态，
--      根据自定义的url, 请求参数，请求cookie，请求头，以及选中的路由策略，路由到合适的服务节点。
-- @author iamtsm
-- @email 1905333456@qq.com

local api_match_mode                    = require("constant.tl_ops_constant_balance_api").mode;
local tl_ops_constant_balance           = require("constant.tl_ops_constant_balance");
local tl_ops_constant_limit             = require("constant.tl_ops_constant_limit")
local tl_ops_constant_service           = require("constant.tl_ops_constant_service");
local tl_ops_balance_core_api           = require("balance.tl_ops_balance_core_api");
local tl_ops_balance_core_body          = require("balance.tl_ops_balance_core_body");
local tl_ops_balance_core_cookie        = require("balance.tl_ops_balance_core_cookie");
local tl_ops_balance_core_header        = require("balance.tl_ops_balance_core_header");
local tl_ops_balance_core_param         = require("balance.tl_ops_balance_core_param");
local cache_service                     = require("cache.tl_ops_cache_core"):new("tl-ops-service");
local balance_count                     = require("balance.count.tl_ops_balance_count");
local waf                               = require("waf.tl_ops_waf")
local tl_ops_limit_fuse_token_bucket    = require("limit.fuse.tl_ops_limit_fuse_token_bucket");
local tl_ops_limit_fuse_leak_bucket     = require("limit.fuse.tl_ops_limit_fuse_leak_bucket");
local tl_ops_limit                      = require("limit.tl_ops_limit");
local cjson                             = require("cjson.safe");
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local tl_ops_manage_env                 = require("tl_ops_manage_env")
local ngx_balancer                      = require ("ngx.balancer")
local tl_ops_err_content                = require("err.tl_ops_err_content")
local shared                            = ngx.shared.tlopsbalance


local _M = {
	_VERSION = '0.02'
}
local mt = { __index = _M }


-- 负载节点过滤筛选
function _M:tl_ops_balance_core_filter(ctx)
    -- 服务节点配置列表
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str then
        tl_ops_err_content:err_content_rewrite_to_balance("", "empty", "", tl_ops_constant_balance.cache_key.service_empty)
        return
    end
    local service_list_table = cjson.decode(service_list_str);
    if not service_list_table and type(service_list_table) ~= 'table' then
        tl_ops_err_content:err_content_rewrite_to_balance("", "empty", "", tl_ops_constant_balance.cache_key.service_empty)
        return
    end

    -- 负载模式
    local balance_mode = "api"

    -- 先走api负载
    local node, node_state, node_id, host, rule_match_mode = tl_ops_balance_core_api.tl_ops_balance_api_service_matcher(service_list_table)
    if not node then
        -- api不匹配，走param负载
        balance_mode = "param"

        node, node_state, node_id, host, rule_match_mode = tl_ops_balance_core_param.tl_ops_balance_param_service_matcher(service_list_table)
        if not node then
            -- param不匹配，走cookie负载
            balance_mode = "cookie"

            node, node_state, node_id, host, rule_match_mode = tl_ops_balance_core_cookie.tl_ops_balance_cookie_service_matcher(service_list_table)
            if not node then
                -- cookie不匹配，走header负载
                balance_mode = "header"

                node, node_state, node_id, host, rule_match_mode = tl_ops_balance_core_header.tl_ops_balance_header_service_matcher(service_list_table)
                if not node then
                     -- header不匹配，走body负载
                    balance_mode = "body"

                    node, node_state, node_id, host, rule_match_mode = tl_ops_balance_core_body.tl_ops_balance_body_service_matcher(service_list_table)
                    if not node then
                        -- 无匹配
                        tl_ops_err_content:err_content_rewrite_to_balance("", "empty", balance_mode, tl_ops_constant_balance.cache_key.mode_empty)
                        return
                    end
                end
            end
        end
    end

    if rule_match_mode and rule_match_mode == api_match_mode.api then
        -- 域名负载
        if host == nil or host == '' then
            tl_ops_err_content:err_content_rewrite_to_balance("", "nil", balance_mode, tl_ops_constant_balance.cache_key.host_empty)
            return
        end

        -- 域名匹配
        if host ~= "*" and host ~= ngx.var.host then
            tl_ops_err_content:err_content_rewrite_to_balance("", "pass", balance_mode, tl_ops_constant_balance.cache_key.host_pass)
            return
        end
    end

    -- 流控介入
    if tl_ops_manage_env.balance.limiter then
        local depend = tl_ops_limit.tl_ops_limit_get_limiter(node.service, node_id)
        if depend then
            -- 令牌桶流控
            if depend == tl_ops_constant_limit.depend.token then
                local token_result = tl_ops_limit_fuse_token_bucket.tl_ops_limit_token( node.service, node_id)  
                if not token_result or token_result == false then
                    balance_count:tl_ops_balance_count_incr_fail(node.service, node_id)
                    tl_ops_err_content:err_content_rewrite_to_balance("", "t-limit", balance_mode, tl_ops_constant_balance.cache_key.token_limit)
                    return
                end
            end

            -- 漏桶流控 
            if depend == tl_ops_constant_limit.depend.leak then
                local leak_result = tl_ops_limit_fuse_leak_bucket.tl_ops_limit_leak( node.service, node_id)
                if not leak_result or leak_result == false then
                    balance_count:tl_ops_balance_count_incr_fail(node.service, node_id)
                    tl_ops_err_content:err_content_rewrite_to_balance("", "l-limit", balance_mode, tl_ops_constant_balance.cache_key.leak_limit)
                    return
                end
            end
        end
    end

    -- 服务层waf
    waf:init_service(node.service);

    -- 节点下线
    if not node_state or node_state == false then
        balance_count:tl_ops_balance_count_incr_fail(node.service, node_id)

        local limit_req_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_fail, node.service, node_id)
        local failed_count = shared:get(limit_req_fail_count_key)
		if not failed_count then
			shared:set(limit_req_fail_count_key, 0);
        end
        shared:incr(limit_req_fail_count_key, 1)
        
        tl_ops_err_content:err_content_rewrite_to_balance(node.service .. ":" .. node.name, "offline", balance_mode, tl_ops_constant_balance.cache_key.offline)
        return
    end

    ctx.tlops_ups_node = node
    ctx.tlops_ups_node_id = node_id
    ctx.tlops_ups_mode = balance_mode
end




-- 请求负载分发
function _M:tl_ops_balance_core_balance(ctx)

    local tlops_ups_mode = ctx.tlops_ups_mode
    local tlops_ups_node = ctx.tlops_ups_node
    local tlops_ups_node_id = ctx.tlops_ups_node_id

    if not tlops_ups_mode or not tlops_ups_node or not tlops_ups_node_id then
        return
    end

    -- 负载成功
    balance_count:tl_ops_balance_count_incr_succ(tlops_ups_node.service, tlops_ups_node_id)

    local limit_req_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.req_succ, tlops_ups_node.service, tlops_ups_node_id)
    local success_count = shared:get(limit_req_succ_count_key)
    if not success_count then
        shared:set(limit_req_succ_count_key, 0);
    end
    shared:incr(limit_req_succ_count_key, 1)

    ngx.header[tl_ops_constant_balance.proxy_server] = tlops_ups_node.service .. ":" .. tlops_ups_node.name;
    ngx.header[tl_ops_constant_balance.proxy_state] = "online"
    ngx.header[tl_ops_constant_balance.proxy_mode] = tlops_ups_mode

    local ok, err = ngx_balancer.set_current_peer(tlops_ups_node.ip, tlops_ups_node.port)
    if ok then
        ngx_balancer.set_timeouts(3, 60, 60)
    end
end




function _M:new()
	return setmetatable({}, mt)
end


return _M

