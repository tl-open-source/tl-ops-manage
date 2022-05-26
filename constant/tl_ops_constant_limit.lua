local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

---- 桶配置 （全局桶，服务桶，节点桶）,global, service, node
local global_token = {   ----全局令牌桶配置
    cache_key = {
        capacity = "tl_ops_limit_token_capacity_global",
        rate = "tl_ops_limit_token_rate_global",
        pre_time = "tl_ops_limit_token_pre_time_global",
        token_bucket = "tl_ops_limit_token_bucket_global",
        warm = "tl_ops_limit_token_warm_global",
        lock = "tl_ops_limit_token_lock_global"
    },
    options = {
        capacity = 10 * 1024 * 1024,      ---- 最大容量 10M (按字节为单位，可做字节整型流控)
        rate = 1024,                      ---- 令牌生成速率/秒 (每秒 1KB)
        warm = 100 * 1024,                ---- 预热令牌数量 (预热100KB)
        half_capacity = 2,                ---- 限流状态令牌最大容量
        block = 1024,                     ---- 流控以1024为单位
    }
}
local service_token = {   ----服务令牌桶配置
    cache_key = {
        capacity = "tl_ops_limit_token_capacity_service",
        rate = "tl_ops_limit_token_rate_service",
        pre_time = "tl_ops_limit_token_pre_time_service",
        token_bucket = "tl_ops_limit_token_bucket_service",
        warm = "tl_ops_limit_token_warm_service",
        lock = "tl_ops_limit_token_lock_service"
    },
    options = {
        capacity = 10 * 1024 * 1024,
        rate = 1024,
        warm = 100 * 1024,
        half_capacity = 2,
        block = 1024,
    }
}
local node_token = {   ----节点令牌桶配置
    cache_key = {
        capacity = "tl_ops_limit_token_capacity_node",
        rate = "tl_ops_limit_token_rate_node",
        pre_time = "tl_ops_limit_token_pre_time_node",
        token_bucket = "tl_ops_limit_token_bucket_node",
        warm = "tl_ops_limit_token_warm_node",
        lock = "tl_ops_limit_token_lock_node"
    },
    options = {
        capacity = 10 * 1024 * 1024,
        rate = 1024,
        warm = 100 * 1024,
        half_capacity = 2,
        block = 1024,
    }
}

---- 依赖限流组件
local depend = {
    token = "token",
    leak = "leak"
}

---- 组件级别
local level = {
    service = "service"
}

---- 熔断配置
local fuse = {
    cache_key = {
        lock = "tl_ops_limit_fuse_lock",
        req_succ = "tl_ops_limit_fuse_req_succ",                                ---- int        周期内路由成功次数
        req_fail = "tl_ops_limit_fuse_req_fail",                                ---- int        周期内路由失败次数
        options_list = "tl_ops_limit_fuse_options_list",                        ---- list       配置缓存
        service_state = "tl_ops_limit_fuse_service_state",                      ---- int        服务熔断状态
        service_version = "tl_ops_limit_fuse_service_version",                  ---- int        服务配置变动
        service_options_version = "tl_ops_limit_fuse_service_options_version",  ---- boolean    服务新增变动
        timers = "tl_ops_limit_fuse_timers",                                    ---- list       当前开启自检的服务
    },
    options = {

    },
    demo = {
        service_name = "tlops-demo",
        interval = 10 * 1000,         ---- 检测时间间隔 单位/ms
        node_threshold = 0.3,         ---- 切换状态阈值 （node失败占比）
        service_threshold = 0.5,      ---- 切换状态阈值 （service切换阈值，取决于node失败状态占比）
        recover = 15 * 1000,          ---- 全熔断恢复时间 单位/ms
        depend = depend.token,        ---- 默认依赖组件 ：token_bucket
        level = level.service,        ---- 默认组件级别，服务层级 [限流熔断针对的层级]
    },
    service = tl_ops_constant_service.list
}

---- 限流/熔断配置
local tl_ops_constant_limit = {
    fuse = fuse,
    global_token = global_token,
    node_token = node_token,
    service_token = service_token,
    depend = depend,
    level = level,
}


return tl_ops_constant_limit