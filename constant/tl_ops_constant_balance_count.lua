local tl_ops_constant_balance_count = {
    cache_key = {
        -- 临时字段
        lock = "tl_ops_balance_count_lock",
        node_req_succ = "tl_ops_balance_node_req_succ",                 -- 以服务节点为单位路由请求成功次数     int
        node_req_fail = "tl_ops_balance_node_req_fail",                 -- 以服务节点为单位路由请求失败次数     int
        api_req_succ = "tl_ops_balance_api_req_succ",                   -- 以api规则命中次数次数 int
        body_req_succ = "tl_ops_balance_body_req_succ",                 -- 以body规则命中次数次数 int
        cookie_req_succ = "tl_ops_balance_cookie_req_succ",             -- 以bookie规则命中次数次数 int
        header_req_succ = "tl_ops_balance_header_req_succ",             -- 以header规则命中次数次数 int
        param_req_succ = "tl_ops_balance_param_req_succ",               -- 以param规则命中次数次数 int

        -- 持久化字段
        node_counting_list = "tl_ops_balance_node_counting_list",       -- 以服务节点为单位，周期内统计次数集合 list
        api_counting_list = "tl_ops_balance_api_counting_list",         -- 以服务节点的api为单位，周期内统计次数集合 list
        body_counting_list = "tl_ops_balance_body_counting_list",       -- 以服务节点的body为单位，周期内统计次数集合 list
        cookie_counting_list = "tl_ops_balance_cookie_counting_list",   -- 以服务节点的cookie为单位，周期内统计次数集合 list
        header_counting_list = "tl_ops_balance_header_counting_list",   -- 以服务节点的header为单位，周期内统计次数集合 list
        param_counting_list = "tl_ops_balance_param_counting_list",     -- 以服务节点的param为单位，周期内统计次数集合 list
        
    },
    interval = 10,              -- 统计周期 单位/s, 默认:10s
}

return tl_ops_constant_balance_count