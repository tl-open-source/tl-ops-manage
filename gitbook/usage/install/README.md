
# 安装

**下载项目 : https://github.com/iamtsm/tl-ops-manage**

或者

**git clone https://github.com/iamtsm/tl-ops-manage**

## 安装依赖

首先需要安装openresty，可以去官网下载对应包, http://openresty.org/cn/download.html 

如果需要将数据同步至redis存储，需要安装redis，https://redis.io/download/， redis启用开关在tl_ops_manage_env.lua中

redis存储是本项目附带的一个功能，你也可以自行支持你需要的存储模式如mysql, etcd等。自行支持请查看本文档中的 ‘缓存相关’ 


## 修改配置

#### tl-ops-manage/conf/tl_ops_manage.conf

```
ssl_certificate /path/to/tl-ops-manage/conf/tlops.com.pem;
ssl_certificate_key /path/to/tl-ops-manage/conf/tlops.com.key;
```

#### openresty/conf/nginx.conf

````
http {
	...
	# 引入tl_ops_manage.conf
	include "/path/to/tl-ops-manage/conf/*.conf";

	# 引入lua包
	lua_package_path "/path/to/tl-ops-manage/?.lua;;";
	...
}
````

#### tl-ops-manage/tl_ops_manage_env.lua

```
# 项目路径
ROOT_PATH = "/path/to/tl-ops-manage/"
```

## 启动nginx/openresty

访问 http://your-domain/tlopsmanage/tl_ops_web_index.html  控制台
