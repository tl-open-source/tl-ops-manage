local tl_ops_constant_service = require("constant.tl_ops_constant_service");

---- 基础检测配置功能定义
local tl_ops_constant_health_check = {
    cache_key = {
        lock = "tl_ops_health_check_lock",                           ---- boolean
        state = "tl_ops_health_check_donw_state",                    ---- boolean
        failed = "tl_ops_health_check_failed_count",                 ---- int
        success = "tl_ops_health_check_success_count",               ---- int

        options_list = "tl_ops_health_options_list",                        ---- list       健康配置缓存
        service_version = "tl_ops_health_service_version",                  ---- int        服务配置变动
        service_options_version = "tl_ops_health_service_options_version",  ---- boolean    服务新增变动
        timers = "tl_ops_health_timers",                                    ---- list       当前开启自检的服务
        history_state = "tl_ops_health_history_state",                      ---- list       TODO
    },
    options = { ---- service health check default配置
        {
            check_failed_max_count = 5,
            check_success_max_count = 2,
            check_interval = 5 * 1000,
            check_timeout = 1000,
            check_content = "GET / HTTP/1.0",
            check_service_name = "service1"
        },
        {
            check_failed_max_count = 5,
            check_success_max_count = 2,
            check_interval = 5 * 1000,
            check_timeout = 1000,
            check_content = "GET / HTTP/1.0",
            check_service_name = "service2"
        }
    },
    service = tl_ops_constant_service.list,
}


return tl_ops_constant_health_check