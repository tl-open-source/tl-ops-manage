
# 熔断限流

熔断限流，其实是自动化熔断，限流两种配置的组合。对于服务自动化熔断来说，其应该是根据节点 ‘状态’ 来进行一种服务降级的手段。在节点负载过高时，应该对节点减少流量的进入，在服务性能较优时，增加流量的进入，而控制流量的进入就需要用到一些流控手段。所以我将其组合来配置


## 在文件中配置

`熔断配置`

```lua
options = {
	{
		service_name = "测试服务1",	   -- 该配置所属服务
		interval = 10 * 1000,         -- 检测时间间隔 单位/ms
		node_threshold = 0.3,         -- 切换状态阈值 （node失败占比）
		service_threshold = 0.5,      -- 切换状态阈值 （service切换阈值，取决于node失败状态占比）
		recover = 15 * 1000,          -- 全熔断恢复时间 单位/ms
		depend = depend.token,        -- 默认依赖组件 ：token_bucket
		level = level.service,        -- 默认组件级别，服务层级 [限流熔断针对的层级]
		mode = mode.balance_fail,     -- 默认策略 ：节点路由失败率
	},
	....
},

-- 依赖限流组件
local depend = {
	token = "token",
	leak = "leak"
}

-- 组件级别
local level = {
    service = "service"
}

-- 熔断策略
local mode = {
    balance_fail = "balance_fail",      -- 节点路由失败率
    health_state = "health_state"       -- 节点健康状态
}
```

`令牌桶限流配置`

```lua

-- 限流配置
options = {
	service_name = "测试服务1",        -- 令牌桶配置所属服务 
	capacity = 10 * 1024 * 1024,      -- 最大容量 10M (按字节为单位，可做字节整型流控)
	rate = 1024,                      -- 令牌生成速率/秒 (每秒 1KB)
	warm = 100 * 1024,                -- 预热令牌数量 (预热100KB)
	block = 1024,                     -- 流控以1024为单位
	expand = 0.5,                     -- 扩容比例
	shrink = 0.5,                     -- 缩容比例
}

```


`漏桶限流配置`

```lua

-- 限流配置
options = {
	service_name = "测试服务1",        -- 漏桶配置所属服务 
	capacity = 10 * 1024 * 1024,      -- 最大容量 10M (按字节为单位，可做字节整型流控)
	rate = 1024 * 10,                 -- 漏桶流速/秒 (每秒 10KB)
	block = 1024,                     -- 流控以1024为单位
	expand = 0.5,                     -- 扩容比例
	shrink = 0.5,                     -- 缩容比例
}

```


## 在管理台配置

`熔断配置`

 ![图片](https://qnproxy.iamtsm.cn/16566605539833.png "图片") 

`限流配置`

 ![图片](https://qnproxy.iamtsm.cn/16566606262260.png "图片") 

