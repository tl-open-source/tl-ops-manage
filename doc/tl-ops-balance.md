# tl openresty balance module

### 负载模块主要分为四部分：服务项目，具体节点，负载规则，负载策略

## 1. 服务
	用于不同项目的划分，不同动态服务下都可存在多个动态节点。 结构如下：

```
{
    service_name_1 : nodes,
    service_name_2 : nodes,
    service_name_3 : nodes
}
```

## 2. 节点
	用于相同服务下不同机器区分，同一服务下都可存在多个动态节点。结构如下：

```
[
    {
        ip : xx,
        port : xx,
        name : node_name_1,
        service : service_1
        xxx : xxx
    },
    {
        ip : xx,
        port : xx,
        name : node_name_2,
        service : service_1
        xxx : xxx
    }
]

```


## 3. 规则
	负载规则等价于url匹配，url匹配支持正则，如/api/get， /api/* ，* 代表通配符。 结构如下：

```
{
    url : /api/xxx,
    service : service_name,
    index : node_index
}

```



## 4. 策略
	提供不同策略支持，可动态切换策略。暂支持url指定策略，random随机策略。

    url指定策略 ： 在指定服务内指定节点负载
    random随机策略 ： 在指定服务内所有节点负载