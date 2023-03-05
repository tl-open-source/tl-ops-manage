# 页面代理插件

页面代理插件主要用于tl-ops-manage内部静态页面路径处理，如管理控制台页面，官网页面。

其实现方式通过在set阶段指定变量名称，在 `tl_ops_process_before_init_rewrite` 阶段执行变量赋值，从而转向访问具体内部地址。

## 为什么要动态地址？ 我个人的考虑有以下几点

#### 方便统一配置

最初的设计是在nginx.conf中配置每个静态模块的页面地址。而项目地址在 `tl_ops_manage_env.lua` 中也有一份相关配置，导致配置分散，不统一。

统一后的配置，项目路径统一在全局配置文件中 `tl_ops_manage_env.lua` 管理，由插件读取配置文件进行动态转发静态页面地址。

#### 方便权限控制

在一些情况下，可能会需要限制某些ip，或者达到某些条件才能访问管理控制台，而如果直接在传统的location块下，可能会这样实现

```lua
location xxx {

    root /path/to/xxx;

    deny xxxx;

    allow all;
}
```
这种如果需要进行动态变更ip的话，需要调整到对应的conf。如果用插件的形式动态调整的话，只需要后续在插件上补充一些限制ip的代码逻辑，并提供可视化操作即可

#### 动态调整路径

还有一个好处就是支持动态调整静态资源路径，v-3.3.0以上已支持动态配置静态资源路由

## 实现

```lua
# 代码位置 : plugins/tl_ops_page_proxy/tl_ops_plugin_core.lua


-- 页面转发插件实现
function _M:tl_ops_process_before_init_rewrite(ctx)

    local request_uri = utils:get_req_uri()

    if ngx.re.find(request_uri, "/tlopsmanage/", 'jo') then
        ngx.var.tlopsmanage = env.path.tlopsmanage
    end

    if ngx.re.find(request_uri, "/website/", 'jo') then
        ngx.var.website = env.path.website
    end

    return true, "ok"
end
```