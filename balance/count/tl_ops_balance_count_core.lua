-- tl_ops_balance_count
-- en : balance count state
-- zn : 路由次数统计器
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_balance_count");
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
local tl_ops_constant_service = require("constant.tl_ops_constant_service");
local cache_service = require("cache.tl_ops_cache"):new("tl-ops-service");
local tl_ops_manage_env = require("tl_ops_manage_env")

local lock = require("lib.lock");
local shared = ngx.shared.tlopsbalance;


local _M = {
    _VERSION = '0.02',
}
local mt = { __index = _M }


-- 需要提前定义，定时器访问不了
local tl_ops_balance_count_timer


-- 统计器加锁
local tl_ops_balance_count_lock = function()
	local ok, _ = shared:add(tl_ops_constant_balance.cache_key.lock, true, tl_ops_constant_balance.count.interval - 0.01)
	if not ok then
		if _ == "exists" then
			return nil
		end
		return nil
    end
	
	return true
end


-- 统计器 ： 持久化数据
local tl_ops_balance_count = function()
    if not tl_ops_balance_count_lock() then
        return
    end

    local service_list = nil
    local service_list_str, _ = cache_service:get(tl_ops_constant_service.cache_key.service_list);
    if not service_list_str then
        -- use default
        service_list = tl_ops_constant_service.list
    else
        service_list = cjson.decode(service_list_str);
    end
    

    -- 控制细度 ，以周期为分割，仅用store持久
    local count_name = "tl-ops-balance-count-" .. tl_ops_constant_balance.count.interval;
    local cache_balance_count = require("cache.tl_ops_cache"):new(count_name);

    for service_name, nodes in pairs(service_list) do
        if nodes == nil then
            tlog:err("nodes nil")
            return
        end
    
        for i = 1, #nodes do
            local node_id = i-1
            local cur_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_succ, service_name, node_id)
            local cur_succ_count = shared:get(cur_succ_count_key)
            if not cur_succ_count then
                cur_succ_count = 0
            end

            local cur_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.req_fail, service_name, node_id)
            local cur_fail_count = shared:get(cur_fail_count_key)
            if not cur_fail_count then
                cur_fail_count = 0
            end

            local cur_count = cur_succ_count + cur_fail_count
            if cur_count == 0 then
                tlog:err("balance count async err , succ=",cur_succ_count,",fail=",cur_fail_count,",service_name=",service_name,",node_id=",node_id)
            else
                -- push to list
                local success_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.balance_interval_success, service_name, node_id)
                local balance_interval_success = cache_balance_count:get001(success_key)
                if not balance_interval_success then
                    balance_interval_success = {}
                else
                    balance_interval_success = cjson.decode(balance_interval_success)
                end

                balance_interval_success[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
                local ok, _ = cache_balance_count:set001(success_key, cjson.encode(balance_interval_success))
                if not ok then
                    tlog:err("balance success count async err ,success_key=",success_key,",cur_count=",cur_count,",err=",_)
                end

                -- rest cur_count
                local ok, _ = shared:set(cur_succ_count_key, 0)
                if not ok then
                    tlog:err("balance succ count reset err ,success_key=",success_key,",cur_count=",cur_count)
                end
                ok, _ = shared:set(cur_fail_count_key, 0)
                if not ok then
                    tlog:err("balance fail count reset err ,success_key=",success_key,",cur_count=",cur_count)
                end

                tlog:dbg("balance count async ok ,success_key=",success_key,",balance_interval_success=",balance_interval_success)
            end
        end
    end
end



-- 统计balance次数周期默认为5min，可调整配置
tl_ops_balance_count_timer = function(premature, args)
	if premature then
		return
    end

	local ok, _ = pcall(tl_ops_balance_count)
	if not ok then
		tlog:err("failed to pcall : " ,  _)
    end

	local ok, _ = ngx.timer.at(tl_ops_constant_balance.count.interval, tl_ops_balance_count_timer, args)
	if not ok then
		tlog:err("failed to create timer: " , _)
    end

end

-- 启动
function _M:tl_ops_balance_count_timer_start() 
    if not tl_ops_manage_env.balance.open then
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