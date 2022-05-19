# tl-ops-manage (tl openresty lua manage)

[![](https://img.shields.io/badge/base-openresty-blue)](https://openresty.org/cn/)
[![](https://img.shields.io/badge/webmanage-red)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/healthcheck-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-health.md)
[![](https://img.shields.io/badge/balance-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/limitfuse-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/dynamic%20conf-green)](https://github.com/iamtsm/tl-ops-manage)


[EN DOC](doc/README_EN.md) 

# 基于openresty的轻量级服务管理功能集合实现

![image](doc/balance_console.png)

![image](doc/health_console.png)

![image](doc/limit_console.png)

## 规划/进度

- [x] 路由策略 
- [x] 健康检查
- [x] 限流熔断
- [x] 动态配置
- [x] 节点扩展
- [x] 数据持久
- [x] 管理界面
- [x] 数据管理

#### 路由策略 ： 
    自定义路由策略，资源路由策略，随机路由策略，路由统计。

#### 健康检查 ： 
    服务节点健康检查自动化，动态新增修改配置。

#### 限流熔断 ：
    限流熔断策略自动化，动态新增修改配置。

#### 动态服务 ：
    动态扩充服务节点。

#### 数据持久化 ：
    配置策略持久化，操作记录可朔源，支持多级缓存。

##### 持续更新中 ...


---------

## 使用方式

### 1. 安装环境

    安装openresty，安装redis

### 2. 修改nginx.conf引入本项目lua包

    lua_package_path "/xxx/tl-ops-manage/?.lua;;"

### 3. 修改nginx.conf引入/conf/tl_ops_manage.conf

    1. include "/xxx/tl-ops-manage/conf/*.conf;"

    2. 修改tl_ops_manage.conf中的路径

### 4. 修改/constant/下配置

    tl_ops_constant_log.lua 修改dir路径

### 5. 启动nginx/openresty，如果是首次启动，先访问 `http://127.0.0.1/tlops/reset` 初始化项目

    http://localhost/tlops/tl_ops_web_index.html  管理后台

---------


## 说明文档

- [x] [详细使用说明文档](https://blog.iamtsm.cn/detail.html?id=90)

- [x] [路由模块](doc/tl-ops-balance.md)

- [x] [健康检查模块](doc/tl-ops-health.md)

- [x] [熔断限流模块](doc/tl-ops-limit.md)

- [x] [数据模块](doc/tl-ops-store.md)


## 目录结构

    |-- .gitignore
    |-- LICENSE
    |-- README.md
    |-- api
    |   |-- tl_ops_api_get_api.lua
    |   |-- tl_ops_api_get_health.lua
    |   |-- tl_ops_api_get_limit.lua
    |   |-- tl_ops_api_get_service.lua
    |   |-- tl_ops_api_get_state.lua
    |   |-- tl_ops_api_get_store.lua
    |   |-- tl_ops_api_reset_all.lua
    |   |-- tl_ops_api_set_api.lua
    |   |-- tl_ops_api_set_health.lua
    |   |-- tl_ops_api_set_limit.lua
    |   |-- tl_ops_api_set_service.lua
    |-- balance
    |   |-- tl_ops_balance.lua
    |   |-- tl_ops_balance_core.lua
    |   |-- tl_ops_balance_count.lua
    |   |-- tl_ops_balance_count_core.lua
    |-- cache
    |   |-- tl_ops_cache.lua
    |   |-- tl_ops_cache_dict.lua
    |   |-- tl_ops_cache_redis.lua
    |   |-- tl_ops_cache_store.lua
    |-- conf
    |   |-- tl_ops_manage.conf
    |-- constant
    |   |-- tl_ops_constant_api.lua
    |   |-- tl_ops_constant_balance.lua
    |   |-- tl_ops_constant_comm.lua
    |   |-- tl_ops_constant_health.lua
    |   |-- tl_ops_constant_limit.lua
    |   |-- tl_ops_constant_log.lua
    |   |-- tl_ops_constant_service.lua
    |-- doc
    |   |-- README_EN.md
    |   |-- tl-ops-balance.md
    |   |-- tl-ops-health.md
    |   |-- tl-ops-limit.md
    |   |-- tl-ops-manage.png
    |   |-- tl-ops-store.md
    |-- health
    |   |-- tl_ops_health.lua
    |   |-- tl_ops_health_check.lua
    |   |-- tl_ops_health_check_dynamic_conf.lua
    |   |-- tl_ops_health_check_version.lua
    |-- lib
    |   |-- iredis.lua
    |   |-- lock.lua
    |   |-- snowflake.lua
    |-- limit
    |   |-- tl_ops_limit_leak_bucket.lua
    |   |-- tl_ops_limit_sliding_window.lua
    |   |-- tl_ops_limit_token_bucket.lua
    |   |-- tl_ops_limit_warm.lua
    |   |-- fuse
    |       |-- tl_ops_limit_fuse.lua
    |       |-- tl_ops_limit_fuse_check.lua
    |       |-- tl_ops_limit_fuse_check_dynamic_conf.lua
    |       |-- tl_ops_limit_fuse_check_version.lua
    |       |-- tl_ops_limit_fuse_token_bucket.lua
    |-- store
    |   |-- example
    |   |-- tl-ops-api.tlindex
    |   |-- tl-ops-api.tlstore
    |   |-- tl-ops-balance-count-300.tlindex
    |   |-- tl-ops-balance-count-300.tlstore
    |   |-- tl-ops-health.tlindex
    |   |-- tl-ops-health.tlstore
    |   |-- tl-ops-limit.tlindex
    |   |-- tl-ops-limit.tlstore
    |   |-- tl-ops-service.tlindex
    |   |-- tl-ops-service.tlstore
    |-- utils
    |   |-- tl_ops_utils_func.lua
    |   |-- tl_ops_utils_log.lua
    |   |-- tl_ops_utils_store.lua
    |-- web
        |-- tl_ops_web_comm.js
        |-- tl_ops_web_index.html
        |-- balance
        |   |-- tl_ops_web_api.html
        |   |-- tl_ops_web_api.js
        |   |-- tl_ops_web_api_form.html
        |   |-- tl_ops_web_api_form.js
        |-- console
        |   |-- tl_ops_web_console.html
        |   |-- tl_ops_web_console.js
        |-- health
        |   |-- tl_ops_web_health.html
        |   |-- tl_ops_web_health.js
        |   |-- tl_ops_web_health_form.html
        |-- lib
        |   |-- axios.js
        |   |-- echarts.min.js
        |-- limit
        |   |-- tl_ops_web_limit.html
        |   |-- tl_ops_web_limit.js
        |   |-- tl_ops_web_limit_form.html
        |-- service
        |   |-- tl_ops_web_service.html
        |   |-- tl_ops_web_service.js
        |   |-- tl_ops_web_service_form.html
        |   |-- tl_ops_web_service_node.html
        |   |-- tl_ops_web_service_node.js
        |   |-- tl_ops_web_service_node_form.html
        |-- store
            |-- tl_ops_web_store.html
            |-- tl_ops_web_store.js
            |-- tl_ops_web_store_view.html


## 引用致谢

### [openresty](https://github.com/openresty/openresty)

### [layui](https://github.com/layui/layui)

### [iredis](https://github.com/membphis/lua-resty-iredis)

### [snowflake](https://github.com/yunfengmeng/lua-resty-snowflake)

### [echarts](https://github.com/apache/echarts)

## License

### Apache License 2.0