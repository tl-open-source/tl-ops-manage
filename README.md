# tl-ops-manage

[![](https://img.shields.io/badge/base-openresty-blue)](https://openresty.org/cn/)
[![](https://img.shields.io/badge/dynamic%20conf-support-green)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/webmanage-support-green)](https://github.com/iamtsm/tl-ops-manage)
[![](https://img.shields.io/badge/healthcheck-support-green)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-health.md)
[![](https://img.shields.io/badge/balance-support-green)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)
[![](https://img.shields.io/badge/limitfuse-support-green)](https://github.com/iamtsm/tl-ops-manage/blob/main/doc/tl-ops-balance.md)

# service management based on openresty

tl-ops-manage is positioned for service management


# progress

- [x] router
- [x] health-check
- [x] dynamic-conf
- [x] dynamic-service
- [x] data-persistence
- [x] web-manage
- [x] limit-fuse
- [ ] gray-strategy


## Router

Customize url routing strategy, random routing strategy

- [x] [balance doc](doc/tl-ops-balance.md)

## Health-check

Service node health check is automated and configurable，Support dynamic addition and modification of configuration

- [ ] [health doc](doc/tl-ops-health.md)


## Limit-fuse

Automatic current limiting and fusing strategy, dynamic configuration content

- [ ] [limit doc](doc/tl-ops-limit.md)

## Store

Support data storage, traceability of operation records, and complete logging

- [ ] [store doc](doc/tl-ops-store.md)

## Grey-strategy

Customize grayscale publishing routing rules, according to request parameters grayscale

- [ ] [grey doc](doc/tl-ops-grey.md)


# usage

First you need to install [openresty](https://openresty.org/cn/installation.html)。

then modify nginx.conf to introduce `tl-ops-manage lua package` and `/conf/tl_ops_manage.conf ` of the current project


    http {
        #....

        include "/xxx/tl-ops-manage/conf/*.conf;"

        lua_package_path "/xxx/tl-ops-manage/?.lua;;"
    }

You need to modify the path of the content in the tl_ops_manage.conf to your own path

    #...
    location = /tlops/service/list {
		content_by_lua_file "/ your path /tl-open-source/tl-ops-manage/api/tl_ops_api_get_service.lua";
	}
	location = /tlops/service/set {
		content_by_lua_file "/ your path /tl-open-source/tl-ops-manage/api/tl_ops_api_set_service.lua";
	}
    #...

And you need to modify the path of the content in the tl_ops_constant_log.lua to your own path

    local tl_ops_constant_log = {
        dir = [[/your path/]],
        format_json = true
    }

Finallyinaly start nginx

    http://127.0.0.1/tlops/tl_ops_web_index.html (web manage)



#### More features are in development ..