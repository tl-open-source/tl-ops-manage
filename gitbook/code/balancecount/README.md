
# 路由统计

路由统计，是在负载均衡模块上扩充的一种功能，在服务进行负载逻辑时，可能存在负载成功，或失败，有些情况下可能需要统计负载情况进行展示。在此需求下，用定时任务实现了统计负载数据。


```lua
# 代码位置 : conf/tl_ops_manage.conf

init_worker_by_lua_block {
	tlops:tl_ops_process_init_worker();
}


# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init_worker()
    ...

	-- 启动路由统计
    m_balance_count:init();
    
    ...
end

```

我们可以看到主入口在 `init_worker_by_lua_block` 中调用了定时任务启动器。

关于路由统计启动器主要逻辑如下，大家可以看到这里有加锁操作，因为在启动时存在多worker抢占执行，而统计只需要一个worker执行即可。

获取到锁后，先获取所有服务节点，对所有服务节点的负载成功次数，负载失败次数，时间，进行记录，放置在list中并持久化到store文件中（为避免过多内存暂用，所以只用store持久即可）

```lua
# 代码位置 : balance/count/tl_ops_balance_count_core.lua

-- 统计器 ： 持久化数据
local tl_ops_balance_count = function()
	-- 统计器加锁
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
    local count_name = "tl-ops-balance-count-" .. tl_ops_constant_balance_count.interval;
    local cache_balance_count = require("cache.tl_ops_cache_core"):new(count_name);

    for service_name, nodes in pairs(service_list) do
        if nodes == nil then
            tlog:err("nodes nil")
            return
        end
    
        for i = 1, #nodes do
            local node_id = i-1
            local cur_succ_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.node_req_succ, service_name, node_id)
            local cur_succ_count = shared:get(cur_succ_count_key)
            if not cur_succ_count then
                cur_succ_count = 0
            end

            local cur_fail_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.node_req_fail, service_name, node_id)
            local cur_fail_count = shared:get(cur_fail_count_key)
            if not cur_fail_count then
                cur_fail_count = 0
            end

            local cur_count = cur_succ_count + cur_fail_count
            if cur_count == 0 then
                tlog:err("balance count async err , succ=",cur_succ_count,",fail=",cur_fail_count,",service_name=",service_name,",node_id=",node_id)
            else
                -- push to list
                local success_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_balance.cache_key.node_counting_list, service_name, node_id)
                local node_counting_list = cache_balance_count:get001(success_key)
                if not node_counting_list then
                    node_counting_list = {}
                else
                    node_counting_list = cjson.decode(node_counting_list)
                end

                node_counting_list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
                local ok, _ = cache_balance_count:set001(success_key, cjson.encode(node_counting_list))
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

                tlog:dbg("balance count async ok ,success_key=",success_key,",node_counting_list=",node_counting_list)
            end
        end
    end
end
```
