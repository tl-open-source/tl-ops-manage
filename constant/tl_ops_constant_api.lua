---- api 默认列表
local tl_ops_constant_api_list = {
    url = {
        {
            url = "/*",                 ---- 当前url匹配规则
            service = "service1",       ---- 当前url负载到的service
            index = 0                   ---- 当前url负载到的service下的node
        },
        {
            url = "/api/public/*",
            service = "service1",
            index = 1
        },
        {
            url = "/api/admin/*",
            service = "service2",
            index = 0
        },
        {
            url = "/api/v1/*",
            service = "service2",
            index = 1
        }
    },
    random = {
        {
            url = "/*",             ---- 当前url匹配规则
            service = "service1"    ---- 当前url负载到的service
        }, 
        {
            url = "/api/*",
            service = "service2"
        },
    },
    rule = {---- api rule 策略
        url = "url",        ---- url负载可指定到具体节点
        random = "random"       ---- 随机负载可指定到具体服务
    },
}

return tl_ops_constant_api_list