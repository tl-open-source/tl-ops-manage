# 动态证书配置

由于在一些业务场景下，会需要将域名配置为https协议，相比于nginx的ssl配置来说，需要人工干预证书文件,路径相关配置。而在tl-ops-manage中，提供了动态支持证书配置，只需要指定域名，填写好证书内容即可。无需修改nginx.conf配置相关。

## 在文件中配置

```lua

list = {
    id = 1,
    host = "tlops.com",             -- 当前生效的域名
    pem = "xxxxx",                  -- pem证书内容 （需注意换行和空格）
    key = "xxxxx",                  -- key证书内容（需注意换行和空格）
},

```

## 在管理台配置

 ![图片](https://qnproxy.iamtsm.cn/企业微信截图_1661246281537.png "图片") 