      __  .__                                                                                       
    _/  |_|  |             ____ ______  ______           _____ _____    ____ _____     ____   ____  
    \   __\  |    ______  /  _ \\____ \/  ___/  ______  /     \\__  \  /    \\__  \   / ___\_/ __ \ 
    |  | |  |__  /_____/ (  <_> )  |_> >___ \  /_____/ |  Y Y  \/ __ \|   |  \/ __ \_/ /_/  >  ___/ 
    |__| |____/           \____/|   __/____  >         |__|_|  (____  /___|  (____  /\___  / \___  >
                                |__|       \/                \/     \/     \/     \//_____/      \/ 
[![](https://img.shields.io/badge/base-openresty-blue)](https://openresty.org/cn/)
[![](https://img.shields.io/badge/webmanage-red)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/healthcheck-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-health.md)
[![](https://img.shields.io/badge/balance-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/limitfuse-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/dynamic%20conf-green)](https://github.com/iamtsm/tl-ops-manage)

<a href="https://github.com/iamtsm/tl-ops-manage/blob/main/doc/README_EN.md"> translate EN DOC </a>


体验demo : https://tlops.iamtsm.cn/tlopsmanage/tl_ops_web_index.html


**qq交流群 : 624214498，欢迎有兴趣的童鞋提交PR, 持续更新中 ....**



# 性能压测

###  版本 : openresty-1.19.3.1

###  机器 : 腾讯云2核4g

 ![图片](https://qnproxy.iamtsm.cn/16559798756003.png "图片") 


### 正常压测结果，执行压测命令 : `ab -n 10000 -c 50 http://127.0.0.1/` ， 单个请求耗时约3.7ms

 ![图片](https://qnproxy.iamtsm.cn/16559785692014.png "图片") 


### 开启tl-ops-manage网关后 【健康检查，路由统计，熔断限流，负载均衡】，执行压测命令 : `ab -n 10000 -c 50 http://127.0.0.1/` ，单个请求耗时约4.6ms

 ![图片](https://qnproxy.iamtsm.cn/16559817202461.png "图片") 



# 说明文档

- [x] [tl-ops-manage详细文档-推荐](https://book.iamtsm.cn)

- [x] [路由模块简要文档](doc/tl-ops-balance.md)

- [x] [健康检查模块简要文档](doc/tl-ops-health.md)

- [x] [熔断限流模块简要文档](doc/tl-ops-limit.md)

- [x] [数据模块简要文档](doc/tl-ops-store.md)



# 特性

- [x] 支持API规则负载

- [x] 支持cookie负载

- [x] 支持header负载

- [x] 支持请求参数负载

- [x] 支持域名路由负载

- [x] 支持批量路由策略

- [x] 支持动态路由策略

- [x] 支持路由配置管理


- [x] 支持服务健康检查

- [x] 支持自定义回包码

- [x] 支持暂停健康检查

- [x] 支持调整健康状态


- [x] 支持服务熔断限流

- [x] 支持令牌桶限流器

- [x] 支持令牌桶预热

- [x] 支持漏桶限流器

- [x] 支持动态变更限流器

- [x] 支持限流器配置管理

- [x] 支持熔断策略调整



- [x] 支持配置数据持久

- [x] 支持动态节点扩展

- [x] 支持动态增量配置

- [x] 支持管理操作界面

- [x] 支持实时服务监控

- [x] 支持多级日志生成



- [x] 支持定制WAF策略

- [x] 支持cc防范规则

- [x] 支持Ip黑白名单规则

- [x] 支持Url黑白名单规则

- [x] 支持Cookie黑白名单规则

- [x] 支持Header黑白名单规则

- [x] 支持Args黑白名单规则



- [ ] 支持配置灰度发布

- [ ] 支持权限身份控制

- [ ] 支持引入插件二次开发

- [x] 支持版本迭代数据同步

- [ ] 支持集群部署数据同步
 
- [ ] 支持docker一键部署

- [ ] 支持多语言管理界面



- [ ] 支持健康检查日志分析

- [ ] 支持熔断限流日志分析

- [ ] 支持路由负载日志分析


# 更新日志

- [x] [CHNAGE-LOG](doc/change.md)


# 引用致谢

#### [openresty](https://github.com/openresty/openresty)

#### [layui](https://github.com/layui/layui)

#### [iredis](https://github.com/membphis/lua-resty-iredis)

#### [snowflake](https://github.com/yunfengmeng/lua-resty-snowflake)

#### [echarts](https://github.com/apache/echarts)


# 开源协议

#### Apache License 2.0