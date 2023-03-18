-- tl_ops_waf_count
-- en : waf count core impl
-- zn : waf统计实现
-- @author iamtsm
-- @email 1905333456@qq.com


local tlog                              = require("utils.tl_ops_utils_log"):new("tl_ops_waf_count")
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func")
local tl_ops_constant_waf               = require("constant.tl_ops_constant_waf")
local tl_ops_constant_waf_count         = require("constant.tl_ops_constant_waf_count")
local tl_ops_manage_env                 = require("tl_ops_manage_env")
local waf_count_ip                      = require("waf.count.tl_ops_waf_count_ip")
local waf_count_cc                      = require("waf.count.tl_ops_waf_count_cc")
local waf_count_api                     = require("waf.count.tl_ops_waf_count_api")
local waf_count_cookie                  = require("waf.count.tl_ops_waf_count_cookie")
local waf_count_header                  = require("waf.count.tl_ops_waf_count_header")
local waf_count_param                   = require("waf.count.tl_ops_waf_count_param")
local waf_count_service                 = require("waf.count.tl_ops_waf_count_service")

local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 需要提前定义，定时器访问不了
local tl_ops_waf_count_timer


-- 统计器 ： 持久化数据
local tl_ops_waf_count_core = function()
    local lock_key = tl_ops_constant_waf_count.cache_key.lock
    local lock_time = tl_ops_constant_waf_count.interval - 0.01
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
        return
    end

    -- api规则统计
    waf_count_api.tl_ops_waf_count_api();

    -- ip规则统计
    waf_count_ip.tl_ops_waf_count_ip();

    -- cc规则统计
    waf_count_cc.tl_ops_waf_count_cc();

    -- cookie规则统计
    waf_count_cookie.tl_ops_waf_count_cookie();

    -- header规则统计
    waf_count_header.tl_ops_waf_count_header();

    -- param规则统计
    waf_count_param.tl_ops_waf_count_param();

    -- 服务级别统计
    waf_count_service.tl_ops_waf_count_service();

end



-- 统计waf次数周期默认为5min，可调整配置
tl_ops_waf_count_timer = function(premature, args)
	if premature then
		return
    end

	local ok, _ = pcall(tl_ops_waf_count_core)
	if not ok then
		tlog:err("failed to pcall : " ,  _)
    end

	local ok, _ = ngx.timer.at(tl_ops_constant_waf.count.interval, tl_ops_waf_count_timer, args)
	if not ok then
		tlog:err("failed to create timer: " , _)
    end

end

-- 启动
function _M:tl_ops_waf_count_timer_start() 
    if not tl_ops_manage_env.waf.counting then
        tlog:err("waf counting not open " ,_)
        return
    end

	local ok, _ = ngx.timer.at(0, tl_ops_waf_count_timer, nil)
	if not ok then
		tlog:err("failed to run default args , create timer failed " ,_)
		return nil
    end
end


function _M:new()
	return setmetatable({}, mt)
end


return _M