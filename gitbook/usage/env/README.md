
# 配置

#### 对于tl-ops-manage来说，配置以 `*.tlindex` 和 `*.tlstore`中的数据为主。

配置有两种方式，一种是在配置文件中填写配置，另外一种是在管理台填写配置。同时，配置是分为两种类别，一种是定时任务中的配置，另外一种是无需进入定时任务的规则配置。


## 配置类别


### 定时任务配置

    在定时任务中的配置，是在ngx.timer启动时传入，并启动相应的timer，其作用域是在timer的作用域中，如果发生配置变动ngx.timer是主动无法感知的。所以是需要主动判断timer内的conf是否需要同步为最新

 如 “健康检查配置”，“熔断限流配置”，“服务节点配置” 这些需要依赖定时任务的都属于定时任务配置。

### 规则配置

    而像负载多策略配置，如 “API负载规则” ，“WAF-CC规则”，... 这类配置是在请求阶段实时获取的，是实时保持最新，无需主动同步的


## 配置方式


### 文件中配置

    在文件中配置的数据，会在启动时同步合并至store文件中，并进行数据预热至内存中。


### 管理台配置 

    在管理后台设置的数据，会直接进入store中



# 全局项目配置


除了基础数据配置外，tl-ops-manage还提供了全局配置，对应的配置文件在，`tl-ops-manage/tl_ops_manage_env.lua` 中，全局配置支持了对各种功能模块的的细化控制


```lua
local ROOT_PATH = "F:/code/tl-open-source/tl-ops-manage/"

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
            
            zn :日志等级, 注意请不要在生产环境开启调试级别日志，十分影响性能。
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
            
            zn :开启自定义二级缓存，目前支持选项 【redis】, 【none】, 【none】表示不开启二级缓存
                支持自定义扩展缓存实现，如etcd，mysql等。
        ]]
        cus = "redis"
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
                Notice: the order in which plugins are filled in will affect the order in which the same plugin stages are executed
            
            zn :插件模块定义，引入的插件需要在此定义好才能被加载。否则将不生效。注意，插件填写的顺序将影响相同插件阶段执行的顺序
        ]]
        module = {
            "ssl", "sync", "sync_cluster", "page_proxy",
            -- "jwt", "cors", "log_analyze", "tracing"
        }
    }
}

```
