-- tl_ops_sync
-- en : sync data , load data to memory
-- zn : 同步数据接口，预热数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_sync_constant_fields = require("sync.tl_ops_sync_constant_fields"):new();
local tl_ops_sync_constant_data = require("sync.tl_ops_sync_constant_data"):new();
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_sync");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");

local tl_ops_manage_env = require("tl_ops_manage_env")
local sync_env = tl_ops_manage_env.sync

local lock = require("lib.lock");
local shared = ngx.shared.tlopsbalance;


local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 核心逻辑
local tl_ops_sync_timer = function(premature, args)
	if premature then
		return
    end
    
    local sync_fields_data = {}
    local sync_fields_env = sync_env.fields
    if sync_fields_env.open then
        local module = sync_fields_env.module
        if module then
            for i = 1, #module do
                local res = tl_ops_sync_constant_fields:tl_ops_sync_constant_fields_module(module[i]);
                sync_fields_data[module[i]] = res
                tlog:dbg("tl_ops_sync_constant_fields , module=",module[i],",res=",res)
            end
        else
            tlog:dbg("tl_ops_sync_constant_fields no module, module=",module)
        end
    end

    local sync_constant_data = {}
    local sync_data_env = sync_env.data
    if sync_data_env.open then
        local module = sync_data_env.module
        if module then
            for i = 1, #module do
                local res = tl_ops_sync_constant_data:tl_ops_sync_constant_data_module(module[i]);
                sync_fields_data[module[i]] = res
                tlog:dbg("tl_ops_sync_constant_data , module=",module[i],",res=",res)
            end
        else
            tlog:dbg("tl_ops_sync_constant_data no module, module=",module)
        end
    end
end


-- 启动器
function _M:tl_ops_sync_timer_start( )
    local lock_key = "tl_ops_sync_lock"
    local lock_time = 5
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    local ok, _ = ngx.timer.at(0, tl_ops_sync_timer, nil)
	if not ok then
		tlog:err("tl_ops_sync_timer start failed to run , create timer failed " ,_)
		return nil
    end
end


function _M:new()
	return setmetatable({}, mt)
end

return _M
