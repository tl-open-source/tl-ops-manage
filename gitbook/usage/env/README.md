
# 配置


配置有两种方式，一种是在配置文件中填写配置，另外一种是在管理台填写配置。同时，配置是分为两种类别，一种是定时任务中的配置，另外一种是无需进入定时任务的规则配置。


## 定时任务配置

    在定时任务中的配置，是在ngx.timer启动时传入，并启动相应的timer，其作用域是在timer的作用域中，如果发生配置变动ngx.timer是主动无法感知的。所以是需要主动判断timer内的conf是否需要同步为最新

 如 “健康检查配置”，“熔断限流配置”，“服务节点配置” 这些需要依赖定时任务的都属于定时任务配置。

## 规则配置

    而像负载多策略配置，如 “API负载规则” ，“WAF-CC规则”，... 这类配置是在请求阶段实时获取的，是实时保持最新，无需主动同步的


## 文件中配置

    在文件中配置的数据，只有服务配置，健康检查配置，熔断配置等依赖定时器的情况下，才会从文件配置中取值，其他情况下在文件中配置不生效。
    因为配置的读取都在cache中进行，如果需要将文件中新增或者修改的数据生效，可以开启同步数据插件，在启动时同步合并至cache中。

### 内置模块文件中配置

    在内置的模块中，如服务，自检，负载等模块中的文件配置是统一在 constant 包下的文件

### 插件模块文件中配置

    在插件模块中，配置统一放置在各个插件包下的tl_ops_plugin_constant.lua中

## 管理台配置 

    在管理后台设置的数据，会直接进入cache中


# 全局项目配置


除了基础数据配置外，tl-ops-manage还提供了全局配置，对应的配置文件在，`tl-ops-manage/tl_ops_manage_env.lua` 中，全局配置支持了对各种功能模块的的细化控制


```lua
local ROOT_PATH = "/path/to/tl-open-source/tl-ops-manage/"

return {
    path = {
        tlopsmanage = ROOT_PATH .. "web/",
        website = ROOT_PATH .. "website/",
        log = ROOT_PATH,
        store = ROOT_PATH .. "store/",
    },
    log = {
        level = 1,
        format_json = true,
    },
    cache = {
        cus = "none"
    },
    balance = {
        counting = true,
        limiter = true,
    },
    waf = {
        open = true,
        counting = true,
    }
}

```
