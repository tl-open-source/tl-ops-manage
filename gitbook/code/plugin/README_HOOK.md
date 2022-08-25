# 插件多阶段钩子

在openresty多阶段执行中，tl-ops-manage植入了16个钩子函数，分别是如下 
`tl_ops_process_before_init_worker`, `tl_ops_process_before_init_ssl`, `tl_ops_process_before_init_rewrite`,  `tl_ops_process_before_init_access`,  `tl_ops_process_before_init_balancer`,  `tl_ops_process_before_init_header`,  `tl_ops_process_before_init_body`,  `tl_ops_process_before_init_log`,

`tl_ops_process_after_init_worker`, `tl_ops_process_after_init_ssl`,  `tl_ops_process_after_init_rewrite`,  `tl_ops_process_after_init_access`,  `tl_ops_process_after_init_balancer`,  `tl_ops_process_after_init_header`,  `tl_ops_process_after_init_body`,  `tl_ops_process_after_init_log`



### tl_ops_process_*_init_worker

init_worker阶段和其他阶段不太一样，此阶段存在多worker竞争，所以有一次前置锁操作。

#### 应用场景

一般在此阶段可以植入一些定时器逻辑，如数据定时同步等


```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- init_worker阶段执行
function _M:tl_ops_process_init_worker()
    local lock_key = "tl_ops_plugin_process_worker_lock"
    local lock_time = 5
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_worker) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_worker()
            if not ok then
                tlog:err("tl_ops_process_init_worker process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_worker process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end

```


### tl_ops_process_*_init_ssl

#### 应用场景

一般在此阶段处理ssl证书相关逻辑，如动态配置ssl证书等


```lua
# 代码位置 : plugins/tl_ops_plugin.lua

function _M:tl_ops_process_init_ssl(ctx)
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_ssl) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_ssl(ctx)
            if not ok then
                tlog:err("tl_ops_process_init_ssl process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_ssl process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end

```

### tl_ops_process_*_init_rewrite

#### 应用场景

一般在此阶段可以植入一些转发逻辑

```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- rewrite阶段执行
function _M:tl_ops_process_init_rewrite()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_rewrite) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_rewrite()
            if not ok then
                tlog:err("tl_ops_process_init_rewrite process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_rewrite process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end
```

### tl_ops_process_*_init_access

#### 应用场景

一般在此阶段可以植入一些权限控制逻辑

```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- access阶段执行
function _M:tl_ops_process_init_access()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_access) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_access()
            if not ok then
                tlog:err("tl_ops_process_init_access process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_access process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end
```

### tl_ops_process_*_init_balancer

#### 应用场景

一般在此阶段可以植入一些 接收请求处理并输出响应 逻辑

```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- content阶段执行
function _M:tl_ops_process_init_balancer()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_balancer) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_balancer()
            if not ok then
                tlog:err("tl_ops_process_init_balancer process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_balancer process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end
```

### tl_ops_process_*_init_header

#### 应用场景

一般在此阶段可以植入一些响应头修改逻辑


```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- header阶段执行
function _M:tl_ops_process_init_header()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_header) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_header()
            if not ok then
                tlog:err("tl_ops_process_init_header process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_header process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end
```

### tl_ops_process_*_init_body

#### 应用场景

一般在此阶段可以植入一些 响应体内容处理 逻辑


```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- body阶段执行
function _M:tl_ops_process_init_body()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_body) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_body()
            if not ok then
                tlog:err("tl_ops_process_init_body process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_body process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end
```

### tl_ops_process_*_init_log

#### 应用场景

一般在此阶段可以植入一些 日志记录统计 逻辑


```lua
# 代码位置 : plugins/tl_ops_plugin.lua

-- log阶段执行
function _M:tl_ops_process_init_log()
    for i = 1, #self.plugins do
        local plugin = self.plugins[i]
        if type(plugin.func.tl_ops_process_init_log) == 'function' then
            local ok, _ = plugin.func:tl_ops_process_init_log()
            if not ok then
                tlog:err("tl_ops_process_init_log process err , name=",plugin.name, ", ",_)
            else
                tlog:dbg("tl_ops_process_init_log process ok , name=",plugin.name, ", ",_)
            end
        end
    end
end
```