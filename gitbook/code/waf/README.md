# WAF防护

waf防护其本质是对非法流量的过滤，其对应的策略有多种。如CC攻击防护，Sql注入，非法参数拼接，伪造请求等，对于这些非正常流量，不能直接打到我们自己的业务服务中。

对此，tl-ops-manage提供了多种waf防护策略，如 多规则过滤，黑白名单。同时对于被waf拦截的请求返回自定义的错误码和内容


## 规则预热

    对于waf逻辑而言，其核心在于规则的匹配，waf作为流量的入口，应该保持高性能，所以规则的加载和匹配不能阻塞请求的分发，在tl-ops-manage中，由于数据都是存在store文件, (或者redis中)。在实际启动后，对于数据的加载每次都要访问磁盘IO，对性能会有极大的影响，所以tl-ops-manage提供了数据同步和预热功能，只需开启 `sync` 插件即可。

开启后会在启动时执行一次数据同步，并将磁盘数据加载进入shared:dict共享内存中。


## waf规则

```lua
# 代码位置 : conf/tl_ops_manage.conf

location / {
	...
    rewrite_by_lua_block {
        tlops:tl_ops_process_init_rewrite();
    }
}

# 代码位置 : tl_ops_manage.lua

function _M:tl_ops_process_init_rewrite()
	...
	
    -- 启动全局WAF
    m_waf:init_global(ngx.ctx);

    ...
end
```

可以看到核心逻辑在 `init` 方法，我们直接进入init方法的核心流程 `tl_ops_waf_global_core` 查看，核心流程遵循上面说到的waf执行链，如果某个执行链没有通过，也就是返回false，便会返回对应的自定义配置码。

同时可以看到在被waf拦截后，会对请求头写入一个 `Tl-Waf-Mode`的标志，用于区分/调试等用处


```lua
# 代码位置 : waf/tl_ops_waf.lua


-- 全局waf核心流程
function _M:tl_ops_waf_global_core()

	-- 关闭
	if not tl_ops_manage_env.waf.open then
		return true
	end

	local waf = tl_ops_waf_core_ip.tl_ops_waf_core_ip_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_ip)
		tl_ops_err_content:err_content_rewrite_to_waf("g-ip", tl_ops_constant_waf.cache_key.waf_ip)
        return
	end

	waf = tl_ops_waf_core_api.tl_ops_waf_core_api_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_api)
		tl_ops_err_content:err_content_rewrite_to_waf("g-api", tl_ops_constant_waf.cache_key.waf_api)
        return
	end

	waf = tl_ops_waf_core_cc.tl_ops_waf_core_cc_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_cc)
		tl_ops_err_content:err_content_rewrite_to_waf("g-cc", tl_ops_constant_waf.cache_key.waf_cc)
        return
	end

	waf = tl_ops_waf_core_header.tl_ops_waf_core_header_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_header)
		tl_ops_err_content:err_content_rewrite_to_waf("g-header", tl_ops_constant_waf.cache_key.waf_header)
        return
	end

	waf = tl_ops_waf_core_cookie.tl_ops_waf_core_cookie_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_cookie)
		tl_ops_err_content:err_content_rewrite_to_waf("g-cookie", tl_ops_constant_waf.cache_key.waf_cookie)
        return
	end

	waf = tl_ops_waf_core_param.tl_ops_waf_core_param_filter_global_pass()
	if not waf then
		tl_ops_waf_count:tl_ops_waf_count_incr_key(tl_ops_constant_waf.cache_key.req_param)
		tl_ops_err_content:err_content_rewrite_to_waf("g-param", tl_ops_constant_waf.cache_key.waf_param)
        return
	end

	return true
end

```
