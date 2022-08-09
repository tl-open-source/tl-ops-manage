-- tl_ops_sync_cluster_timer
-- en : sync_cluster timer
-- zn : 周期性同步集群节点数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                      = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync_cluster_timer")
local sync_cluster_data         = require("plugins.tl_ops_sync_cluster.sync_cluster_data")
local constant_sync_cluster     = require("plugins.tl_ops_sync_cluster.tl_ops_plugin_constant")
local sync_env                  = tlops.env.sync
local utils                     = tlops.utils


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 检查器
local tl_ops_sync_cluster_timer = function(premature, modules)
	if premature then
		return
    end

    -- 对每个节点周期性的检查各个模块数据
    for i = 1, #other do
        local node = other[i]
        local res = sync_cluster_data:sync_cluster_data_module(node, options)
        tlog:dbg("tl_ops_sync_cluster_timer, res=",res,",node=",node)
    end
end


-- 启动器
function _M:tl_ops_sync_cluster_timer_start( )
    local lock_key = "tl_ops_plugin_sync_cluster_timer_lock"
    local lock_time = 1
    if not utils:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    local sync_cluster_data_env = sync_env.cluster_data
    if not sync_cluster_data_env.open then
        tlog:dbg("tl_ops_sync_cluster_timer_start not open ")
        return
    end

    local module = sync_cluster_data_env.module
    if not module then
        tlog:dbg("tl_ops_sync_cluster_timer_start no module, module=",module)
        return
    end
    
    local options = {
        timeout = constant_sync_cluster.timeout,
        current = constant_sync_cluster.current,
        other = constant_sync_cluster.other,
        interval = constant_sync_cluster.interval,
        modules = module
    }

    tlog:dbg("tl_ops_sync_cluster_timer_start options=",options)

    local current = options.current
    if not current then
        tlog:err("tl_ops_sync_cluster_timer_start current nil")
        return
    end

    -- 主节点才能发送心跳
    if not current.master then
        tlog:dbg("tl_ops_sync_cluster_timer_start current not master")
        return
    end

    -- 从节点
    local other = options.other
    if not other then
        tlog:err("tl_ops_sync_cluster_timer_start other nil")
        return
    end

    local ok, _ = ngx.timer.at(options.interval, tl_ops_sync_cluster_timer, options)
	if not ok then
		tlog:err("tl_ops_sync_cluster_timer_start start failed to run , create timer failed " ,_)
		return
    end
end


-- 拦截器
function _M:tl_ops_sync_cluster_filter(ctx)

    local current = constant_sync_cluster.current
    if not current then
        tlog:err("tl_ops_sync_cluster_filter current nil")
        return
    end

    -- 主节点不拦截
    if current.master then
        tlog:dbg("tl_ops_sync_cluster_filter current master")
        return
    end

    --从节点关闭管理端API
    local request_uri = utils:get_req_uri()
    for uri ,router in pairs(ctx.tlops_api) do
        if ngx.re.find(request_uri, uri, 'jo') then
            tlog:dbg("tl_ops_sync_cluster_filter slave tlops api close, request_uri=",request_uri)
            ngx.header['Tl-Slave-Api'] = "close"
            ngx.exit(403)
            return
        end
    end
end


function _M:new()
	return setmetatable({}, mt)
end

return _M
