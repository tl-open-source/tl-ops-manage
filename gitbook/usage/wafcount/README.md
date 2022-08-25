# WAF统计

WAF统计，是在WAF模块上扩充的一种功能，在服务进行WAF逻辑拦截请求时，可能存在拦截成功，或通过，有些情况下可能需要统计WAF情况进行展示。其对应的配置在 constant/tl_ops_constant_waf.lua中。


## 在文件中配置

```lua
-- WAF统计时间间隔
count = {
	interval = 5 * 60       -- 统计周期 单位/s, 默认:5min
}
```

## 在管理台配置

暂不支持