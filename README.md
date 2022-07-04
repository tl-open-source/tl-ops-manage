<div align=center><img src="https://qnproxy.iamtsm.cn/logo.png"/></div>

[![](https://img.shields.io/badge/base-openresty-blue?style=flat-square)](https://openresty.org/cn/) ![Build](https://img.shields.io/badge/build-passing-green?style=flat-square) ![Version](https://img.shields.io/github/v/tag/iamtsm/tl-ops-manage?color=green&label=Version&style=flat-square) ![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square)

基于openresty的API网关，支持负载均衡，注册发现，健康检查，服务熔断，服务限流，waf过滤，黑白名单，动态配置，数据统计，数据展示

---

<a href="https://github.com/iamtsm/tl-ops-manage/blob/main/doc/README_EN.md"> translate EN DOC </a>


体验demo : https://tlops.iamtsm.cn/tlopsmanage/tl_ops_web_index.html


qq交流群 : 624214498，欢迎有兴趣的童鞋提交PR, 持续更新中 ....



# 说明文档

[tl-ops-manage详细文档](https://book.iamtsm.cn)

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

- [x] 支持插件二次开发

- [x] 支持版本迭代数据同步

- [ ] 支持集群部署数据同步
 
- [ ] 支持安装部署脚本

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

#### [cookie](https://github.com/cloudflare/lua-resty-cookie)

#### [snowflake](https://github.com/yunfengmeng/lua-resty-snowflake)

#### [echarts](https://github.com/apache/echarts)


# 开源协议

#### Apache License 2.0