-- tl_ops_manage
-- en : core 
-- zn : 核心流程
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_manage");


local _M = {}
_M._VERSION = '0.01'


-- init阶段执行
function _M:tl_ops_process_init()

end


-- init_worker阶段执行
function _M:tl_ops_process_init_worker()

    -- 启动健康检查
	require("health.tl_ops_health"):init();

	-- 启动限流熔断
	require("limit.fuse.tl_ops_limit_fuse"):init();

	-- 启动路由统计
	require("balance.count.tl_ops_balance_count"):init();
	
	-- 启动数据同步/预热
    require("sync.tl_ops_sync"):init();

    -- 加载插件
    require("tl_ops_plugin"):tl_ops_process_init_worker();

end


-- rewrite阶段执行
function _M:tl_ops_process_init_rewrite()

    -- 启动waf
    local scope = require("constant.tl_ops_constant_waf_scope");
    require("waf.tl_ops_waf"):init(scope.global);

    -- 加载插件
	require("tl_ops_plugin"):tl_ops_process_init_rewrite();

end


-- access阶段执行
function _M:tl_ops_process_init_access()
    
    -- 加载api
    require("api.tl_ops_api"):init();

    -- 启动负载均衡
    require("balance.tl_ops_balance"):init();

    -- 加载插件
	require("tl_ops_plugin"):tl_ops_process_init_access();

end



-- content阶段执行
function _M:tl_ops_process_init_content()
    
    -- 加载插件
	require("tl_ops_plugin"):tl_ops_process_init_content();

end



-- header阶段执行
function _M:tl_ops_process_init_header()
    
    -- 加载插件
	require("tl_ops_plugin"):tl_ops_process_init_header();

end


-- body阶段执行
function _M:tl_ops_process_init_body()
    
    -- 加载插件
	require("tl_ops_plugin"):tl_ops_process_init_body();

end


-- log阶段执行
function _M:tl_ops_process_init_log()
    
    -- 加载插件
	require("tl_ops_plugin"):tl_ops_process_init_log();

end



return _M
