
# WAF统计

WAF统计，是在WAF模块上扩充的一种功能，在服务进行WAF逻辑拦截请求时，可能存在拦截成功，或通过，有些情况下可能需要统计WAF情况进行展示。在此需求下，用定时任务实现了统计WAF数据。


```lua
# 代码位置 : conf/tl_ops_manage.conf

init_worker_by_lua_block {
	tlops:tl_ops_process_init_worker();
}


# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init_worker()
    ...

    -- 启动waf统计
	m_waf_count:init();
    
    ...
end
```

我们可以看到主入口在 `init_worker_by_lua_block` 中调用了定时任务启动器。

关于WAF统计启动器主要逻辑如下，大家可以看到这里有加锁操作，因为在启动时存在多worker抢占执行，而统计只需要一个worker执行即可。

获取到锁后，先获取所有服务节点，对服务层级，全局层级的各种规则下的WAF情况进行记录，放置在list中并持久化到store文件中（为避免过多内存暂用，所以只用store持久即可）

```lua
# 代码位置 : waf/count/tl_ops_waf_count_core.lua


local tl_ops_waf_count_keys = function(waf_interval_success_key, service_name, node_id)

    local req_ip_key = tl_ops_constant_waf.cache_key.req_ip
    if service_name ~= nil or node_id ~= nil then
        req_ip_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf.cache_key.req_ip, service_name, node_id)
    end
    local req_ip_count = shared:get(req_ip_key)
    if not req_ip_count then
        req_ip_count = 0
    end

    ...

    local cur_count = req_ip_count + req_api_count + req_cc_count + req_cookie_count + req_header_count + req_param_count
    if cur_count == 0 then
        tlog:dbg("waf count dont need async , cur_count=",cur_count,",service_name=",service_name,",node_id=",node_id)
    else
        -- push to list
        local key = tl_ops_utils_func:gen_node_key(waf_interval_success_key, service_name, node_id)
        local waf_interval_success = cache_waf_count:get001(key)
        if not waf_interval_success then
            waf_interval_success = {}
        else
            waf_interval_success = cjson.decode(waf_interval_success)
        end

        waf_interval_success[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
        local ok, _ = cache_waf_count:set001(key, cjson.encode(waf_interval_success))
        if not ok then
            tlog:err("waf success count async err ,key=",key,",cur_count=",cur_count,",err=",_)
        end

        -- rest cur_count
        local ok, _ = shared:set(req_ip_key, 0)
        if not ok then
            tlog:err("waf req_ip_key count reset err ,req_ip_key=",req_ip_key,",cur_count=",cur_count)
        end
        
        ...

        tlog:dbg("waf count async ok ,key=",key,",waf_interval_success=",waf_interval_success)
    end

end


-- 统计器 ： 持久化数据
local tl_ops_waf_count = function()
	local lock_key = tl_ops_constant_waf.cache_key.lock
    local lock_time = tl_ops_constant_waf.count.interval - 0.01
    if not tl_ops_utils_func:tl_ops_worker_lock(lock_key, lock_time) then
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
    local count_name = "tl-ops-waf-count-" .. tl_ops_constant_waf.count.interval;
    local cache_waf_count = require("cache.tl_ops_cache_core"):new(count_name);

    for service_name, nodes in pairs(service_list) do
        if nodes == nil then
            tlog:err("nodes nil")
            return
        end
        -- 服务级别waf
        tl_ops_waf_count_keys(tl_ops_constant_waf.cache_key.waf_interval_success, service_name, nil)
    end
    -- 全局级别waf
    tl_ops_waf_count_keys(tl_ops_constant_waf.cache_key.waf_interval_success, nil, nil)
end
```
