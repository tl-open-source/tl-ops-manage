      __  .__                                                                                       
    _/  |_|  |             ____ ______  ______           _____ _____    ____ _____     ____   ____  
    \   __\  |    ______  /  _ \\____ \/  ___/  ______  /     \\__  \  /    \\__  \   / ___\_/ __ \ 
    |  | |  |__  /_____/ (  <_> )  |_> >___ \  /_____/ |  Y Y  \/ __ \|   |  \/ __ \_/ /_/  >  ___/ 
    |__| |____/           \____/|   __/____  >         |__|_|  (____  /___|  (____  /\___  / \___  >
                                |__|       \/                \/     \/     \/     \//_____/      \/ 
# Service management framework based on openresty （API Gateway）

[![](https://img.shields.io/badge/base-openresty-blue)](https://openresty.org/cn/)
[![](https://img.shields.io/badge/webmanage-red)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/healthcheck-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-health.md)
[![](https://img.shields.io/badge/balance-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/limitfuse-red)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/dynamic%20conf-green)](https://github.com/iamtsm/tl-ops-manage)


Experience demo : https://tlops.iamtsm.cn/tlopsmanage/tl_ops_web_index.html


**QQ : 624214498, welcome to submit PR, we will continue to update ....**


<a href="https://github.com/iamtsm/tl-ops-manage/blob/main/README.md"> 中文翻译 </a>

# Performance stress test

### Version : openresty-1.19.3.1

### Machine: Tencent Cloud 2 core 4g

 ![Picture](https://qnproxy.iamtsm.cn/16559798756003.png "Picture")


### For normal pressure test results, execute the pressure test command: `ab -n 10000 -c 50 http://127.0.0.1/` , a single request takes about 3.7ms

 ![Picture](https://qnproxy.iamtsm.cn/16559785692014.png "Picture")


### After enabling the tl-ops-manage gateway [health check, routing statistics, fuse current limiting, load balancing], execute the stress test command: `ab -n 10000 -c 50 http://127.0.0.1/` , single The request takes about 4.6ms

 ![Picture](https://qnproxy.iamtsm.cn/16559817202461.png "Picture")



# Documentation

- [x] [tl-ops-manage detailed documentation](https://book.iamtsm.cn)

- [x] [Brief documentation of routing module](tl-ops-balance.md)

- [x] [Brief Documentation of Health Check Module](tl-ops-health.md)

- [x] [Brief Documentation of Fusing Current Limiting Module](tl-ops-limit.md)

- [x] [Data Module Brief Documentation](tl-ops-store.md)


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