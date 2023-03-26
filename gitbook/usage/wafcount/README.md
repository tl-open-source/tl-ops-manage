# WAF统计

WAF统计，是在WAF模块上扩充的一种功能，在服务进行WAF逻辑拦截请求时，可能存在拦截成功，或通过，有些情况下可能需要统计WAF情况进行展示。其对应的配置在 constant/tl_ops_constant_waf_count.lua中。

为了更直观的统计各种WAF拦截情况，除了以前的WAF拦截成功的统计数据，目前已经支持统计多个维度下的WAF拦截详情，如 `api-WAF策略`，`cc-WAF策略`，`cookie-WAF策略` ... 等等

## 在文件中配置

```lua
-- WAF统计时间间隔
interval = 10       -- 统计周期 单位/s, 默认: 10s
```

## 在管理台配置

暂不支持