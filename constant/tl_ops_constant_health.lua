local tl_ops_status = require("constant.tl_ops_constant_comm").tl_ops_status;
local tl_ops_constant_service = require("constant.tl_ops_constant_service");

---- 基础检测配置功能定义
local tl_ops_constant_heath_check = {
    options = {
        {
            check_failed_max_count = 5,
            check_success_max_count = 2,
            check_interval = 5 * 1000,
            check_timeout = 1000,
            check_content = "GET / HTTP/1.0\r\n\r\n\r\n",
            check_service_name = "service1"
        },
        {
            check_failed_max_count = 5,
            check_success_max_count = 2,
            check_interval = 5 * 1000,
            check_timeout = 1000,
            check_content = "GET / HTTP/1.0\r\n\r\n\r\n",
            check_service_name = "service2"
        }
    },
    cache_key = {
        lock = "tl_ops_heath_check_lock",
        version = "tl_ops_heath_check_version",
        state = "tl_ops_heath_check_donw_state",
        failed = "tl_ops_heath_check_failed_count",
        success = "tl_ops_heath_check_success_count"
    },
    service = tl_ops_constant_service.list,
}


return tl_ops_constant_heath_check