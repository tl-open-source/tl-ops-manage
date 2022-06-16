# tl-ops-manage (tl openresty lua service manage)

# Service management framework based on openresty

[![](https://img.shields.io/badge/base-openresty-blue)](https://openresty.org/cn/)
[![](https://img.shields.io/badge/webmanage-red)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/healthcheck-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-health.md)
[![](https://img.shields.io/badge/balance-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/limitfuse-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/dynamic%20conf-green)](https://github.com/iamtsm/tl-ops-manage)



Experience demo : https://tlops.iamtsm.cn/tlops/tl_ops_web_index.html


**QQ : 624214498, welcome to submit PR, we will continue to update ....**


<p align="center"> <a href="https://github.com/iamtsm/tl-ops-manage/blob/main/doc/README_EN.md"> EN </a> | <a href="https:// github.com/iamtsm/tl-ops-manage#readme"> ZN </a> </p>  


| Web | Manage | UI | Preview |
|:-------------:|:-------:|:-------:|:-------:|
| ![console_balance](console_balance.png "console_balance") | ![console_health](console_health.png "console_health") | ![console_fuse](console_fuse.png "console_fuse") |![service](service.png "service")
|![service_node](service_node.png "service_node") |![balance_api](balance_api.png "balance_api")| ![balance_cookie](balance_cookie.png "balance_cookie") | ![balance_header](balance_header.png "balance_header")
|![balance_param](balance_param.png "balance_param")|![fuse](fuse.png "fuse")|![fuse_limit_token](fuse_limit_token.png "fuse_limit_token")|![fuse_limit_leak](fuse_limit_leak.png "fuse_limit_leak")
|![health](health.png "health")|![store](store.png "store")|![store_view](store_view.png "store_view")


# Features


- [x] Support API rule load

- [x] support cookie payload

- [x] support header payload

- [x] support request parameter payload

- [x] support domain name routing payload

- [x] Support bulk routing strategy

- [x] Support dynamic routing strategy

- [x] Support routing configuration management


- [x] Support service health check

- [x] Support custom return code

- [x] support pausing health check

- [x] Support for adjusting health status


- [x] Support service fuse current limiting

- [x] support token bucket current limiter

- [x] Support token bucket warm-up

- [x] support leaky bucket restrictor

- [x] Support for dynamically changing current limiter

- [x] Support current limiter configuration management


- [x] support configuration data persistence

- [x] support dynamic node expansion

- [x] support dynamic incremental configuration

- [x] Support management interface

- [x] Support real-time service monitoring

- [x] Support multi-level log generation

- [ ] Support docker installation configuration

- [ ] Support for deployment scripts

- [ ] Support health check node log analysis

- [ ] Supports log analysis of fuse current-limiting nodes

- [ ] Support routing load node log analysis




# How to use

## 1. Installation environment

install openresty

## 2. Modify the configuration

- Copy the following two lines into nginx.conf into the http block

    ````
    http {
        ...
        # Import tl_ops_manage.conf
        include "/path/to/tl-ops-manage/conf/*.conf;

        # import lua package
        lua_package_path "/path/to/tl-ops-manage/?.lua;;"
        ...
    }
    ````

- Modify the path in the /path/to/tl-ops-manage/conf/tl_ops_manage.conf file

- Modify the path in the /path/to/tl-ops-manage/constant/tl_ops_manage_env.lua file

- Since redis is enabled by default, you need to install redis. If you don't want to use redis, you can set the redis option to false in tl_ops_manage_env.lua


## 3. Start nginx/openresty

http://localhost/tlops/tl_ops_web_index.html management background

If it is the first time to start, first visit `http://127.0.0.1/tlops/reset` to initialize the project



# Documentation

- [x] [Detailed instruction document](https://blog.iamtsm.cn/detail.html?id=90)

- [x] [Source code implementation documentation](https://blog.iamtsm.cn/detail.html?id=91)

- [x] [Brief documentation of routing module](doc/tl-ops-balance.md)

- [x] [Brief Documentation of Health Check Module](doc/tl-ops-health.md)

- [x] [Brief Documentation of Fusing Current Limiting Module](doc/tl-ops-limit.md)

- [x] [Data Module Brief Documentation](doc/tl-ops-store.md)


# Change log

- [x] [CHNAGE-LOG](doc/change.md)


# Thanks

#### [openresty](https://github.com/openresty/openresty)

#### [layui](https://github.com/layui/layui)

#### [iredis](https://github.com/membphis/lua-resty-iredis)

#### [snowflake](https://github.com/yunfengmeng/lua-resty-snowflake)

#### [echarts](https://github.com/apache/echarts)


# License

#### Apache License 2.0