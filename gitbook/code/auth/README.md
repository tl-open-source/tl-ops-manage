# 登录认证插件

登录认证插件主要为管理后台系统提供一个操作可控的权限认证，实现的方式是在 `tl_ops_process_before_init_rewrite` 阶段进行cookie或者header验证，对于需要拦截验证的链接进行验证，当然，拦截链接是可视化配置的，可以根据需要自定义

登录插件数据主要分为两个子模块，一个是自定义配置模块，一个是账号密码模块


### 拦截配置

我们先看一下拦截配置的数据定义，主要包含几个方面，拦截的api，拦截api白名单，拦截后返回的内容，登录验证身份相关。

```lua
# 代码位置 : plugins/tl_ops_auth/tl_ops_plugin_constant.lua

login = {
    code = 403,                     -- 拦截命中返回错误码
    content_type = "text/html",     -- 拦截命中返回错误内容格式
    content = default_content_page, -- 拦截命中返回内容
    intercept = {                   -- 需要拦截的api列表
        "/tlopsmanage/", 
        "/tlops/",
    },
    filter = {                      -- 不拦截的api列表
        "/tlops/auth/login",
        "/tlopsmanage/lib/",
    },
    auth_time = 3600,               -- 登录后session有效时间
    auth_cid = "_tl_t",             -- 登录后cookie值key
    auth_hid = "Tl-Auth-Rid",       -- 登录后header值key
},
```


### 账号配置

我们先看看账号数据定义，账号配置比较简单，只需要配置账号密码就行了，也可以在管理后台界面添加修改

```lua
# 代码位置 : plugins/tl_ops_auth/tl_ops_plugin_constant.lua

list = {
    {
        id = 1,
        username = "admin",
        password = "admin",
    },
    {
        id = 2,
        username = "test",
        password = "test"
    }
}
```

下面看看主要的实现逻辑，在rewrite阶段优先校验身份

```lua
# 代码位置 : plugins/tl_ops_auth/tl_ops_plugin_core.lua

function _M:tl_ops_process_before_init_rewrite(ctx)
    
    -- 登录态校验
    auth:auth_core(ctx)
    
    return true, "ok"
end
```

进入 `auth_core` 方法，看实现逻辑为拿到设置配置后，判断当前uri是否需要拦截，如果需要拦截， 判断cookie或者header中的sessionkey是否有效，
如果无效，则是没有登录，返回自定义的配置内容。

```lua
# 代码位置 : plugins/tl_ops_auth/auth.lua


function _M:auth_core(ctx)

    local login_str, _ = cache:get(constant.cache_key.login)
    if not login_str then
        tlog:err("auth_core get login cache err login_str=",login_str,",err=",_)
        return
    end

    local login, _ = cjson.decode(login_str)
    if not login then
        tlog:err("auth_core decode login cache err login=",login,",err=",_)
        return
    end

    -- 处理白名单
    for i, filter_ui in ipairs(login.filter) do
        if ngx.re.find(ctx.request_uri, filter_ui, 'jo') then
            return
        end
    end

    -- 处理拦截名单uri
    if not uri_in_intercept_uri(ctx) then
        return
    end

    -- cookie校验
    local cookie_utils = require("lib.cookie"):new();
    local auth_cid, _ = cookie_utils:get(login.auth_cid);
    if auth_cid ~= nil and auth_cid then
        local session = self:auth_get_session(auth_cid)
        if session then
            return
        end
    end

    -- header校验
    local headers = ngx.req.get_headers()
    local auth_hid = headers[login.auth_hid]
    if auth_hid ~= nil then
        local session = self:auth_get_session(auth_hid)
        if session then
            return
        end
    end

    tlog:dbg("req uri no auth, uri=",ctx.request_uri)

    utils:set_ngx_req_return_content(
        login.code, 
        login.content, 
        login.content_type
    )
    return
end
```
