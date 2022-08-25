# tl-ops-manage  [开源API网关]

## 性能压测

###  版本 : openresty-1.19.3.1

###  机器 : 腾讯云2核4g

 ![图片](https://qnproxy.iamtsm.cn/16559798756003.png "图片") 


### 正常压测结果，执行压测命令 : `ab -n 10000 -c 50 http://127.0.0.1/` ， 单个请求耗时约3.7ms

 ![图片](https://qnproxy.iamtsm.cn/16559785692014.png "图片") 


### 开启tl-ops-manage网关后 【健康检查，路由统计，熔断限流，负载均衡】，执行压测命令 : `ab -n 10000 -c 50 http://127.0.0.1/` ，单个请求耗时约4.6ms

 ![图片](https://qnproxy.iamtsm.cn/16559817202461.png "图片") 

