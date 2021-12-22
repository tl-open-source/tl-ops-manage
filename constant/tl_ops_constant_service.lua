local tl_ops_status = require("constant.tl_ops_constant_comm").tl_ops_status;

---- service 默认列表
local tl_ops_constant_service = {
    list = {
        service1 = {
            {
                name = "service1-node-8081",    ---- 当前节点name
                service = "service1",           ---- 当前节点所属service
                protocol = "http://",           ---- 当前节点协议头
                ip = "127.0.0.1",               ---- 当前节点ip
                port = 8081,                    ---- 当前节点port
            },
            {
                name = "service1-node-8082",
                service = "service1",
                protocol = "http://",
                ip = "127.0.0.1",
                port = 8082,
            }
        },
        service2 = {
            {
                name = "service2-node-9091",
                service = "service2",
                protocol = "http://",
                ip = "127.0.0.1",
                port = 9091,
            },
            {
                name = "service2-node-9092",
                service = "service2",
                protocol = "http://",
                ip = "127.0.0.1",
                port = 9092,
            }
        }
    },
    rule = {---- service rule 策略
        auto_load = 0,
        cus_load = 1,
        on_load = 2
    }
}


return tl_ops_constant_service