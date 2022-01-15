
---- 限流/熔断配置
local tl_ops_constant_limit = {
    token = {   ----令牌桶配置
        cache_key = {
            capacity = "tl_ops_limit_token_capacity",
            rate = "tl_ops_limit_token_rate",
            pre_time = "tl_ops_limit_token_pre_time",
            token_bucket = "tl_ops_limit_token_bucket",
            warm = "tl_ops_limit_token_warm",
            lock = "tl_ops_limit_token_lock"
        },
        options = {
            capacity = 10 * 1024 * 1024,      ---- 最大容量 10M (按字节为单位，可做字节整型流控)
            rate = 1024,                      ---- 令牌生成速率/秒 (每秒 1KB)
            warm = 100 * 1024                 ---- 预热令牌数量 (预热100KB)
        },
    },
    leak = {    ----漏桶配置
        cache_key = {

        },
        options = {
            
        }
    },
    sliding = { ----滑动窗口配置
        cache_key = {

        },
        options = {
            
        }
    },
    fuse = {    ----熔断配置配置
        cache_key = {

        },
        options = {
            
        }
    },
}


return tl_ops_constant_limit