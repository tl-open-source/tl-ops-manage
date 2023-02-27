
# 负载均衡模式

在v3.0.1版本后才支持，最初在设计上没有考虑到这一点，后面有同学反馈了这一个场景后便补充了这个功能

 ![图片](https://qnproxy.iamtsm.cn/WechatIMG22.png "图片") 

 ![图片](https://qnproxy.iamtsm.cn/WechatIMG23.png "图片") 

这个功能可以支持到根据设置的负载模式，来决定在规则匹配前进行模式选择，目前有两种模式，项目默认选用host，这个设置是对全负载策略生效，不进行区分

host: 优先匹配host，再匹配不同策略下的规则
api : 优先匹配规则，再从匹配的规则中进行host匹配

# 负载均衡策略

对于负载均衡，目前分为五个负载策略，在负载时，会按照这个顺序进行负载，而每个策略分为两种模式 指定路由，随机路由。

	URL负载  >  请求参数负载  >  请求COOKIE负载  >  请求头负载  >  请求Body负载

## 指定路由

一旦请求命中模式中的任意一条规则，即会路由到具体节点。

## 随机路由

一旦请求命中模式中的任意一条规则，不会路由到具体节点，而是在命中的服务中随机选取一个节点进行路由。

对于模式的不同，每个随机方式也是不相同，对于 `URL随机负载` 随机模式是根据当前请求url的长度设置随机种子，得到随机数进行随机负载。

对于 `请求参数`，`请求COOKIE`，`请求HEADER` 的随机负载，是根据当前命中的key的长度设置随机种子，得到随机数进行随机负载。


## 正则匹配自定义

API策略和Body策略，是支持每条规则自定义正则匹配模式的，目前支持一下几种。其他几种策略暂不支持

```lua
tl_ops_match_mode = {-- api匹配模式
	-- 精准匹配模式
	all = "all",
	-- 正则匹配
	reg = "jo",
	-- 正则忽略大小写
	regi = "joi",
	-- 最长字符串匹配
	regid = "joid"
}
```

## 在文件中的配置

在文件中的配置需注意的是，如果`sync`插件为开启状态时，会有后台任务同步文件中的配置数据至store中，且是根据 `id` 来判定是否需要执行同步逻辑。所以需要保证文件中的配置的数据的id是具有唯一性的标识字段。

当然，此字段如果为关闭状态，静态规则将不会同步至store中，规则也就不会生效，


`API策略`

```lua
point = {
	 {
		id = 1,
		url = "/*",                             -- 当前url匹配规则
		match_mode = match_mode.reg,            -- 正则匹配模式
		service = "tlops-demo",                 -- 当前url路由到的service
		node = 0,                               -- 当前url路由到的service下的node的索引
		host = "tlops1.com",                    -- 当前url处理的域名范围
		rewrite_url = "",                       -- 当前url重写后的url
	}
},
random = {
	 {
		id = 1,
		url = "/api",                           -- 当前url匹配规则
		match_mode = match_mode.all,            -- 精准匹配模式
		service = "tlops-demo",                 -- 当前url路由到的service
		host = "tlops1.com",                    -- 当前url处理的域名范围
		rewrite_url = "",                       -- 当前url重写后的url
	}
},
```

`cookie策略`

```lua
point = {
	 {
		id = 1,
		key = "_tl_session_id",             -- 当前cookie匹配名称
		value = {                           -- 当前cookie名称对应值列表  
			"ok","ok1","ok2"
		}, 
		service = "测试服务1",               -- 当前cookie路由到的service
		node = 0,                           -- 当前cookie路由到的service下的node的索引
		host = "tlops1.com",                -- 当前cookie处理的域名范围
	}
},
random = {
	 {
		id = 1,
		key = "_tl_token_id",               -- 当前cookie匹配名称
		value = {                           -- 当前cookie名称对应值列表  
			"ok","ok1","ok2"
		}, 
		service = "测试服务1",               -- 当前cookie路由到的service
		host = "tlops1.com",                -- 当前cookie处理的域名范围
	}
},
```

`参数策略`

```lua
point = {
	 {
		id = 1,
		key = "_tl_id",                     -- 当前请求参数匹配名称
		value = {                           -- 当前请求参数对应值列表  
			"ok","ok1","ok2"
		}, 
		service = "测试服务1",               -- 当前请求参数路由到的service
		node = 0,                           -- 当前请求参数路由到的service下的node的索引
		host = "tlops1.com",                -- 当前请求参数处理的域名范围
	}
},
random = {
	 {
		id = 1,
		key = "_tl_name",                   -- 当前请求参数匹配名称
		value = {                           -- 当前请求参数对应值列表  
			"ok","ok1","ok2"
		}, 
		service = "tlops-demo",             -- 当前请求参数路由到的service
		host = "tlops1.com",                -- 当前请求参数处理的域名范围
	}
},
```

`请求头模式`

```lua
point = {
	 {
		id = 1,
		key = "content-type",               -- 当前请求头匹配名称
		value = {                           -- 当前请求头名称对应值列表  
			"text/fragment+html","text/plain"
		},
		service = "tlops-demo",             -- 当前请求头路由到的service
		node = 0,                           -- 当前请求头路由到的service下的node的索引
		host = "tlops1.com",                -- 当前请求头处理的域名范围
	}
},
random = {
	 {
		id = 1,
		key = "content-type",               -- 当前请求头匹配名称
		value = {                           -- 当前请求头名称对应值列表  
			"text/fragment+html","text/plain"
		},
		service = "tlops-demo",             -- 当前请求头路由到的service
		host = "tlops1.com",                -- 当前请求头处理的域名范围
	}
},
```

`请求body模式`

```lua
point = {
	 {
        id = 1,
		body = "iamtsm",                            -- 当前url匹配规则
		match_mode = match_mode.reg,                -- 正则匹配模式
		service = "tlops-demo",                     -- 当前url路由到的service
		node = 0,                                   -- 当前url路由到的service下的node的索引
		host = "tlops1.com",                        -- 当前url处理的域名范围
	}
},
random = {
	 {
        id = 1,
		body = "iamtsm",                            -- 当前url匹配规则
		match_mode = match_mode.all,                -- 精准匹配模式
		service = "tlops-demo",                     -- 当前url路由到的service
		host = "tlops1.com",                        -- 当前url处理的域名范围
	}
},
```

## 在管理台配置

`URL模式`

 ![图片](https://qnproxy.iamtsm.cn/0c0924652e58ad3458231f6f6e23077.png "图片")

 ![图片](https://qnproxy.iamtsm.cn/dcd18b423a1ceabf739a606e98cdba3.png "图片")

`请求参数模式`

 ![图片](https://qnproxy.iamtsm.cn/487226ec83372ea6215473d14bec78c.png "图片")

 ![图片](https://qnproxy.iamtsm.cn/4401fc73b2bd5899c11db8ef00584b7.png "图片") 

`COOKIE模式`

 ![图片](https://qnproxy.iamtsm.cn/999999c6ec74b79b8feb8de07249532.png "图片")

 ![图片](https://qnproxy.iamtsm.cn/4328406465973182c443572becf58c0.png "图片")

`请求头模式`

 ![图片](https://qnproxy.iamtsm.cn/16566592861425.png "图片") 

 ![图片](https://qnproxy.iamtsm.cn/16566594089138.png "图片") 

 `请求body模式`

 ![图片](https://qnproxy.iamtsm.cn/1833f9aaa2fcc040860207c1391209d.png "图片") 