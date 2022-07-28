-- tl_ops_manage
-- en : core 
-- zn : 核心流程
-- @author iamtsm
-- @email 1905333456@qq.com

-- module
local m_health          =  require("health.tl_ops_health")
local m_limit_fuse      =  require("limit.fuse.tl_ops_limit_fuse")
local m_balance_count   =  require("balance.count.tl_ops_balance_count")
local m_plugin          =  require("plugins.tl_ops_plugin"):new()
local m_waf             =  require("waf.tl_ops_waf")
local m_waf_count       =  require("waf.count.tl_ops_waf_count")
local m_api             =  require("api.tl_ops_api")
local m_balance         =  require("balance.tl_ops_balance")
local m_ctx             =  require("ctx.tl_ops_ctx");
local tlog              =  require("utils.tl_ops_utils_log"):new("tl_ops_manage");
local utils             =  require("utils.tl_ops_utils_func");
local env               =  require("tl_ops_manage_env")
local constant          =  require("constant.tl_ops_constant")
local cache             =  require("cache.tl_ops_cache")
local tlops_api         =  require("api.tl_ops_api_core")
local balance_shared    =  ngx.shared.tlopsbalance
local plugin_shared     =  ngx.shared.tlopsplugin
local waf_shared        =  ngx.shared.tlopswaf


local _M = {
    env = env,
    cache = cache,
    utils = utils,
    constant = constant,
    plugins = {},
    waf_shared = waf_shared,
    plugin_shared = plugin_shared,
    balance_shared = balance_shared,
}


-- init阶段执行
function _M:tl_ops_process_init()
    -- 加载所有插件
    m_plugin:tl_ops_process_load_plugins();

    _M.plugins = m_plugin:tl_ops_process_get_plugins()
end


-- init_worker阶段执行
function _M:tl_ops_process_init_worker()
    -- 执行插件
    m_plugin:tl_ops_process_before_init_worker();

    -- 启动健康检查
	m_health:init();

	-- 启动限流熔断
	m_limit_fuse:init();

	-- 启动路由统计
    m_balance_count:init();
    
    -- 启动waf统计
	m_waf_count:init();

    -- 执行插件
    m_plugin:tl_ops_process_after_init_worker();
end


-- ssl阶段执行
function _M:tl_ops_process_init_ssl()
    -- 执行插件
    m_plugin:tl_ops_process_before_init_ssl();
    -- 执行插件
	m_plugin:tl_ops_process_after_init_ssl();
end


-- rewrite阶段执行
function _M:tl_ops_process_init_rewrite()
    -- 执行插件
    m_plugin:tl_ops_process_before_init_rewrite();
    -- 执行插件
	m_plugin:tl_ops_process_after_init_rewrite();    
end


-- access阶段执行
function _M:tl_ops_process_init_access()
    -- 初始化ctx
    m_ctx:init();
    
    -- 执行插件
    m_plugin:tl_ops_process_before_init_access(ngx.ctx);

    -- 启动waf
    m_waf:init_global(ngx.ctx);

    -- 加载api
    m_api:init(ngx.ctx);

    -- 执行插件
	m_plugin:tl_ops_process_after_init_access(ngx.ctx);
end


-- balance
function _M:tl_ops_process_init_balancer()
    -- 启动负载均衡
    m_balance:init(ngx.ctx);
end


-- content阶段执行
function _M:tl_ops_process_init_content()
    -- 执行插件
	m_plugin:tl_ops_process_before_init_content(ngx.ctx); 
    -- 执行插件
	m_plugin:tl_ops_process_after_init_content(ngx.ctx);
end


-- header阶段执行
function _M:tl_ops_process_init_header()
    -- 执行插件
	m_plugin:tl_ops_process_before_init_header(ngx.ctx);    
    -- 执行插件
	m_plugin:tl_ops_process_after_init_header(ngx.ctx);
end


-- body阶段执行
function _M:tl_ops_process_init_body()
    -- 执行插件
	m_plugin:tl_ops_process_before_init_body(ngx.ctx);    
    -- 执行插件
	m_plugin:tl_ops_process_after_init_body(ngx.ctx);
end


-- log阶段执行
function _M:tl_ops_process_init_log()
    -- 执行插件
	m_plugin:tl_ops_process_before_init_log(ngx.ctx);    
    -- 执行插件
	m_plugin:tl_ops_process_after_init_log(ngx.ctx);
end


return _M
