
# WAF统计

WAF统计，是在WAF模块上扩充的一种功能，在服务进行WAF逻辑拦截请求时，可能存在拦截成功，或通过，有些情况下可能需要统计WAF情况进行展示。在此需求下，用定时任务实现了统计WAF数据。

为了更直观的统计各种WAF拦截情况，除了以前的WAF成功的统计数据，目前已经支持统计多个维度下的WAF拦截详情

`api-WAF策略`，`cc-WAF策略`，`cookie-WAF策略`，`param-WAF策略`，`header-WAF策略`，`ip-WAF策略`，

之前针对节点汇总级别的WAF成功统计归类到 `service级别统计`，独立于以上几个维度，方便统计

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

获取到锁后，统计不同维度下的WAF拦截详情，记录时间，统计次数，放置在list中并持久化到store文件中（为避免过多内存暂用，所以只用store持久即可）

```lua
# 代码位置 : waf/count/tl_ops_waf_count_core.lua


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
```


而对于不同维度下的统计，其实原理也相对简单，这里以 `api-WAF策略` 为例进行说明

在考虑统计具体规则下的WAF情况这个点的时候，希望能够统计具体到某一个规则的负载情况，于是我将统计规则细化到具体规则id为粒度，
也就是以这四个名称凑出一个具体的规则key，统计这个key的命中次数 `tl_ops_constant_waf_count.cache_key.api_req_succ`, `service_name`, `node_id`, `id`

例如 : `tl_ops_waf_api_req_succ_订单服务_1_113123123123` : 100，
表示 : 订单服务下的节点1的id=113123123123的api维度规则的WAF拦截次数为100

和负载统计不同的是，WAF拦截统计，可以设置服务级别WAF，和全局级别WAF，所以需要补充一个全局级别的统计key

例如 : `tl_ops_waf_api_req_succ` : 100，
表示 : 全局级别下api维度WAF拦截次数为100

具体实现如下

```lua

local tl_ops_waf_count_api_core = function( service_name, node_id, id )

    local cur_count_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.api_req_succ, service_name, node_id, id)
    local cur_count = shared:get(cur_count_key)
    if not cur_count then
        cur_count = 0
    end

    if cur_count == 0 then
        tlog:dbg("waf api count dont need async , cur_count=",cur_count,",service_name=",service_name,",node_id=",node_id,",cur_count_key=",cur_count_key)
    else
        local list_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.api_counting_list, service_name, node_id, id)
        local list = cache_waf_count:get001(list_key)
        if not list then
            list = {}
        else
            list = cjson.decode(list)
        end

        list[os.date("%Y-%m-%d %H:%M:%S", ngx.now())] = cur_count
        
        local ok, _ = cache_waf_count:set001(list_key, cjson.encode(list))
        if not ok then
            tlog:err("waf api success count async err ,list_key=",list_key,",cur_count=",cur_count,",err=",_)
        end

        -- rest cur_count
        ok, _ = shared:set(cur_count_key, 0)
        if not ok then
            tlog:err("waf api succ count reset err ,cur_count_key=",cur_count_key,",cur_count=",cur_count)
        end

        tlog:dbg("waf api count async ok ,list_key=",list_key,",list=",list)
    end
end


local tl_ops_waf_count_api = function(  )

    -- 统计全局拦截
    tl_ops_waf_count_api_core();

    -- 统计规则下拦截
    local waf_list_str, _ = cache_waf_api:get(tl_ops_constant_waf_api.cache_key.list);
    if not waf_list_str or waf_list_str == nil then
        tlog:err("waf api count list nil, break")
        return;
    end

    local waf_list = cjson.decode(waf_list_str);
    if not waf_list or waf_list == nil then
        tlog:err("waf api count list decode nil, break")
        return;
    end

    for _, api in ipairs(waf_list) do
        repeat
            local id = api.id;
            local service_name = api.service;
            -- 由于暂时只支持到服务级别的waf，node_id给默认值0即可
            local node_id = 0;

            if not id then
                tlog:err("waf api count api id nil, api=",api);
                break
            end
            if not service_name then
                tlog:err("waf api count api service_name nil, api=", api);
                break
            end
            if node_id== nil or node_id == '' then
                tlog:err("waf api count api node_id nil, api=", api);
                break
            end

            tl_ops_waf_count_api_core(service_name, node_id, id)
            break
        until true
    end
end

```