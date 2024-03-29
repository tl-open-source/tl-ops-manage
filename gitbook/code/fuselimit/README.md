
# 熔断限流

熔断限流，其实是服务自动化熔断降级，服务限流两种的组合。

### 为什么称其为自动化熔断 ？

```
因为我们在判断服务是否处于 `性能不佳` 状态，而不能及时处理请求时，是需要依据一些服务本身的`健康状态`或实际`负载率`来衡量是否将服务降级，
但是我们在进行服务降级后，此服务恢复正常，那么此时该服务应该被升级，用于处理更多请求。而此 ‘服务升级/降级’ 步骤应该实现系统自动化。
```


对于服务自动化熔断来说，其应该是根据节点 ‘状态’ 来进行一种服务降级的手段。在节点负载过高时，应该对节点减少流量的进入，
在服务性能较优时，增加流量的进入，而控制流量的进入就需要用到一些流控手段。所以我将其组合设计。


对于这两种服务治理手段，在各大框架中也有不少应用，如java的spring cloud Hystrix，其实现也是做到了自动化熔断恢复。
