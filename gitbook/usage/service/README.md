
# 服务节点

服务节点是基础配置，添加好的节点会被用于健康检查，节点限流，熔断降级，路由统计，负载均衡等模块。节点的基础数据可以在文件中设置好，或也可以在管理后台中设置。

## 在文件中配置

配置节点数据对应的文件在 `constant/tl_ops_constant_service.lua`，在文件中，我提供了demo示例数据，只需要按照对应的格式放入 `list` 中即可，需要配置多少个，放置多少个即刻。


```lua
list = {
	{
		id = 1,
		name = "节点1",                      -- 当前节点name
		service = "测试服务",                -- 当前节点所属service
		protocol = "http://",               -- 当前节点协议头
		ip = "127.0.0.1",                   -- 当前节点ip
		port = 6666,                        -- 当前节点port
	},
	{
		id = 2,
		name = "节点2",
		service = "测试服务",
		protocol = "http://",
		ip = "127.0.0.1",
		port = 6667,
	}
	....
}
```


## 在管理台配置

 ![图片](https://qnproxy.iamtsm.cn/9b0d2c2818f43a8f67698c69d052afe.png "图片") 

 ![图片](https://qnproxy.iamtsm.cn/99e05a5306e0ce6ad3ff5c0c8e27306.png "图片") 


