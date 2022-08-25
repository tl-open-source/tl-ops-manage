# 负载均衡

在负载逻辑执行中，可能会存在限流，节点下线，负载失败等情况，对此，需要返回错误码，balance模块提供了自定义的错误码和错误内容。

    注 : 错误内容是后期版本才支持，早期版本只支持错误码自定义


## 在文件中的配置

```lua
service_empty = {   -- 路由服务空错误定制
    code = 503,
    content_type = "text/html",
    content = "<p> service_empty err </p>"
},
mode_empty = {   -- 路由匹配空错误码
    code = 503,
    content_type = "text/html",
    content = "<p> mode_empty err </p>"
},
host_empty = {   -- 路由域名空错误码
    code = 503,
    content_type = "text/html",
    content = "<p> host_empty err </p>"
},
host_pass = {   -- 路由服务不匹配错误码
    code = 503,
    content_type = "text/html",
    content = "<p> host_pass err </p>"
},
token_limit = {   -- 路由令牌桶限流错误码
    code = 503,
    content_type = "text/html",
    content = "<p> token_limit err </p>"
},
leak_limit = {   -- 路由漏桶限流错误码
    code = 503,
    content_type = "text/html",
    content = "<p> leak_limit err </p>"
},
offline = {   -- 路由服务下线错误码
    code = 503,
    content_type = "text/html",
    content = "<p> offline err </p>"
},
```

## 在管理台的配置

 ![图片](https://qnproxy.iamtsm.cn/企业微信截图_16596930546451.png "图片") 


