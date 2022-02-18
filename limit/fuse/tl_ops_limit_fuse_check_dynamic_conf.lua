---- 动态配置加载器启动
local tl_ops_limit_fuse_check_dynamic_conf_add_start = function() 
	
end


---- 校验是否需要同步conf变更
local tl_ops_limit_fuse_check_dynamic_conf_change_check = function( conf )
	
end

---- 动态配置加载器启动
local tl_ops_limit_fuse_check_dynamic_conf_change_start = function( conf ) 
    if not conf then
        tlog:err("[change-check] err , conf nil")
    end
	tl_ops_limit_fuse_check_dynamic_conf_change_check(conf)
end


return {
	dynamic_conf_change_start = tl_ops_limit_fuse_check_dynamic_conf_change_start,
	dynamic_conf_add_start = tl_ops_limit_fuse_check_dynamic_conf_add_start
}