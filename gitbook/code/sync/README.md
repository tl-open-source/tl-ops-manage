# 同步器


该插件主要有三个功能，一个是同步数据，一个是同步字段，一个是数据预热


## 数据同步

主要用于同步各个模块的配置数据，因为在tl-ops-manage中配置以store文件的配置为主，配置分为两类，一类是静态配置，一类是动态文件配置，静态配置存放在对应模块的 constant 文件下，动态配置存放在对应模块的 store 文件中。

在使用时可能存在静态配置和动态配置同时存在的情况，此时需要同步静态文件中的数据至store文件中。


## 字段同步


主要用于同步各模块的增量字段


## 数据预热

数据预热主要用于在WAF规则，负载规则的查询情况下，在执行数据同步逻辑时，会将数据先load到shared:dict中，达到全量数据预热的目的


## 外部接口

除了支持项目本身自带的模块的数据同步预热，同时也提供了外部接口，供其他插件数据同步预热，插件只需要在默认的`tl_ops_plugin_core.lua`文件中实现并提供  `sync_data`, `sync_fields` 方法即可。