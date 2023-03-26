
# 路由统计

路由统计，是在负载均衡模块上扩充的一种功能，在服务进行负载逻辑时，可能存在负载成功，或失败，有些情况下可能需要统计负载情况进行展示。在此需求下，用定时任务实现了统计负载数据。

为了更直观的统计各种路由请求情况，除了以前的路由成功或失败的统计数据，目前已经支持统计多个维度下的路由详情

`api负载策略`，`body负载策略`，`cookie负载策略`，`param负载策略`，`header负载策略`，`node级别统计`，

之前的负载成功和失败统计归类到 `node级别统计`，独立于以上几个维度，方便统计


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

获取到锁后，统计不同维度下的路由详情，记录时间，统计次数，放置在list中并持久化到store文件中（为避免过多内存暂用，所以只用store持久即可）

```lua
# 代码位置 : balance/count/tl_ops_balance_count_core.lua

-- 统计器 ： 持久化数据
local tl_ops_balance_count = function()
    local lock_key = tl_ops_constant_balance_count.cache_key.lock
    local lock_time = tl_ops_constant_balance_count.interval - 0.01
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

```

而对于不同维度下的统计，其实原理也相对简单，这里以 `api负载策略` 为例进行说明

在考虑统计具体规则下的负载情况这个点的时候，希望能够统计具体到某一个规则的负载情况，于是我将统计规则细化到具体规则id为粒度，
也就是以这四个名称凑出一个具体的规则key，统计这个key的命中次数 `tl_ops_constant_balance_count.cache_key.api_req_succ`, `service_name`, `node_id`, `id`

例如 : `tl_ops_balance_api_req_succ_订单服务_1_113123123123` : 100，
表示 : 订单服务下的节点1的id=113123123123的api维度规则的负载次数为100

具体实现如下

```lua

-- 以api为粒度统计
local tl_ops_balance_count_api = function( )

    local rule, _ = cache_balance_api:get(tl_ops_constant_balance_api.cache_key.rule);
    if not rule or rule == nil then
        tlog:err("balance api count rule nil, break")
        return;
    end
    
    local list_str, _ = cache_balance_api:get(tl_ops_constant_balance_api.cache_key.list);
    if not list_str or list_str == nil then
        tlog:err("balance api count list nil, break")
        return;
    end

    local list = cjson.decode(list_str);
    if not list or list == nil then
        tlog:err("balance api count list decode nil, break")
        return;
    end

    local api_rule_list = list[rule];
    if not api_rule_list or api_rule_list == nil then
        tlog:err("balance api count api_rule_list nil, break")
        return;
    end

    for _, api in ipairs(api_rule_list) do
        repeat
            local id = api.id;
            local service_name = api.service;
            local node_id = api.node;

            if not id then
                tlog:err("balance api count api id nil, api=",api);
                break
            end
            if not service_name then
                tlog:err("balance api count api service_name nil, api=", api);
                break
            end
            if rule == tl_ops_constant_balance_api.rule.point then
                if node_id == nil or node_id == '' then
                    tlog:err("balance api count api node_id nil, api=", api);
                    break
                end
            end

            local cur_count_key = tl_ops_utils_func:gen_node_key( tl_ops_constant_balance_count.cache_key.api_req_succ, service_name, node_id, id)
            local cur_succ_count = shared:get(cur_count_key)
            if not cur_succ_count then
                cur_succ_count = 0
            end

            if cur_succ_count == 0 then
                tlog:dbg("balance api count not need sync , succ=",cur_succ_count,",rule=",rule,",id=",id);
            else
                -- push to list
                local counting_list_key = tl_ops_utils_func:gen_node_key( tl_ops_constant_balance_count.cache_key.api_counting_list, service_name, node_id, id)
                local counting_list = cache_balance_count:get001(counting_list_key)
                if not counting_list then
                    counting_list = {}
                else
                    counting_list = cjson.decode(counting_list)
                end

                counting_list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_succ_count

                local ok, _ = cache_balance_count:set001(counting_list_key, cjson.encode(counting_list))
                if not ok then
                    tlog:err("balance api success count async err ,counting_list_key=",counting_list_key,",cur_succ_count=",cur_succ_count,",err=",_)
                end

                -- rest cur_succ_count
                ok, _ = shared:set(cur_count_key, 0)
                if not ok then
                    tlog:err("balance api success count reset err ,cur_count_key=",cur_count_key,",cur_succ_count=",cur_succ_count,",err=",_)
                end

                tlog:dbg("balance api count async ok ,counting_list_key=",counting_list_key,",counting_list=",counting_list)
            end

            break
        until true
    end
end

```