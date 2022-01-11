local tl_ops_status = require("constant.tl_ops_constant_comm").tl_ops_status;
local snowflake = require("lib.snowflake");
---- service 默认列表
local tl_ops_constant_service = {
    list = {
        service1 = {
            {
                id = snowflake.generate_id( 100 ),  ---- default snow id
                name = "service1-node-8081",        ---- 当前节点name
                service = "service1",               ---- 当前节点所属service
                protocol = "http://",               ---- 当前节点协议头
                ip = "127.0.0.1",                   ---- 当前节点ip
                port = 8081,                        ---- 当前节点port
            },
            {
                id = snowflake.generate_id( 100 ),
                name = "service1-node-8082",
                service = "service1",
                protocol = "http://",
                ip = "127.0.0.1",
                port = 8082,
            }
        },
        service2 = {
            {
                id = snowflake.generate_id( 100 ),
                name = "service2-node-9091",
                service = "service2",
                protocol = "http://",
                ip = "127.0.0.1",
                port = 9091,
            },
            {
                id = snowflake.generate_id( 100 ),
                name = "service2-node-9092",
                service = "service2",
                protocol = "http://",
                ip = "127.0.0.1",
                port = 9092,
            }
        }
    },
    rule = {---- service rule 自检策略
        auto_load = 'auto_load',
        cus_load = 'cus_load',
    },
}


return tl_ops_constant_service