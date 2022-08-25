# WAF过滤

在tl-ops-manage中，waf过滤支持完整的配置化。且支持多种规则定制过滤，按照如下顺序进行过滤

    ip-waf > api-waf > cc-waf > header-waf > cookie-waf > param-waf

对于每种规则，有更加细化的模式和开关控制，每种规则支持单独的开启关闭开关，支持三种模式 ，`全局过滤` , `服务过滤` , `节点过滤`


## 全局过滤

    全局过滤的执行阶段在负载阶段之前，如果被waf过滤拦截，将不会执行到负载阶段。其规则拦截的是设置的所有服务和节点

## 服务过滤

    服务过滤的执行阶段在负载阶段之中，也就是在命中了对应的服务后，才会执行waf逻辑，其规则拦截的是设置的命中的服务

## 节点过滤

    节点过滤的执行阶段在负载阶段之中，也就是在命中了对应的服务和节点后，才会执行waf逻辑，其规则拦截的是设置的命中的服务下的某个节点


下面将对不同规则的配置进行介绍


## 在文件中的配置

在文件中的配置需注意的是，如果`sync`插件为开启状态时，会有后台任务同步文件中的配置数据至store中，且是根据 `id` 来判定是否需要执行同步逻辑。所以需要保证文件中的配置的数据的id是具有唯一性的标识字段。

当然，此字段如果为关闭状态，静态规则将不会同步至store中，规则也就不会生效，


`IP规则`

```lua
list = {
    {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        value = "127.0.0.1",                -- 当前匹配的规则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        white = true,                       -- 是否为白名单    
    }
}
```

`API规则`

```lua
list = {
    {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        value = ".git",                     -- 当前匹配的规则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        balck = false,                      -- 是否为黑名单
        white = true,                       -- 是否为白名单
    }
}
```


`CC规则`

```lua
list = {
    {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        time = 60,                          -- cc记录过期时间
        count = 100,                        -- time内触发次数
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
    }
}
```


`COOKIE规则`

```lua
list = {
    {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        value = "select.",                  -- 当前匹配的正则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        white = true,                       -- 是否为白名单
    }
}
```

`请求头规则`

```lua
list = {
    {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        keys = {                            -- 拦截的请求头名称列表
            "User-Agent","Accept"
        },      
        value = "Mozilla/5.0",              -- 当前匹配的规则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        white = true,                       -- 是否为白名单
    }
}
```

`请求参数规则`

```lua
list = {
    {
        id = 1,
        host = "tlops.com",                 -- 当前生效的域名
        value = "java.lang",                -- 当前匹配的规则
        service = "tlops-demo",             -- 当前生效的service
        node = 0,                           -- 当前生效的service下的node的索引
        white = true,                       -- 是否为白名单
    }
}
```


## 在管理台配置


`IP规则`

 ![图片](https://qnproxy.iamtsm.cn/16566640259443.png "图片") 

`API规则`

 ![图片](https://qnproxy.iamtsm.cn/16566640627678.png "图片") 

`CC规则`

 ![图片](https://qnproxy.iamtsm.cn/16566639821015.png "图片") 

`COOKIE规则`

 ![图片](https://qnproxy.iamtsm.cn/16566641435253.png "图片") 

`请求头规则`

 ![图片](https://qnproxy.iamtsm.cn/16566642014231.png "图片") 

`请求参数规则`

 ![图片](https://qnproxy.iamtsm.cn/16566641068000.png "图片") 