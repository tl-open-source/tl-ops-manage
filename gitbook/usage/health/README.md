
# 健康检查

健康检查依赖设置好的节点，对节点依次进行发包检查节点状态，在健康检查中，如检查间隔，发包超时时间，周期内请求成功多少次算正常服务状态，周期内请求失败多少次才需要转变服务状态，接收服务回包时什么状态才算成功，等等... ，这些需要数据根据每个服务的不同，可以做到配置化，并实时更新。

## 在文件中配置

配置节点数据对应的文件在 `constant/tl_ops_constant_health.lua`，在文件中，我提供了demo示例数据，只需要按照对应的格式放入 `options` 中即可，需要配置多少个，放置多少个即刻。


```lua
options = {
	{
		check_failed_max_count = 5,         -- 自检周期内失败次数
		check_success_max_count = 2,        -- 自检周期内成功次数
		check_interval = 10 * 1000,         -- 自检服务自检周期 (单位/ms)
		check_timeout = 1000,               -- 自检节点心跳包连接超时时间 (单位/ms)
		check_content = "GET / HTTP/1.0",   -- 自检心跳包内容
		check_success_status = {            -- 自检返回成功状态, 如 201,202（代表成功）
			200
		},
		check_service_name = "测试服务1"	 -- 该配置所属服务
	},
	{
		check_failed_max_count = 5,
		check_success_max_count = 2,
		check_interval = 10 * 1000
		check_timeout = 1000,
		check_content = "GET / HTTP/1.0",
		check_success_status = {
			200
		},
		check_service_name = "测试服务2"
	}
}
```


## 在管理台配置

 ![图片](https://qnproxy.iamtsm.cn/d89dcc56164874f57ea2c2b65e92cec.png "图片")



