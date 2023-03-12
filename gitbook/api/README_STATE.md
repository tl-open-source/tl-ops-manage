# 状态数据概览

对于基础模块数据接口的GET/SET之外，还有一个重要接口，数据概览接口，用于汇总各个基础模块的状态数据。

请求地址 : `/tlops/state/get`

请求方法 : `GET/POST`

```json
{
    "code": 0,          // 请求状态码，代码不报错，一般来说返回0                    
    "msg": "success",   // 状态信息
    "data": {
        "waf": {                                        // WAF模块状态数据汇总
            "waf_success": {                            // 全局WAF统计列表
                "2022-08-16 11:20:26": 3,               // 时间周期内触发多少次
            },                          
            "count_interval": 10                        // WAF统计器时间间隔
        },
        "balance": {                                    // 负载模块状态数据汇总
            "count_interval": 10                        // 负载统计器时间间隔
        },
        "service": {                                    // 服务列表
            "test": {                                   // 服务名称
                "health_lock": true,                    // 服务健康检查锁状态
                "health_version": 3,                    // 健康检查配置版本号
                "health_uncheck": false,                // 健康检查是否暂停
                "limit_state": 0,                       // 服务限流熔断状态
                "limit_version": 3,                     // 熔断配置版本号
                "waf_success": {                        // 服务WAF统计列表
                    "2022-08-16 11:20:26": 3,
                },                      
                "nodes": {                              // 节点列表
                    "test-node-1": {                    // 节点名称
                        "health_state": false,          // 节点健康状态
                        "balance_node_count": {         // 负载统计列表
                            "2022-08-16 11:20:26": 3,
                        },
                        "limit_depend": "token",        // 节点限流熔断依赖算法
                        "limit_capacity": "nil",        // 节点限流熔断最大容量
                        "limit_rate": "nil",            // 节点限流熔断速率
                        "limit_pre_time": "nil",        // 节点限流熔断桶更新时间
                        "limit_bucket": "nil",          // 节点限流熔断单位
                        "limit_failed": 0,              // 节点熔断周期内请求失败数量
                        "limit_success": 0,             // 节点熔断周期内请求成功数量
                        "limit_state": 0,               // 节点限流熔断状态
                        "health_failed": 154,           // 节点健康检查失败次数
                        "health_success": 0,            // 节点健康检查成功次数
                    },
                }
            },
        },
        "health": {                                     // 健康检查状态数据汇总
            "timer_list": [                             // 健康检查当前定时任务
                "test",
                "iamtsm-test"
            ],
            "options_list": [                           // 健康检查配置列表
                {
                    "check_failed_max_count": 5,        // 健康检查最大失败次数
                    "check_success_max_count": 2,       // 健康检查最大成功次数
                    "check_content": "GET / HTTP/1.0",  // 健康检查自检内容
                    "check_timeout": 1000,              // 健康检查自检超时时间
                    "check_success_status": [           // 健康检查成功状态码列表
                        200
                    ],
                    "check_interval": 10000,            // 健康检查自检周期
                    "check_service_name": "test"        // 健康检查自检服务名称
                },
            ]
        },
        "limit": {                                      // 熔断状态数据汇总
            "option_list": [
                {
                    "service_threshold": 0.5,           // 服务熔断阈值
                    "interval": 10000,                  // 熔断自检周期
                    "level": "service",                 // 熔断自检层级
                    "node_threshold": 0.3,              // 节点熔断阈值
                    "service_name": "test",             // 熔断自检服务名称
                    "recover": 15000,                   // 全熔断自恢复时间
                    "depend": "token",                  // 熔断依赖算法
                    "mode": "balance_fail"              // 熔断依赖数据模式
                },
            ]
        },
        "other": []
    },
}
```