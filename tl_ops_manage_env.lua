return {
    log = {
        --[[
            en :log level, please be careful not to enable debug level logs 
                in the production environment, it will greatly affect the performance.
            
            zn :日志等级, 注意请不要在生产环境开启调试级别日志，十分影响性能。
        ]]
        level = 1,
        --[[
            en :log formatting. Turning this option on will take up more disk space. 
                It is recommended to turn off this option in a production environment
            
            zn :日志格式化，开启此选项会占用更多磁盘空间，生产环境推荐关闭此选项
        ]]
        format_json = true,
        --[[
            en :log output directory, all module logs will be output to this directory, 
                Notice : need to fill in the 'absolute path'
            
            zn :日志输出目录，所有模块的日志都将输出到此目录下，注意：需要填写 ‘绝对路径’
        ]]
        log_dir = "F:/code/tl-open-source/tl-ops-manage/",
        --[[
            en :data storage directory, the directory where the module data is stored, 
                Notice: need to fill in the 'absolute path'
            
            zn :数据存放目录，模块的数据存放的目录，注意：需要填写 ‘绝对路径’
        ]]
        store_dir = "F:/code/tl-open-source/tl-ops-manage/store/",
    },
    cache = {
        --[[
            en :enable redis cache. Notice: that you need to install redis first to enable this option.
            
            zn :是否开启redis缓存，注意，开启此选项需要先安装redis。
        ]]
        redis = true
    },
    sync = {
        fields = {
            --[[
                en :sync field device. After this option is turned on, each time nginx is started, 
                    the field will be synchronized once.
                
                zn :同步字段器，开启此选项后，将在每次启动nginx时，会执行一次同步字段。
            ]]
            open = true,
            --[[
                en :synchronization module definition. The synchronization field device needs to synchronize the module. 
                    If you add a new module that needs to be persisted, you need to define it here.
                
                zn :同步模块定义，同步字段器需要同步的模块，如果新增需要持久化的模块，需要在此定义
            ]]
            module = {
                "service", "health", "limit-fuse", "limit-token", "limit-leak",
                "balance", "balance-api", "balance-cookie", "balance-header", "balance-param",
                "waf", "waf-ip", "waf-api", "waf-cc", "waf-header", "waf-cookie", "waf-param"
            }
        },
        data = {
            --[[
                en :sync data timer. After this option is turned on, 
                    each time nginx is started, the data will be synchronized once.
                
                zn :同步数据器，开启此选项后，将在每次启动nginx时，会执行一次同步数据。
            ]]
            open = true,
            --[[
                en :synchronization module definition. The synchronization data timer needs to synchronize 
                    the module. If you add a new module that needs to be persisted, you need to define it here.
                    Notice: The reason why the modules here do not include 'health check module', 
                            'service module','fuse current limiting module', This is because 
                            the data of these modules is in the timer, and the data synchronization 
                            in the timer is handled by their respective dynamic configurators.
                
                zn :同步模块定义，同步数据器需要同步的模块，如果新增需要持久化的模块，需要在此定义，
                    注意：之所以这里的模块不包含 ‘健康检查模块’，‘服务模块’，‘熔断限流模块’，
                    是因为这些模块的数据是在定时器中，而定时器中的数据同步是由其各自的动态配置器处理。
            ]]
            module = {
                "balance-api", "balance-cookie", "balance-header", "balance-param",
                "waf-ip", "waf-api", "waf-cc", "waf-header", "waf-cookie", "waf-param"
            }
        },
        cluster_data = {
            --[[
                en :sync cluster data timer. After this option is turned on, 
                    each time nginx is started, the data will be synchronized once.
                
                zn :同步集群数据器，开启此选项后，将在每次启动nginx时，会执行一次同步数据。
            ]]
            open = true,
            --[[
                en :synchronization module definition. The synchronization data timer needs to synchronize 
                    the module. If you add a new module that needs to be persisted, you need to define it here.
                    Notice: The reason why the modules here do not include 'health check module', 
                            'service module','fuse current limiting module', This is because 
                            the data of these modules is in the timer, and the data synchronization 
                            in the timer is handled by their respective dynamic configurators.

                zn :同步模块定义，同步数据器需要同步的模块，如果新增需要持久化的模块，需要在此定义，
                    注意：之所以这里的模块不包含 ‘健康检查模块’，‘服务模块’，‘熔断限流模块’，
                    是因为这些模块的数据是在定时器中，而定时器中的数据同步是由其各自的动态配置器处理。
            ]]
            module = {
                "balance-api", "balance-cookie", "balance-header", "balance-param",
                "waf-ip", "waf-api", "waf-cc", "waf-header", "waf-cookie", "waf-param"
            }
        }
    },
    balance = {
        --[[
            en :load counter, after this option is enabled, every time nginx is started, 
                a timer will be enabled to count the load requests within a certain period of time
                The time interval is configured in 'constant.tl_ops_constant_balance.count.interval'
                Notice: Do not set the statistical time interval too short, which may affect performance.
            
            zn :负载统计器，开启此选项后，将在每次启动nginx时，将开启定时器统计一定时间段内的负载请求情况
                时间间隔在‘constant.tl_ops_constant_balance.count.interval’进行配置
                注意：统计时间间隔不要设置过短，可能会影响性能。
        ]]
        counting = true,
        --[[
            en :load current limiter. After this option is enabled, a current limiter will be 
                connected to the load balancing module. If you need to access current limit, 
                it is recommended to enable this option
            
            zn :负载限流器，开启此选项后，将在负载均衡模块接入限流器。如果需要接入限流，推荐开启此选项
        ]]
        limiter = true,
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
                The time interval is configured in 'constant.tl_ops_constant_waf.count.interval'
                Notice: Do not set the statistical time interval too short, which may affect performance.
            
            zn :waf过滤统计器，开启此选项后，将在每次启动nginx时，将开启定时器统计一定时间段内的waf过滤请求情况
                时间间隔在‘constant.tl_ops_constant_waf.count.interval’进行配置
                注意：统计时间间隔不要设置过短，可能会影响性能。
        ]]
        counting = true,

    },
    plugin = {
        --[[
            en :plugins, when this option is turned on, the added plugins will be enabled
            
            zn :插件，开启此选项后，将在启动时加载添加的所有插件
        ]]
        open = true,
        --[[
            en :plugin module definition, the imported plugin needs to be defined here before it can be loaded. 
                Otherwise it will not take effect
            
            zn :插件模块定义，引入的插件需要在此定义好才能被加载。否则将不生效
        ]]
        module = {
            "log_analyze", "api_authentication", "cluster_sync","template"
        }
    }
}
