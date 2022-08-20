-- tl_ops_time_alert_content
-- en : request long time alert content wrap
-- zn : 请求耗时告警内容生成组装
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                  = require("utils.tl_ops_utils_log"):new("tl_ops_time_alert")
local time_alert_constant   = require("plugins.tl_ops_time_alert.tl_ops_plugin_constant")
local utils                 = tlops.utils
local cjson                 = require("cjson.safe");


local time_alert_content_wrap = function(ctx, option, alert_type)
    
    -- 当前时间
    local cur_time = ngx.now()

    -- 请求耗时
    local request_time = cur_time - ngx.req.start_time()

    --  请求长度
    local request_length = ngx.req.request_length

    -- 内容长度
    local bytes_sent = ngx.req.bytes_sent

    -- 请求uri
    local request_uri = utils.get_req_uri()

    -- 负载的机器
    local upstream_node = ctx.tlops_ups_node

    -- 负载模式
    local upstream_mode = ctx.tlops_ups_mode

    local content = {
        option = option,
        alert_type = alert_type,
        request_time = request_time,
        request_lengt = request_lengt,
        bytes_sent = bytes_sent,
        cur_time = cur_time,
        request_uri = request_uri,
        upstream_mode = upstream_mode,
        upstream_node = upstream_node
    }

    return cjson.encode(content) 
end



return {
    time_alert_content_wrap = time_alert_content_wrap
}