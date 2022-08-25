# 配置数据获取

对于管理端API来说，对于各个模块的配置获取是批量性的获取，下面对各个模块的数据格式进行说明


## 服务节点配置获取

请求地址 : `/tlops/service/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,          // 请求状态码，代码不报错，一般来说返回0
    "msg": "success",   // 状态信息
    "data": {
        "tl_ops_service_list": {                            // 服务节点配置列表key
            "test": [                                       // 节点列表
                {
                    "service": "test",                      // 节点所属服务
                    "updatetime": "2022-08-11 15:15:00",    // 节点信息更新时间
                    "name": "test-node-1",                  // 节点名称
                    "id": "1011171617076035585",            // 节点id
                    "port": 9091,                           // 节点端口
                    "protocol": "http://",                  // 节点支持的协议
                    "ip": "127.0.0.1"                       // 节点ip
                },
            ]
        },
        "tl_ops_service_rule": "auto_load"
    }
}
```

## 健康检查配置获取

请求地址 : `/tlops/health/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_health_options_list": [             // 健康检查配置列表key
            {
                "check_failed_max_count": 5,        // 最大失败次数
                "check_success_max_count": 2,       // 最大成功次数
                "check_content": "GET / HTTP/1.0",  // 自检内容
                "check_timeout": 1000,              // 自检超时时间
                "check_success_status": [           // 成功状态码列表
                    200
                ],
                "check_interval": 10000,            // 自检周期
                "check_service_name": "test"        // 自检服务名称
            }
        ]
    }
}
```

## 熔断限流配置获取

请求地址 : `/tlops/limit/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_limit_fuse_options_list": [         // 熔断配置列表key
            {
                "service_threshold": 0.5,           // 服务熔断阈值
                "interval": 10000,                  // 熔断自检周期
                "level": "service",                 // 熔断自检层级
                "node_threshold": 0.3,              // 节点熔断阈值
                "service_name": "test",             // 熔断自检服务名称
                "recover": 15000,                   // 全熔断自恢复时间
                "depend": "token",                  // 熔断依赖算法
                "mode": "balance_fail"              // 熔断依赖数据模式
            }
        ],
        "tl_ops_limit_token_options_list": [        // 令牌桶配置列表key
            {
                "warm": 102400,                     // 令牌桶预热数量
                "rate": 1024,                       // 令牌生成速率/秒 (每秒 1KB)
                "shrink": 0.5,                      // 令牌桶缩容比例
                "block": 1024,                      // 令牌桶最小单位
                "expand": 0.5,                      // 令牌桶扩容比例
                "service_name": "test",             // 令牌桶负责的服务
                "capacity": 10485760                // 令牌桶最大容量
            }
        ],
        "tl_ops_limit_leak_options_list": [         // 漏桶配置列表key
            {
                "rate": 1024,                       // 漏生成速率/秒 (每秒 1KB)
                "shrink": 0.5,                      // 漏桶缩容比例
                "block": 1024,                      // 漏桶最小单位
                "expand": 0.5,                      // 漏桶扩容比例
                "service_name": "test",             // 漏桶负责的服务
                "capacity": 10485760                // 漏桶最大容量
            }
        ]
    }
}
```

## 数据文件列表获取

请求地址 : `/tlops/store/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "api" : {                                   // 数据文件内容key
            "name": "tl-ops-balance-api.tlstore",   // 数据文件名称
            "version": 62,                          // 数据文件内容版本数
            "id": 1,                                // 数据文件id
            "size": 40072,                          // 数据文件内容大小
            "list": [                               // 数据文件内容版本列表
                {                                   // 数据文件内容详情
                    "value": "{\"point\":[],\"random\":[]}",
                    "business": "tl-ops-balance-api",
                    "time": "2022-08-11 15:14:12"
                },
            ],
        }
    }
}
```

## 负载错误内容配置获取

请求地址 : `/tlops/balance/get`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "offline": {                                // 负载错误内容key
            "content": "<p> offline err </p>",      // 负载错误自定义内容
            "code": 503,                            // 负载错误自定义错误码
            "content_type": "text/html"             // 负载错误自定义内容格式
        },
    }
}
```

## 负载API规则配置获取

请求地址 : `/tlops/balance/api/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_balance_api_rule": "point",                 // 当前选中模式
        "tl_ops_balance_api_list": {                        // 规则列表key
            "point": [                                      // 指定模式规则列表
                {
                    "id": "1012923972696031233",            // 规则id
                    "updatetime": "2022-08-16 11:18:14",    // 规则更新时间
                    "host": "localhost",                    // 规则生效域名
                    "service": "test",                      // 规则转发到的服务
                    "rewrite_url": "",                      // 规则重写uri地址
                    "node": 1,                              // 规则转发到服务下的节点索引
                    "url": "/online/*"                      // 规则匹配正则
                }
            ],
            "random": []                                    // 随机模式规则列表 (相比于point少了一个node索引)
        },
    }
}
```

## 负载COOKIE规则配置获取

请求地址 : `/tlops/balance/cookie/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_balance_cookie_rule": "point",              // 当前选中模式
        "tl_ops_balance_cookie_list": {                     // 规则列表key
            "point": [                                      // 指定模式规则列表
                {
                    "id": "1015832846214250497",            // 规则id
                    "updatetime": "2022-08-24 11:57:03",    // 规则更新时间
                    "host": "localhost",                    // 规则生效域名
                    "node": 0,                              // 规则转发到服务下的节点索引
                    "service": "test",                      // 规则转发到的服务
                    "key": "iamtsm",                        // 规则匹配名称
                    "value": [                              // 规则匹配值列表
                        "666"
                    ],
                }
            ],
            "random": []                                    // 随机模式规则列表 (相比于point少了一个node索引)
        },
    }
}
```

## 负载请求头规则配置获取

请求地址 : `/tlops/balance/header/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_balance_header_rule": "point",              // 当前选中模式
        "tl_ops_balance_header_list": {                     // 规则列表key
            "point": [                                      // 指定模式规则列表
                {
                    "id": "1015834324085653505",            // 规则id
                    "updatetime": "2022-08-24 12:02:56",    // 规则更新时间
                    "host": "localhost",                    // 规则生效域名
                    "node": 0,                              // 规则转发到服务下的节点索引
                    "service": "test",                      // 规则转发到的服务
                    "key": "iamtsm",                        // 规则匹配名称
                    "value": [                              // 规则匹配值列表
                        "test"
                    ],
                }
            ],
            "random": []                                    // 随机模式规则列表 (相比于point少了一个node索引)
        },
    }
}
```

## 负载请求参数规则配置获取

请求地址 : `/tlops/balance/param/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_balance_param_rule": "point",               // 当前选中模式
        "tl_ops_balance_param_list": {                      // 规则列表key
            "point": [                                      // 指定模式规则列表
                {
                    "id": "1015833876272398337",            // 规则id
                    "updatetime": "2022-08-24 12:01:09",    // 规则更新时间
                    "host": "localhost",                    // 规则生效域名
                    "node": 0,                              // 规则转发到服务下的节点索引
                    "service": "test",                      // 规则转发到的服务
                    "key": "iamtsm",                        // 规则匹配名称
                    "value": [                              // 规则匹配值列表
                        "111"
                    ],
                }
            ],
            "random": []                                    // 随机模式规则列表 (相比于point少了一个node索引)
        },
    }
}
```

## WAF错误内容配置获取

请求地址 : `/tlops/waf/get`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "waf_ip": {                             // WAF错误内容key
            "content_type": "text/html",        // WAF错误内容格式
            "code": 503,                        // WAF自定义错误码
            "content": "<p> waf_ip err </p>"    // WAF自定义错误内容
        },
    },
}
```

## WAF-API规则配置获取

请求地址 : `/tlops/waf/api/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_waf_api_open": true,                    // 当前策略是否开启
        "tl_ops_waf_api_scope": "global",               // 当前策略作用域
        "tl_ops_waf_api_list": [                        // 规则列表key
            {
                "id": "1015860313415106561",            // 规则id
                "service": "test",                      // 规则生效的服务
                "node": 0,                              // 规则生效服务的节点索引
                "value": "java\\.lang",                 // 规则匹配正则
                "updatetime": "2022-08-24 13:46:12",    // 规则更新时间
                "white": false,                         // 规则是否为白名单
                "host": "localhost"                     // 规则生效的域名
            }
        ],
    },
}
```

## WAF-IP规则配置获取

请求地址 : `/tlops/waf/ip/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_waf_ip_open": true,                     // 当前策略是否开启
        "tl_ops_waf_ip_scope": "global",                // 当前策略作用域
        "tl_ops_waf_ip_list": [                         // 规则列表key
            {
                "id": "994878242991521808",             // 规则id
                "service": "test",                      // 规则生效的服务
                "node": 0,                              // 规则生效服务的节点索引
                "value": "127.0.0.1",                   // 规则匹配正则
                "updatetime": "2022-08-24 13:46:12",    // 规则更新时间
                "white": true,                          // 规则是否为白名单
                "host": "localhost"                     // 规则生效的域名
            }
        ],
    },
}
```

## WAF-CC规则配置获取

请求地址 : `/tlops/waf/cc/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_waf_cc_open": true,                     // 当前策略是否开启
        "tl_ops_waf_cc_scope": "global",                // 当前策略作用域
        "tl_ops_waf_cc_list": [                         // 规则列表key
            {
                "id": "994878242991521808",             // 规则id
                "service": "test",                      // 规则生效的服务
                "node": 0,                              // 规则生效服务的节点索引
                "count": 100,                           // 周期内触发次数
                "time": 10,                             // 周期时间
                "updatetime": "2022-08-24 13:46:12",    // 规则更新时间
                "host": "localhost"                     // 规则生效的域名
            }
        ],
    },
}
```

## WAF-COOKIE规则配置获取

请求地址 : `/tlops/waf/cookie/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_waf_cookie_open": true,                 // 当前策略是否开启
        "tl_ops_waf_cookie_scope": "global",            // 当前策略作用域
        "tl_ops_waf_cookie_list": [                     // 规则列表key
            {
                "id": "994878242991521808",             // 规则id
                "service": "test",                      // 规则生效的服务
                "node": 0,                              // 规则生效服务的节点索引
                "value": "select.+(from|limit)",        // 规则匹配正则
                "updatetime": "2022-08-24 13:46:12",    // 规则更新时间
                "white": true,                          // 规则是否为白名单
                "host": "localhost"                     // 规则生效的域名
            }
        ],
    },
}
```

## WAF-请求头规则配置获取

请求地址 : `/tlops/waf/header/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_waf_header_open": true,                 // 当前策略是否开启
        "tl_ops_waf_header_scope": "global",            // 当前策略作用域
        "tl_ops_waf_header_list": [                     // 规则列表key
            {
                "id": "994878242991521808",             // 规则id
                "service": "test",                      // 规则生效的服务
                "node": 0,                              // 规则生效服务的节点索引
                "value": "select.+(from|limit)",        // 规则匹配正则
                "updatetime": "2022-08-24 13:46:12",    // 规则更新时间
                "white": true,                          // 规则是否为白名单
                "host": "localhost",                    // 规则生效的域名
                "keys": [                               // 请求头匹配的key列表
                    "Accept",
                    "Accept-Encoding",
                    "Host",
                    "Referer",
                    "User-Agent"
                ],
            }
        ],
    },
}
```

## WAF-请求参数规则配置获取

请求地址 : `/tlops/waf/param/list`

请求方法 : `GET/POST`

```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "tl_ops_waf_param_open": true,                  // 当前策略是否开启
        "tl_ops_waf_param_scope": "global",             // 当前策略作用域
        "tl_ops_waf_param_list": [                      // 规则列表key
            {
                "id": "994877491502268432",             // 规则id
                "service": "test",                      // 规则生效的服务
                "node": 0,                              // 规则生效服务的节点索引
                "value": "select.+(from|limit)",        // 规则匹配正则
                "updatetime": "2022-08-24 13:46:12",    // 规则更新时间
                "white": true,                          // 规则是否为白名单
                "host": "localhost",                    // 规则生效的域名
            }
        ],
    },
}
```