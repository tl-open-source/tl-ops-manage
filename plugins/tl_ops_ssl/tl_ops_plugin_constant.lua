-- ssl默认列表
-- ps : 可以优化为k-v结构, list结构会影响性能，当前只是简单处理了

local tlops_api = {
    get = "/tlops/ssl/list",
    set = "/tlops/ssl/set"
}

local tl_ops_constant_ssl = {
    cache_key = {
        list = "tl_ops_ssl_list"
    },
    tlops_api = tlops_api,              -- 对外API
    list = {

    },
    demo = {
        id = 1,
        host = "tlops.com",             -- 当前生效的域名
        pem = "",                       -- pem证书内容
        key = "",                       -- key证书内容
    },
}

return tl_ops_constant_ssl