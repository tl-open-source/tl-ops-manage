<div align=center><img src="https://qnproxy.iamtsm.cn/logo.png"/></div>

[![](https://img.shields.io/badge/base-openresty-blue?style=flat-square)](https://openresty.org/cn/) ![Build](https://img.shields.io/badge/build-passing-green?style=flat-square) ![Version](https://img.shields.io/github/v/tag/iamtsm/tl-ops-manage?color=green&label=Version&style=flat-square) ![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square)

API gateway based on openresty, supports load balancing, registration discovery, health check, service fuse, service current limit, waf filtering, black and white list, dynamic configuration, data statistics, data display

---

Experience demo : https://tlops.iamtsm.cn/tlopsmanage/tl_ops_web_index.html

QQ : 624214498, welcome to submit PR, we will continue to update ....


<a href="https://github.com/iamtsm/tl-ops-manage/blob/main/README.md"> 中文翻译 </a>


# Documentation

[tl-ops-manage detailed documentation](https://book.iamtsm.cn)


# Features

- [x] Support API rule load

- [x] Support cookie payload

- [x] Support header payload

- [x] Support request parameter payload

- [x] Support domain name routing payload

- [x] Support bulk routing strategy

- [x] Support dynamic routing strategy

- [x] Support routing configuration management


- [x] Support service health check

- [x] Support custom return code

- [x] Support pausing health check

- [x] Support for adjusting health status


- [x] Support service fuse current limiting

- [x] Support token bucket current limiter

- [x] Support token bucket warm-up

- [x] support leaky bucket restrictor

- [x] Support for dynamically changing current limiter

- [x] Support current limiter configuration management

- [x] Support circuit breaker policy adjustment



- [x] Support configuration data persistence

- [x] Support dynamic node expansion

- [x] Support dynamic incremental configuration

- [x] Support management interface

- [x] Support real-time service monitoring

- [x] Support multi-level log generation



- [x] Support custom WAF policy

- [x] Support cc prevention rules

- [x] Support IP black and white list rules

- [x] Support Url black and white list rules

- [x] Support Cookie black and white list rules

- [x] Support Header black and white list rules

- [x] Support request parameter black and white list rules



- [ ] Support configuring grayscale publishing

- [ ] Support permission identity control

- [ ] Support the introduction of plug-in secondary development

- [x] Support version iteration data synchronization

- [ ] Support cluster deployment data synchronization
 
- [ ] Support docker one-click deployment

- [ ] Support multi-language management interface



- [ ] Support health check log analysis

- [ ] Supports circuit breaker current limiting log analysis

- [ ] Support routing load log analysis

# Change log

- [x] [CHNAGE-LOG](change.md)


# Thanks

#### [openresty](https://github.com/openresty/openresty)

#### [layui](https://github.com/layui/layui)

#### [iredis](https://github.com/membphis/lua-resty-iredis)

#### [snowflake](https://github.com/yunfengmeng/lua-resty-snowflake)

#### [echarts](https://github.com/apache/echarts)


# License

#### Apache License 2.0