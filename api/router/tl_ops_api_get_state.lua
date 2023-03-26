-- tl_ops_api 
-- en : get server current state
-- zn : 获取状态数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_constant_waf           = require("constant.tl_ops_constant_waf");
local tl_ops_constant_waf_count     = require("constant.tl_ops_constant_waf_count");
local tl_ops_constant_balance_count = require("constant.tl_ops_constant_balance_count");
local tl_ops_constant_service       = require("constant.tl_ops_constant_service");
local tl_ops_constant_health        = require("constant.tl_ops_constant_health")
local tl_ops_constant_limit         = require("constant.tl_ops_constant_limit");
local tl_ops_limit                  = require("limit.tl_ops_limit");
local cache_service                 = require("cache.tl_ops_cache_core"):new("tl-ops-service");
local cache_limit                   = require("cache.tl_ops_cache_core"):new("tl-ops-limit");
local cache_health                  = require("cache.tl_ops_cache_core"):new("tl-ops-health");
local cache_waf_count               = require("cache.tl_ops_cache_core"):new("tl-ops-waf-count");
local cache_balance_count           = require("cache.tl_ops_cache_core"):new("tl-ops-balance-count");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local shared                        = ngx.shared.tlopsbalance
local cjson                         = require("cjson.safe");
cjson.encode_empty_table_as_object(false)

local Handler = function()
    --返回的cache state
    local cache_state = {
        service = {}, health = {}, limit = {}, balance = {}, waf = {}, other = {}
    }

    -- 服务相关状态
    local list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not list_str or list_str == nil then
        return tl_ops_rt.not_found ,"not found list", _
    end
    local service_list = cjson.decode(list_str)

    for service_name, nodes in pairs(service_list) do
        -- service级别cache
        local health_lock_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.lock, service_name))
        if not health_lock_cache then
            health_lock_cache = false --"lock cache nil"
        end
        local health_version_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.service_version, service_name))
        if not health_version_cache then
            health_version_cache = 0 --"version cache nil"
        end
        local health_uncheck_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.uncheck, service_name))
        if not health_uncheck_cache then
            health_uncheck_cache = false --"uncheck cache nil"
        end

        local limit_state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, service_name))
        if not limit_state_cache then
            limit_state_cache = 0 --"state cache nil"
        end

        local limit_version_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_version, service_name))
        if not limit_version_cache then
            limit_version_cache = 0 --"version cache nil"
        end

        -- waf统计， service级别是包含了service下所有waf规则下的汇总统计
        local waf_api_count = cache_waf_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, "api"))
        if not waf_api_count then
            waf_api_count = "{}"
        end

        local waf_ip_count = cache_waf_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, "ip"))
        if not waf_ip_count then
            waf_ip_count = "{}"
        end

        local waf_cc_count = cache_waf_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, "cc"))
        if not waf_cc_count then
            waf_cc_count = "{}"
        end

        local waf_cookie_count = cache_waf_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, "cookie"))
        if not waf_cookie_count then
            waf_cookie_count = "{}"
        end

        local waf_header_count = cache_waf_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, "header"))
        if not waf_header_count then
            waf_header_count = "{}"
        end

        local waf_param_count = cache_waf_count:get001(tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.service_counting_list, service_name, "param"))
        if not waf_param_count then
            waf_param_count = "{}"
        end

        cache_state.service[service_name] = {
            health_lock = health_lock_cache,
            health_version = health_version_cache,
            health_uncheck = health_uncheck_cache,
            limit_state = limit_state_cache,
            limit_version = limit_version_cache,
            waf_api_count = cjson.decode(waf_api_count),
            waf_ip_count = cjson.decode(waf_ip_count),
            waf_cc_count = cjson.decode(waf_cc_count),
            waf_cookie_count = cjson.decode(waf_cookie_count),
            waf_header_count = cjson.decode(waf_header_count),
            waf_param_count = cjson.decode(waf_param_count),
        }
        cache_state.service[service_name].nodes = { }

        if nodes == nil then
            nodes = cjson.encode("{}")
        end
        
        -- node级别cache
        for i = 1, #nodes do
            local node_id = i-1
            local node = nodes[i]

            local health_node_state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.state, node.service, node_id))
            if not health_node_state_cache then
                health_node_state_cache = false --"state cache nil"
            end
            local health_node_failed_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.failed, node.service, node_id))
            if not health_node_failed_cache then
                health_node_failed_cache = 0 --"failed cache nil"
            end
            local health_node_success_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_health.cache_key.success, node.service, node_id))
            if not health_node_success_cache then
                health_node_success_cache = 0 --"success cache nil"
            end

            local limit_node_state_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.service_state, node.service, node_id))
            if not limit_node_state_cache then
                limit_node_state_cache = 0 --"state cache nil"
            end

            local limit_node_success_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.node_req_succ, node.service, node_id))
            if not limit_node_success_cache then
                limit_node_success_cache = 0 --"success cache nil"
            end

            local limit_node_failed_cache = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.node_req_fail,  node.service, node_id))
            if not limit_node_failed_cache then
                limit_node_failed_cache = 0 --"failed cache nil"
            end

            local limit_depend = tl_ops_limit:tl_ops_limit_get_limiter(node.service, node_id)
            local limit_capacity
            local limit_rate
            local limit_pre_time
            local limit_bucket
            local limit_block
            if limit_depend == tl_ops_constant_limit.depend.token then
                limit_capacity = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.capacity,  node.service, node_id))
                if not limit_capacity then
                    limit_capacity = 'nil'
                end
                limit_rate = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.rate,  node.service, node_id))
                if not limit_rate then
                    limit_rate = 'nil'
                end
                limit_block = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.block,  node.service, node_id))
                if not limit_block then
                    limit_block = 'nil'
                end
                limit_pre_time = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.pre_time,  node.service, node_id))
                if not limit_pre_time then
                    limit_pre_time = 'nil'
                end
                limit_bucket = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.token.cache_key.token_bucket,  node.service, node_id))
                if not limit_bucket then
                    limit_bucket = 'nil'
                end
            end

            if limit_depend == tl_ops_constant_limit.depend.leak then
                limit_capacity = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.capacity,  node.service, node_id))
                if not limit_capacity then
                    limit_capacity = 'nil'
                end
                limit_rate = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.rate,  node.service, node_id))
                if not limit_rate then
                    limit_rate = 'nil'
                end
                limit_block = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.block,  node.service, node_id))
                if not limit_block then
                    limit_block = 'nil'
                end
                limit_pre_time = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.pre_time,  node.service, node_id))
                if not limit_pre_time then
                    limit_pre_time = 'nil'
                end
                limit_bucket = shared:get(tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.leak.cache_key.leak_bucket,  node.service, node_id))
                if not limit_bucket then
                    limit_bucket = 'nil'
                end
            end

            -- 路由统计
            local balance_count_node_list = cache_balance_count:get001(
                tl_ops_utils_func:gen_node_key(
                    tl_ops_constant_balance_count.cache_key.node_counting_list, node.service, node_id
                )
            ) 
            if not balance_count_node_list then
                balance_count_node_list = "{}"
            end

            cache_state.service[service_name].nodes[node.name] = {
                health_state = health_node_state_cache,
                health_failed = health_node_failed_cache,
                health_success = health_node_success_cache,
                limit_state = limit_node_state_cache,
                limit_success = limit_node_success_cache,
                limit_failed = limit_node_failed_cache,
                limit_depend = limit_depend,
                limit_capacity = limit_capacity,
                limit_rate = limit_rate,
                limit_block = limit_block,
                limit_pre_time = limit_pre_time,
                limit_bucket = limit_bucket,
                balance_node_count = cjson.decode(balance_count_node_list),
            }
        end
    end

    -- 健康检查相关状态
    local health_options_str, _ = cache_health:get(tl_ops_constant_health.cache_key.options_list);
    if not health_options_str or health_options_str == nil then
        return tl_ops_rt.not_found, "not found list", _
    end
    local health_options_list = cjson.decode(health_options_str)

    local health_timers_str = shared:get(tl_ops_constant_health.cache_key.timers)
    if not health_timers_str then
        health_timers_str = "{}" --"timers nil"
    end
    local health_timer_list = cjson.decode(health_timers_str)
    cache_state.health['timer_list'] = health_timer_list
    cache_state.health['options_list'] = health_options_list    


    -- 限流相关状态
    local limit_options_str, _ = cache_limit:get(tl_ops_constant_limit.fuse.cache_key.options_list);
    if not limit_options_str or limit_options_str == nil then
        return tl_ops_rt.not_found, "not found list", _
    end
    local limit_options_list = cjson.decode(limit_options_str)

    local limit_timers_str = shared:get(tl_ops_constant_limit.fuse.cache_key.timers)
    if not limit_timers_str then
        limit_timers_str = "{}" --"timers nil"
    end
    local limit_timer_list = cjson.decode(limit_timers_str)
    cache_state.health['timer_list'] = limit_timer_list
    cache_state.limit['option_list'] = limit_options_list
        

    -- 路由相关
    cache_state.balance['count_interval'] = tl_ops_constant_balance_count.interval

    -- waf相关
    cache_state.waf['count_interval'] = tl_ops_constant_waf_count.interval

    -- 其他
    -- cache_state.other['dict_keys'] = shared:get_keys(1024)

    return tl_ops_rt.ok, "success", cache_state
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}

