local tl_ops_constant_service = require("constant.tl_ops_constant_service");

-- 基础检测配置功能定义
local tl_ops_constant_health_check = {
    cache_key = {
        -- 临时字段
        lock = "tl_ops_health_check_lock",                                  -- boolean  
        state = "tl_ops_health_check_donw_state",                           -- boolean    健康状态标记
        failed = "tl_ops_health_check_failed_count",                        -- int        自检失败标记
        success = "tl_ops_health_check_success_count",                      -- int        自检成功标记
        service_version = "tl_ops_health_service_version",                  -- int        服务配置变动
        service_options_version = "tl_ops_health_service_options_version",  -- boolean    服务新增变动
        timers = "tl_ops_health_timers",                                    -- list       当前开启自检的服务
        uncheck = "tl_ops_health_check_uncheck",                            -- boolean    服务/节点是否关闭自检

        -- 持久化字段
        options_list = "tl_ops_health_options_list",                        -- list       健康配置缓存
        history_state = "tl_ops_health_history_state",                      -- list       TODO 未实现
    },
    options = { 

    }, 
    demo = {
        check_failed_max_count = 5,         -- 自检周期内失败次数 
        check_success_max_count = 2,        -- 自检周期内成功次数
        check_interval = 10 * 1000,         -- 自检服务自检周期
        check_timeout = 1000,               -- 自检节点心跳包连接超时时间
        check_content = "GET / HTTP/1.0",   -- 自检心跳包内容
        check_success_status = {            -- 自检返回成功状态, 如 201,202（代表成功）
            200
        },
        check_service_name = "tlops-demo"   -- 自检服务名称 (自动生成)
    },
    service = tl_ops_constant_service.list,
}


return tl_ops_constant_health_check