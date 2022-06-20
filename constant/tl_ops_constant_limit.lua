local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

-- 令牌桶配置
local token = {   --服务令牌桶配置
    cache_key = {
        options_list = "tl_ops_limit_token_options_list",
        capacity = "tl_ops_limit_token_capacity_service",
        rate = "tl_ops_limit_token_rate_service",
        expand = "tl_ops_limit_leak_expand_service",
        shrink = "tl_ops_limit_leak_shrink_service",
        pre_time = "tl_ops_limit_token_pre_time_service",
        token_bucket = "tl_ops_limit_token_bucket_service",
        warm = "tl_ops_limit_token_warm_service",
        lock = "tl_ops_limit_token_lock_service"
    },
    options = {

    },
    demo = {
        service_name = "tlops-demo",      -- 令牌桶配置所属服务 
        capacity = 10 * 1024 * 1024,      -- 最大容量 10M (按字节为单位，可做字节整型流控)
        rate = 1024,                      -- 令牌生成速率/秒 (每秒 1KB)
        warm = 100 * 1024,                -- 预热令牌数量 (预热100KB)
        block = 1024,                     -- 流控以1024为单位
        expand = 0.5,                     -- 扩容比例
        shrink = 0.5,                     -- 缩容比例
    }
}

-- 漏桶配置
local leak = {   --服务漏桶配置
    cache_key = {
        options_list = "tl_ops_limit_leak_options_list",
        capacity = "tl_ops_limit_leak_capacity_service",
        rate = "tl_ops_limit_leak_rate_service",
        expand = "tl_ops_limit_leak_expand_service",
        shrink = "tl_ops_limit_leak_shrink_service",
        pre_time = "tl_ops_limit_leak_pre_time_service",
        leak_bucket = "tl_ops_limit_leak_bucket_service",
        lock = "tl_ops_limit_leak_lock_service"
    },
    options = {

    },
    demo = {
        service_name = "tlops-demo",      -- 漏桶配置所属服务 
        capacity = 10 * 1024 * 1024,      -- 最大容量 10M (按字节为单位，可做字节整型流控)
        rate = 1024 * 10,                 -- 漏桶流速/秒 (每秒 10KB)
        block = 1024,                     -- 流控以1024为单位
        expand = 0.5,                     -- 扩容比例
        shrink = 0.5,                     -- 缩容比例
    }
}

-- 依赖限流组件
local depend = {
    token = "token",
    leak = "leak"
}

-- 组件级别
local level = {
    service = "service"
}

-- 熔断策略
local mode = {
    balance_fail = "balance_fail",      -- 节点路由失败率
    health_state = "health_state"       -- 节点健康状态
}


-- 熔断配置
local fuse = {
    cache_key = {
        lock = "tl_ops_limit_fuse_lock",                                        -- boolean    熔断定时任务锁
        req_succ = "tl_ops_limit_fuse_req_succ",                                -- int        周期内路由成功次数
        req_fail = "tl_ops_limit_fuse_req_fail",                                -- int        周期内路由失败次数
        options_list = "tl_ops_limit_fuse_options_list",                        -- list       配置缓存
        service_state = "tl_ops_limit_fuse_service_state",                      -- int        服务熔断状态
        service_version = "tl_ops_limit_fuse_service_version",                  -- int        服务配置变动
        service_options_version = "tl_ops_limit_fuse_service_options_version",  -- boolean    服务新增变动
        timers = "tl_ops_limit_fuse_timers",                                    -- list       当前开启自检的服务
    },
    options = {

    },
    demo = {
        service_name = "tlops-demo",
        interval = 10 * 1000,         -- 检测时间间隔 单位/ms
        node_threshold = 0.3,         -- 切换状态阈值 （node失败占比）
        service_threshold = 0.5,      -- 切换状态阈值 （service切换阈值，取决于node失败状态占比）
        recover = 15 * 1000,          -- 全熔断恢复时间 单位/ms
        depend = depend.token,        -- 默认依赖组件 ：token_bucket
        level = level.service,        -- 默认组件级别 ：服务层级 [限流熔断针对的层级]
        mode = mode.balance_fail,     -- 默认策略 ：节点路由失败率
    },
    service = tl_ops_constant_service.list
}

-- 限流/熔断配置
local tl_ops_constant_limit = {
    fuse = fuse,
    token = token,
    leak = leak,
    depend = depend,
    level = level,
    mode = mode
}


return tl_ops_constant_limit