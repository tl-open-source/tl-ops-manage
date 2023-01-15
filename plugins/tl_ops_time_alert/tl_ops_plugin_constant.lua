local mode = {
    log = "log",        -- 日志模式下 target = "/path/to/log_file.log"
    email = "email",    -- 邮件模式下 target = "xx@qq.com",
    robot = "robot",    -- 企业微信机器人通知 target = "机器人key"
}

local tl_ops_plugin_constant_time_alert = {
    cache_key = {
        time_lock = "tl_ops_plugin_time_alert_lock",        -- 定时器启动worker锁
        list_lock = "tl_ops_plugin_time_alert_list_lock",   -- 队列锁
        options = "tl_ops_plugin_time_alert_options",       -- 告警规则列表 (暂不支持动态配置，只能在文件配置)
        list = "tl_ops_plugin_time_alert_list",             -- 告警消息列表组 (定时消费，每组的数量为周期内处理的数量)
        produce = "tl_ops_plugin_time_alert_produce",       -- 告警消息列表生产指针，自增达到max后进行循环覆盖
        consume = "tl_ops_plugin_time_alert_consume",       -- 告警消息列表消费指针，递减达到最小后进行循环覆盖
    },
    tlops_api = {
        get = "/tlops/alert/get",
        set = "/tlops/alert/set",
    },
    mode = mode,
    interval = 5,                   -- 定时告警时间间隔 单位/s
    max_list_count = 10,            -- 最大告警组数量
    max_list_len = 100,             -- 周期内处理多少条告警消息
    options = {
        {
            id = 1,
            time = 1,
            count = 0,
            interval = 0,
            mode = mode.log,
            target = "plugin_time_alert_data",
        },
        {
            id = 2,
            time = 1000,
            count = 5,
            interval = 10,
            mode = mode.email,
            target = "1905333456@qq.com"
        },
        {
            id = 3,
            time = 1000,
            count = 5,
            interval = 10,
            mode = mode.robot,
            target = "xxxxxxxxxxxxxxxxx"
        },
    },
    demo = {
        id = 1,
        time = 1000,            -- 最大时间，超过即告警，单位/ms
        count = 100,            -- 触发多少次，超过即告警
        interval = 10,          -- 周期时间，配置count实现，周期内触发多少次。单位/s
        mode = mode.email,      -- 告警模式
        target = "xx@qq.com",   -- 告警通知对象，内容格式取决于mode
    },
    export = {
        cache_key = {
            time_alert = "tl_ops_plugins_export_time_alert",
        },
        time_alert = {
            zname = '耗时告警插件',
            page = "alert/tl_ops_web_alert.html",
            name = 'time_alert',
            open = true,
            scope = "tl_ops_process_after_init_worker,tl_ops_process_before_init_rewrite,tl_ops_process_after_init_log",
        },
        tlops_api = {
            get = "/tlops/time-alert/manage/get",       -- 获取插件配置数据的接口
            set = "/tlops/time-alert/manage/set",       -- 修改插件配置数据的接口
        },
        demo = {
            zname = '',         -- 插件中文名称
            page = "",          -- 插件配置页面
            name = '',          -- 插件名称
            open = true,        -- 插件是否开启
            scope = "",         -- 插件生命周期阶段
        }
    }
}

return tl_ops_plugin_constant_time_alert