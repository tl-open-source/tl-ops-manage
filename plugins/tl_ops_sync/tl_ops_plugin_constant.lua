
local tl_ops_plugin_sync_constant = {
    fields = {
        -- 同步字段器，开启此选项后，将在每次启动nginx时，会执行一次同步字段。
        open = true,

        -- 同步模块定义，同步字段器需要同步的模块，如果新增需要持久化的模块，需要在此定义
        module = {
            "service", "health", "limit",
            "balance", "balance_api", "balance_cookie", "balance_header", "balance_param",
            "waf", "waf_ip", "waf_api", "waf_cc", "waf_header", "waf_cookie", "waf_param",
            "ssl", "auth", "time_alert"
        }
    },
    data = {
        -- 同步数据器，开启此选项后，将在每次启动nginx时，会执行一次同步数据。
        open = true,

        -- 同步模块定义，同步数据器需要同步的模块，如果新增需要持久化的模块，需要在此定义，
        -- 注意：之所以这里的模块不包含 ‘健康检查模块’，‘服务模块’，‘熔断限流模块’，
        -- 是因为这些模块的数据是在定时器中，而定时器中的数据同步是由其各自的动态配置器处理。
        module = {
            "balance_api", "balance_cookie", "balance_header", "balance_param",
            "waf_ip", "waf_api", "waf_cc", "waf_header", "waf_cookie", "waf_param",
            "ssl", "auth", "time_alert"
        }
    },
}

return tl_ops_plugin_sync_constant