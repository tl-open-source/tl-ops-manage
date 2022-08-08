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


-- 核心逻辑
local tl_ops_sync_cluster_core = function(options, module)

    tlog:dbg("tl_ops_sync_cluster_core checking")

    local sync_cluster_data_env = sync_env.cluster_data
    if sync_cluster_data_env.open then
        local module = sync_cluster_data_env.module
        if module then
            -- 对每个节点执行周期性的检查，检查各个模块数据
            for i = 1, #module do
                
                
            end
        else
            tlog:dbg("tl_ops_sync_cluster_timer no module, module=",module)
        end
    end

end



-- timer
local tl_ops_sync_cluster_timer = function(premature, options)
	if premature then
		return
    end

    tlog:dbg("tl_ops_sync_cluster_timer options=",options)

    tl_ops_sync_cluster_core(options, module)    
end


-- 启动器
function _M:tl_ops_sync_cluster_timer_start( )
    local lock_key = "tl_ops_plugin_sync_cluster_timer_lock"
    local lock_time = 1
    if not utils:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    local interval = constant_sync_cluster.interval
    local options = constant_sync_cluster.options

    local ok, _ = ngx.timer.at(interval, tl_ops_sync_cluster_timer, options)
	if not ok then
		tlog:err("tl_ops_sync_cluster_timer start failed to run , create timer failed " ,_)
		return nil
    end
end


function _M:new()
	return setmetatable({}, mt)
end

return _M
