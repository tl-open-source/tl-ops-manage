-- sync_cluster_heartbeat
-- en : sync cluster data heartbeat
-- zn : 主从节点心跳数据接口，从节点才开放接口。
-- @author iamtsm
-- @email 1905333456@qq.com

local sync_cluster_data_get     = require("plugins.tl_ops_sync_cluster.sync_cluster_data_get")
local sync_cluster_data_parse   = require("plugins.tl_ops_sync_cluster.sync_cluster_data_parse")
local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync_cluster")
local nx_socket					= ngx.socket.tcp
local tl_ops_rt                 = tlops.constant.comm.tl_ops_rt
local utils                     = tlops.utils
local cjson                     = require("cjson.safe")
cjson.encode_empty_table_as_object(false)


-- 心跳处理接口
-- 当前节点是从节点，接收来自主节点的请求数据，执行同步逻辑
local sync_cluster_heartbeat_receive = function( ctx )
    ngx.req.read_body()

    local body = ngx.req.get_body_data()
    
    tlog:dbg("sync_cluster_heartbeat_receive start, uri=",ctx.uri, ",method=",ctx.method,",body=",body)

    local sync_content = cjson.decode(body)

    local res = sync_cluster_data_parse:parse_sync_cluster_data_module(sync_content)
    if not res then
        tlog:err("sync_cluster_heartbeat_receive parse err res=",res)
        return
    end
    
    tlog:dbg("sync_cluster_heartbeat_receive done sync_content=",sync_content)
end


-- 周期性心跳同步包
-- 当前节点是主节点，调用socket请求，发送到从节点的请求数据
local sync_cluster_heartbeat_send = function(options)

    local current = options.current
    local other = options.other
    local timeout = options.timeout
    local path = options.path
    local modules = options.modules

    for i = 1, #other do
        repeat
            local node = other[i]

            local req_data = sync_cluster_data_get:get_sync_cluster_data_module(modules)

            tlog:dbg("sync_cluster_heartbeat_send get data done, node=",node,",req_data=",req_data)

            local sock, _ = nx_socket()
            if not sock then
                tlog:err("sync_cluster_heartbeat_send failed to create stream socket: ", _)
                break
            end
            sock:settimeout(timeout)

            -- 心跳socket
            local ok, _ = sock:connect(node.ip, node.port)
            if not ok then
                tlog:err("sync_cluster_heartbeat_send failed to connect socket: ", _)
                break
            end

            tlog:dbg("sync_cluster_heartbeat_send connect socket ok : ok=", ok)

            local body = "POST " .. path .." HTTP/1.0 \r\n"
            body = body .. "Content-Type: application/json \r\n"
            body = body .. "Host: " .. current.ip .. ":" .. current.port .. " \r\n"
            body = body .. "Content-Length: " .. #req_data .. " \r\n"
            body = body .. "\n" .. req_data .. "\r\n"

            local bytes, _ = sock:send(body)
            if not bytes then
                tlog:err("sync_cluster_heartbeat_send failed to send socket: ", _)
                break
            end

            tlog:dbg("sync_cluster_heartbeat_send send socket ok : byte=", bytes)

            -- socket反馈
            local receive_line, _ = sock:receive()
            if not receive_line then
                if _ == "check_timeout" then
                    tlog:err("sync_cluster_heartbeat_send socket check_timeout: ", _)
                    sock:close()
                end
                break
            end

            tlog:dbg("sync_cluster_heartbeat_send receive socket ok : ", receive_line)

            sock:close()

            tlog:dbg("sync_cluster_heartbeat_send heartbeat done ",",node=",node)

            break
        until true
    end
end


return {
    sync_cluster_heartbeat_receive = sync_cluster_heartbeat_receive,
    sync_cluster_heartbeat_send = sync_cluster_heartbeat_send
}