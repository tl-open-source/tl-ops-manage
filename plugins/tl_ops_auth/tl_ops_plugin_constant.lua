local default_content_page = [[
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
        <form class="layui-form" id="login" lay-filter="login" onkeydown="if(event.keyCode==13){return false;}">
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
    <script src="/tlopsmanage/lib/tl_ops_web_comm.js"></script>
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
        login = "tl_ops_plugin_auth_login",         -- 登录配置
        list = "tl_ops_plugin_auth_list",           -- 用户列表
        session = "tl_ops_plugin_auth_session",     -- 登录态key前缀
    },
    tlops_api = {                                   -- 对外提供的API
        login = "/tlops/auth/login",
        logout = "/tlops/auth/logout",
        get = "/tlops/auth/get",
        set = "/tlops/auth/set",
    },
    login = {
        code = 403,
        content_type = "text/html",
        content = default_content_page,
        intercept = {
            "/tlopsmanage/", 
            "/tlops/",
        },
        filter = {
            "/tlops/auth/login",
            "/tlopsmanage/lib/",
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
    },
    export = {
        cache_key = {
            auth = "tl_ops_plugins_export_auth",
        },
        tlops_api = {
            get = "/tlops/auth/manage/get",      -- 获取插件配置数据的接口
            set = "/tlops/auth/manage/set",      -- 修改插件配置数据的接口  
        },
        auth = {
            zname = '登录认证插件',
            page = "auth/tl_ops_web_auth_user.html",
            name = 'auth',
            open = true,
            scope = "tl_ops_process_before_init_rewrite",
        },
        demo = {
            zname = '',         -- 插件中文名称
            page = "",          -- 插件配置页面
            name = '',          -- 插件名称
            open = true,        -- 插件是否开启
            scope = "",         -- 插件生命周期阶段
        }
    }
}


return tl_ops_plugin_constant_auth