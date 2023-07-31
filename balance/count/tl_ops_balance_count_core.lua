-- tl_ops_balance_count
-- en : balance count state
-- zn : 路由次数统计器实现
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog                          = require("utils.tl_ops_utils_log"):new("tl_ops_balance_count")
local tl_ops_manage_env             = require("tl_ops_manage_env")
local count_node                    = require("balance.count.tl_ops_balance_count_node")
local count_api                     = require("balance.count.tl_ops_balance_count_api")
local count_body                    = require("balance.count.tl_ops_balance_count_body")
local count_cookie                  = require("balance.count.tl_ops_balance_count_cookie")
local count_header                  = require("balance.count.tl_ops_balance_count_header")
local count_param                   = require("balance.count.tl_ops_balance_count_param")
local tl_ops_utils_func             = require("utils.tl_ops_utils_func")
local tl_ops_constant_balance_count = require("constant.tl_ops_constant_balance_count");


local _M = {
    _VERSION = '0.02',
}
local mt = { __index = _M }


-- 需要提前定义，定时器访问不了
local tl_ops_balance_count_timer


-- 统计器 ： 持久化数据
local tl_ops_balance_count = function()
    local lock_key = tl_ops_constant_balance_count.cache_key.lock
    local lock_time = tl_ops_manage_env.balance.counting_interval - 0.01
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    -- 处理命中节点的统计
    count_node.tl_ops_balance_count_node();

    -- 处理命中api的统计
    count_api.tl_ops_balance_count_api();

    -- 处理命中param的统计
    count_param.tl_ops_balance_count_param();

    -- 处理命中body的统计
    count_body.tl_ops_balance_count_body();

    -- 处理命中header的统计
    count_header.tl_ops_balance_count_header();

    -- 处理命中cookie的统计
    count_cookie.tl_ops_balance_count_cookie();
end


-- 统计balance次数周期默认为5min，可调整配置
tl_ops_balance_count_timer = function(premature, args)
	if premature then
        tlog:err("premature")
		return
    end

	local ok, _ = pcall(tl_ops_balance_count)
	if not ok then
		tlog:err("failed to pcall : " ,  _)
    end

	local ok, _ = ngx.timer.at(tl_ops_manage_env.balance.counting_interval, tl_ops_balance_count_timer, args)
	if not ok then
		tlog:err("failed to create timer: " , _)
    end

end

-- 启动
function _M:tl_ops_balance_count_timer_start() 
    if not tl_ops_manage_env.balance.counting then
        tlog:err("balance counting not open " ,_)
        return
    end

	local ok, _ = ngx.timer.at(0, tl_ops_balance_count_timer, nil)
	if not ok then
		tlog:err("failed to run default args , create timer failed " ,_)
		return nil
    end
end


function _M:new()
	return setmetatable({}, mt)
end


return _M