# WAF过滤

在waf过滤执行中，可能会命中waf规则的情况，对此，需要返回特定的错误码和内容，waf模块提供了自定义的错误码和自定义内容功能，对应说明如下

        注 : 错误内容是后期版本才支持，早期版本只支持错误码自定义

## 在文件中的配置

```lua
waf_ip = {   -- waf拦截ip返回错误码
    code = 503,
    content_type = "text/html",
    content = "<p> waf_ip err </p>"
},
waf_api = {   -- waf拦截api返回错误码
    code = 503,
    content_type = "text/html",
    content = "<p> waf_api err </p>"
},
waf_cc = {   -- waf拦截cc返回错误码
    code = 503,
    content_type = "text/html",
    content = "<p> waf_cc err </p>"
},
waf_header = {   -- waf拦截header返回错误码
    code = 503,
    content_type = "text/html",
    content = "<p> waf_header err </p>"
},
waf_cookie = {   -- waf拦截cookie返回错误码
    code = 503,
    content_type = "text/html",
    content = "<p> waf_cookie err </p>"
},
waf_param = {   -- waf拦截args返回错误码
    code = 503,
    content_type = "text/html",
    content = "<p> waf_param err </p>"
}
```

## 在管理台的配置

 ![图片](https://qnproxy.iamtsm.cn/43ac559ebec4fc516de99d8de9efd10.png "图片") 