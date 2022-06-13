# tl-ops-manage (tl openresty lua manage)

# 基于openresty的服务管理框架


[![](https://img.shields.io/badge/base-openresty-blue)](https://openresty.org/cn/)
[![](https://img.shields.io/badge/webmanage-red)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/healthcheck-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-health.md)
[![](https://img.shields.io/badge/balance-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/limitfuse-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/dynamic%20conf-green)](https://github.com/iamtsm/tl-ops-manage)



体验demo : https://tlops.iamtsm.cn/tlops/tl_ops_web_index.html

**欢迎有兴趣的童鞋提交RP, 持续更新中 ....**

**喜欢的大佬点个start支持下**

**qq交流群 : 624214498**


[EN DOC](doc/README_EN.md) 



| Web | Manage  | UI  | Preview  |
|:-------------:|:-------:|:-------:|:-------:|
| ![console_balance](doc/console_balance.png "console_balance") | ![console_health](doc/console_health.png "console_health") | ![console_fuse](doc/console_fuse.png "console_fuse") |![service](doc/service.png "service")
|![service_node](doc/service_node.png "service_node") |![balance_api](doc/balance_api.png "balance_api")| ![balance_cookie](doc/balance_cookie.png "balance_cookie") | ![balance_header](doc/balance_header.png "balance_header") 
|![balance_param](doc/balance_param.png "balance_param")|![fuse](doc/fuse.png "fuse")|![fuse_limit_token](doc/fuse_limit_token.png "fuse_limit_token")|![fuse_limit_leak](doc/fuse_limit_leak.png "fuse_limit_leak")
|![health](doc/health.png "health")|![store](doc/store.png "store")|![store_view](doc/store_view.png "store_view")


# 特性


- [x] 支持API规则负载

- [x] 支持cookie负载

- [x] 支持header负载

- [x] 支持请求参数负载

- [x] 支持域名路由负载

- [x] 支持服务健康检查

- [x] 支持服务限流熔断

- [x] 支持配置数据持久

- [x] 支持管理操作界面

- [x] 支持动态增量配置

- [x] 支持动态节点扩展

- [x] 支持令牌桶流控

- [x] 支持变更路由策略

- [x] 支持自定义回包码

- [x] 支持实时服务监控

- [x] 支持暂停健康检查

- [x] 支持调整健康状态

- [x] 支持漏桶流控选项

- [x] 支持令牌桶配置管理

- [x] 支持令牌桶预热配置

- [ ] 支持负载配置管理

- [ ] 支持服务灰度标签

- [ ] 支持配置发布回滚

- [ ] 支持服务告警通知

- [ ] 支持移除服务节点

- [ ] 支持健康检查历史数据统计

- [ ] 支持查看健康检查节点日志

- [ ] 支持查看熔断限流节点日志

- [ ] 支持查看路由负载节点日志


# 使用方式

## 1. 安装环境

安装openresty

## 2. 修改配置

- 复制以下两行到nginx.conf到http块中

    ````
    http {
        ...
        # 引入tl_ops_manage.conf
        include "/path/to/tl-ops-manage/conf/*.conf;

        # 引入lua包
        lua_package_path "/path/to/tl-ops-manage/?.lua;;"
        ...
        
    }
    ````

- 修改/path/to/tl-ops-manage/conf/tl_ops_manage.conf文件中的路径

- 修改/path/to/tl-ops-manage/constant/tl_ops_manage_env.lua文件中的路径

- 由于默认启用redis，所以需要安装redis，如果不想使用redis，可以在tl_ops_manage_env.lua中将redis选项置为false


## 3. 启动nginx/openresty

http://localhost/tlops/tl_ops_web_index.html  管理后台

如果是首次启动，先访问 `http://127.0.0.1/tlops/reset` 初始化项目



# 说明文档

- [x] [详细使用说明文档](https://blog.iamtsm.cn/detail.html?id=90)

- [x] [源码实现说明文档](https://blog.iamtsm.cn/detail.html?id=91)

- [x] [路由模块简要文档](doc/tl-ops-balance.md)

- [x] [健康检查模块简要文档](doc/tl-ops-health.md)

- [x] [熔断限流模块简要文档](doc/tl-ops-limit.md)

- [x] [数据模块简要文档](doc/tl-ops-store.md)


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