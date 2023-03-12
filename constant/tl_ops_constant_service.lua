local tl_ops_status     = require("constant.tl_ops_constant_comm").tl_ops_status;
local snowflake         = require("lib.snowflake");
-- service 默认列表
local tl_ops_constant_service = {
    cache_key = {
        -- 持久化字段
        service_list = "tl_ops_service_list",
        service_rule = "tl_ops_service_rule",
    },
    list = {
        
    },
    demo = {
        id = 1,
        name = "tlops-demo-node",           -- 当前节点name
        service = "service",                -- 当前节点所属service
        protocol = "http://",               -- 当前节点协议头
        ip = "127.0.0.1",                   -- 当前节点ip
        port = 6666,                        -- 当前节点port
    },
    rule = {-- service rule 自检策略
        auto_load = 'auto_load',
        cus_load = 'cus_load',
    },
}


return tl_ops_constant_service