# tl-ops-balance (tl openresty lua balance)


# 基于openresty的轻量级负载均衡策略实现


优点 : 轻量化，插件式，易扩展，支持可视化操作，记录朔源。

## 规划/进度
- [x] 负载策略 
- [x] 数据持久化
- [x] 健康检查
- [ ] 限流熔断
- [ ] 灰度发布
- [ ] Web管理界面

#### 负载策略 ： 
    自定义url负载策略，资源负载策略，随机负载策略。

#### 数据持久化 ：
    配置策略持久化，操作记录可朔源，支持多级缓存。

#### 健康检查 ： 
    服务节点健康检查自动化，可配置。

#### 限流熔断 ：
    限流熔断策略自动化，可配置。

#### 灰度发布 ：
    api，功能灰度策略发布，可配置。

##### 持续更新中 ...


---------

## 使用方式

### 1. 安装openresty环境

    官网安装openresty

### 2. 修改nginx.conf引入本项目lua包

    lua_package_path "/xxx/tl-ops-balance/?.lua;;"

### 3. 修改nginx.conf引入/conf/tl_ops_balance.conf

    include "/xxx/tl-ops-balance/conf/*.conf;"

    修改tl_ops_balance.conf中的路径

### 4. 修改/constant/下配置

    tl_ops_constant_log.lua 修改dir路径

### 5. 启动nginx/openresty

---------

## 目录结构

    |-- tl-ops-balance
        |-- .gitignore
        |-- LICENSE
        |-- README.md
        |-- api                                     #rest接口
        |   |-- tl_ops_api_get_api.lua                  #获取当前已有api负载配置
        |   |-- tl_ops_api_get_health_state.lua         #获取当前健康检查实时状态
        |   |-- tl_ops_api_get_service.lua              #获取当前已有service节点配置
        |   |-- tl_ops_api_reset_all.lua                #根据配置文件中的配置重置所有已有配置
        |   |-- tl_ops_api_set_api.lua                  #更新当前已有api负载配置
        |   |-- tl_ops_api_set_service.lua              #更新当前已有service节点配置
        |-- cache                                   #多级缓存
        |   |-- tl_ops_cache.lua                        #多级缓存对外工具
        |   |-- tl_ops_cache_dict.lua                   #一级缓存
        |   |-- tl_ops_cache_redis.lua                  #二级缓存
        |   |-- tl_ops_cache_store.lua                  #三级缓存
        |-- conf                                    #配置
        |   |-- tl_ops_balance.conf                     #默认提供nginx conf配置
        |-- constant                                #初始化配置，项目配置
        |   |-- tl_ops_constant_api.lua                 #url负载默认配置
        |   |-- tl_ops_constant_balance.lua             #负载均衡功能配置
        |   |-- tl_ops_constant_comm.lua                #公共静态属性
        |   |-- tl_ops_constant_health.lua              #健康检查功能配置
        |   |-- tl_ops_constant_log.lua                 #日志配置
        |   |-- tl_ops_constant_service.lua             #服务节点负载默认配置
        |-- health                                  #健康检查实现
        |   |-- tl_ops_health.lua                       #健康检查功能主体实现
        |   |-- tl_ops_health_check.lua                 #健康检查功能调用
        |-- lib                                     #依赖
        |   |-- iredis.lua                              #redis连接依赖
        |-- store                                   #三级缓存数据存放目录
        |   |-- example
        |-- utils                                   #工具
            |-- tl_ops_utils_func.lua                   #项目方法封装
            |-- tl_ops_utils_log.lua                    #自定义日志实现
            |-- tl_ops_utils_store.lua                  #简易三级缓存实现


