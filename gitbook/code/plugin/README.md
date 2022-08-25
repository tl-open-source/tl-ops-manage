# 插件模块

关于插件模块的实现，主要是依赖openresty的多阶段基础上植入一些模板钩子方法，达到引入自定义插件的目的，其流程如下

### conf阶段

可以看到是在openresty的不同阶段启动相应的模板方法，相应的模板方法在 `tl_ops_manage.lua` 中


```lua
# 代码位置 : conf/tl_ops_manage.conf

init_by_lua_block {
	tlops = require("tl_ops_manage")
	tlops:tl_ops_process_init();
}
init_worker_by_lua_block {
	tlops:tl_ops_process_init_worker();
}
...

```

我们看回 `tl_ops_manage.lua` 文件，首先是在init阶段加载所有插件，然后在其他阶段以此调用模板方法执行所有加载的插件。

注意 ：在加载完插件后，会将所有加载的插件缓存在全局变量 `tlops` 中，方便其他阶段调用执行


```lua
# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init()
    -- 加载所有插件
    m_plugin:tl_ops_process_load_plugins();
    _M.plugins = m_plugin:tl_ops_process_get_plugins()
end

function _M:tl_ops_process_init_worker()
   ...
    
    m_plugin:tl_ops_process_init_worker();
end

function _M:tl_ops_process_init_rewrite()
    ...
    
	m_plugin:tl_ops_process_init_rewrite();
end
...

```

