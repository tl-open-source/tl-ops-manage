# 服务节点

我将服务划分为`服务`与`节点`，节点隶属于服务，是一个上下级关系。用如下配置可以展示他们之间的关系

```lua
product = { ---- 服务
	{ ---- 节点1
		id = snowflake.generate_id( 100 ),  ---- default snow id
		name = "product-node-1",            ---- 当前节点name
		service = "product",                ---- 当前节点所属service
		protocol = "http://",               ---- 当前节点协议头
		ip = "127.0.0.1",                   ---- 当前节点ip
		port = 6666,                        ---- 当前节点port
	},

	{---- 节点2
		id = snowflake.generate_id( 100 ),  ---- default snow id
		name = "product-node-2",            ---- 当前节点name
		service = "product",                ---- 当前节点所属service
		protocol = "http://",               ---- 当前节点协议头
		ip = "127.0.0.1",                   ---- 当前节点ip
		port = 6667,                        ---- 当前节点port
	}
}
```

例如在业务场景中会有产品功能，对于产品功能来说，运行他的应该是有一个或多个机器实例，产品业务对应的就是产品服务，这些机器实例对应的就是产品节点。

对于tl-ops-manage来说，服务-节点是基础，其他的路由，检查等模块都需要依赖服务-节点。所以服务-节点可以理解为公共全局配置，仅有一份，其对应的项目文件在 `constant/tl_ops_constant_service.lua`


