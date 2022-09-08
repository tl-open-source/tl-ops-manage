
local content_page = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="/tlopsmanage/lib/layui/css/layui.css">
    <link rel="stylesheet" href="/tlopsmanage/lib/login.css">
    <title>登录</title>
</head>
<body>
    <div class="container">
        <form class="layui-form" id="login" lay-filter="login">
            <button class="close" title="关闭">X</button>
            <div class="layui-form-mid layui-word-aux logo">
                <img src="/tlopsmanage/lib/logo.png" height="35"/>
            </div>
            <div class="layui-form-item" style="margin-top: 10px;">
                <label class="layui-form-label">用户名</label>
                <div class="layui-input-block">
                    <input type="text" name="username" required lay-verify="required" placeholder="请输入用户名"
                        autocomplete="off" class="layui-input">
                </div>
            </div>
            <div class="layui-form-item" style="margin-top: 30px;">
                <label class="layui-form-label">密  码</label>
                <div class="layui-input-inline">
                    <input type="password" name="password" required lay-verify="required" placeholder="请输入密码"
                        autocomplete="off" class="layui-input">
                </div>
            </div>
        </form>
        <div class="layui-form-item" style="margin-top: 30px;">
            <div class="layui-input-block">
                <button class="layui-btn" onclick="tl_ops_manage_login()" style="letter-spacing: 40px;text-indent: 30px;">登陆</button>
            </div>
        </div>
    </div>
    <script src="/tlopsmanage/lib/layui/layui.js"></script>
    <script src="/tlopsmanage/tl_ops_web_comm.js"></script>
    <script>
        layui.use(['form', 'layedit', 'layer'], function () {
            window.form = layui.form;
            window.$ = layui.$;
            window.layer = layui.layer
            window.tl_ops_manage_login = function(){
                let data = form.val("login")
                if(data.username === '' || data.password === ''){
                    layer.msg("用户名密码不能为空")
                    return
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/auth/login',
                    data : JSON.stringify(data),
                    contentType : "application/json",
                    success : (res)=>{
                        layer.msg(res.msg)
                        setTimeout(() => {
                            window.location.reload()
                        }, 1000);
                    }
                }));
            }                
        });
    </script>
</body>

</html>
]]


local tl_ops_plugin_constant_auth = {
    cache_key = {
        login = "tl_ops_plugin_auth_login",         -- 登录配置, 暂不支持动态配置
        list = "tl_ops_plugin_auth_list",           -- 用户列表，暂不支持动态配置
        session = "tl_ops_plugin_auth_session",     -- 登录态key前缀, 暂不支持动态配置
    },
    tlops_api = {                                   -- 对外提供的API
        login = "/tlops/auth/login"
    },
    login = {
        code = 403,
        content_type = "text/html",
        content = content_page,
        intercept = {
            "/tlopsmanage/", 
            "/tlops/",
        },
        filter = {
            "/tlops/auth/login",
            "/tlopsmanage/lib/",
            "/tlopsmanage/tl_ops_web_comm.js",
        },
        auth_time = 3600,
        auth_cid = "_tl_t",
        auth_hid = "Tl-Auth-Rid",
    },
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
    },
    demo = {
        login = {
            code = 403,                         -- 返回登录页面的错误码
            content_type = "text/html",         -- 返回登录页面的类型
            content = "<p> 请先登录 </p>",       -- 返回登录页面内容 
            intercept = {                       -- 需要校验登录权限的uri
                "/tlopsmanage/", 
                "/tlops/", 
                "/website/"
            },
            filter = {                          -- 不参与登录校验的uri
                "/tlops/auth/login"
            },
            auth_time = 3600,                   -- 登录态时间, 单位/s
            auth_cid = "_tl_t",                 -- 请求cookie校验
            auth_hid = "Tl-Auth-Rid",           -- 请求头校验
        },
        list = {
            id = 1,                             -- id
            username = "admin",                 -- 用户名
            password = "admin",                 -- 密码
        }
    }
}


return tl_ops_plugin_constant_auth