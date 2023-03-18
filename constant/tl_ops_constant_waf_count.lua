-- waf统计
local tl_ops_constant_waf_count = {
    cache_key = {
        -- 临时字段
        lock = "tl_ops_waf_count_lock",
        service_req_succ = "tl_ops_waf_service_req_succ",          -- 以服务为单位命中次数次数 int
        ip_req_succ = "tl_ops_waf_ip_req_succ",                    -- 以ip规则命中次数次数 int
        api_req_succ = "tl_ops_waf_api_req_succ",                  -- 以api规则命中次数次数 int
        cc_req_succ = "tl_ops_waf_cc_req_succ",                    -- 以cc规则命中次数次数 int
        cookie_req_succ = "tl_ops_waf_cookie_req_succ",            -- 以cookie规则命中次数次数 int
        header_req_succ = "tl_ops_waf_header_req_succ",            -- 以header规则命中次数次数 int
        param_req_succ = "tl_ops_waf_param_req_succ",              -- 以param规则命中次数次数 int

        -- 持久化字段
        service_counting_list = "tl_ops_waf_service_counting_list",    -- 以服务单位，周期内统计次数集合 list
        ip_counting_list = "tl_ops_waf_ip_counting_list",              -- 以ip规则单位，周期内统计次数集合 list
        api_counting_list = "tl_ops_waf_api_counting_list",            -- 以api规则单位，周期内统计次数集合 list
        cc_counting_list = "tl_ops_waf_cc_counting_list",              -- 以cc规则为单位，周期内统计次数集合 list
        cookie_counting_list = "tl_ops_waf_cookie_counting_list",      -- 以cookie规则为单位，周期内统计次数集合 list
        header_counting_list = "tl_ops_waf_header_counting_list",      -- 以header规则为单位，周期内统计次数集合 list
        param_counting_list = "tl_ops_waf_param_counting_list",        -- 以param规则为单位，周期内统计次数集合 list
    },
    interval = 10,      -- 统计周期 单位/s
}

return tl_ops_constant_waf_count