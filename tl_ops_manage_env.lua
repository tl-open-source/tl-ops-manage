local ROOT_PATH = "/path/to/tl-ops-manage/"

return {
    path = {
        --[[
            en :Console path setting, the page forwarding plugin will use this path for path matching
            
            zn :控制台路径设置，页面转发插件会将此路径用于路径匹配 
        ]]
        tlopsmanage = ROOT_PATH .. "web/",
        --[[
            en :The official website path setting, the page forwarding plugin 
                will use this path for path matching
            
            zn :官网路径设置，页面转发插件会将此路径用于路径匹配 
        ]]
        website = ROOT_PATH .. "website/",
        --[[
            en :log output directory, all module logs will be output to this directory
            
            zn :日志输出目录，所有模块的日志都将输出到此目录下
        ]]
        log = ROOT_PATH,
        --[[
            en :data storage directory, the directory where the module data is stored
            
            zn :数据存放目录，模块的数据存放的目录
        ]]
        store = ROOT_PATH .. "store/",
    },
    log = {
        --[[
            en :log level, please be careful not to enable debug level logs 
                in the production environment, it will greatly affect the performance.
            
            zn :日志等级, 注意请不要在生产环境开启调试级别日志，十分影响性能。debug = 1, std = 2, error = 3
        ]]
        level = 1,
        --[[
            en :log formatting. Turning this option on will take up more disk space. 
                It is recommended to turn off this option in a production environment
            
            zn :日志格式化，开启此选项会占用更多磁盘空间，生产环境推荐关闭此选项
        ]]
        format_json = true,
    },
    cache = {
        --[[
            en : enable custom L2 cache, currently supports options [redis], [none], 
                 [none] means close L2 cache
                 Supports custom extended cache implementations, such as etcd, mysql, etcd.
            
            zn :开启自定义二级缓存，目前支持选项 redis, none, none表示不开启二级缓存
                支持自定义扩展缓存实现，如etcd，mysql等。
        ]]
        cus = {
            name = "none",
            check_timeout = 30000,
            host = "127.0.0.1",
            port = 6379,
            auth = "your password",
        }
    },
    balance = {
        --[[
            en :load counter, after this option is enabled, every time nginx is started, 
                a timer will be enabled to count the load requests within a certain period of time
            
            zn :负载统计器，开启此选项后，将在每次启动nginx时，将开启定时器统计一定时间段内的负载请求情况
        ]]
        counting = true,
        --[[
            en :load counter interval, the time interval of the load counter, 
                the unit is seconds, the default is 10s 
                Notice: Do not set the statistical time interval too short, which may affect performance.
            
            zn :负载统计器间隔，负载统计器的时间间隔，单位为秒，默认为10s, 
                注意：统计时间间隔不要设置过短，可能会影响性能。
        ]]
        counting_interval = 10,
        --[[
            en :load current limiter. After this option is enabled, a current limiter will be 
                connected to the load balancing module. If you need to access current limit, 
                it is recommended to enable this option
            
            zn :负载限流器，开启此选项后，将在负载均衡模块接入限流器。如果需要接入限流，推荐开启此选项
        ]]
        limiter = true
    },
    waf = {
        --[[
            en :waf filtering, after this option is enabled, all traffic will be cleaned according 
                to the configuration rules, it is recommended to enable
            
            zn :waf过滤，开启此选项后，将根据配置规则对所有流量进行清洗，推荐开启
        ]]
        open = true,
        --[[
            en :waf filter statistic, after this option is enabled, every time nginx is started, 
                a timer will be enabled to count the waf filter requests within a certain period of time
                The time interval is configured in 'constant.tl_ops_constant_waf_count.interval'
                Notice: Do not set the statistical time interval too short, which may affect performance.
            
            zn :waf过滤统计器，开启此选项后，将在每次启动nginx时，将开启定时器统计一定时间段内的waf过滤请求情况
                时间间隔在‘constant.tl_ops_constant_waf_count.interval’进行配置
                注意：统计时间间隔不要设置过短，可能会影响性能。
        ]]
        counting = true,
        --[[
            en :waf filter statistic interval, the time interval of the waf filter statistic, 
                the unit is seconds, the default is 10s 
                Notice: Do not set the statistical time interval too short, which may affect performance.
            
            zn :waf过滤统计器间隔，waf过滤统计器的时间间隔，单位为秒，默认为10s, 
                注意：统计时间间隔不要设置过短，可能会影响性能。
        ]]
        counting_interval = 10,
    }
}
