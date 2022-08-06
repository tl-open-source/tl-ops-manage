-- tl_ops_err_content
-- en : err content core api
-- zn : 自定义错误内容对外接口
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_err_content_core = require(".err.tl_ops_err_content_core");

local _M = {}


function _M:init(ctx)
    local _err = tl_ops_err_content_core:new();
    _err:tl_ops_err_content_handler()
end


-- uri重写，实现错误内容自定义
-- 重写到balance err内容处理
function _M:err_content_rewrite_to_balance(server, state, mode, err)
    ngx.req.set_uri_args({ 
        type = "balance",
        cache_key = err, 
        mode = mode, 
        state = state, 
        server = server
    })
    ngx.req.set_uri("/balanceerr/", true)
end


--uri重写，实现错误内容自定义
-- 重写到waf err内容处理
function _M:err_content_rewrite_to_waf( mode, err )
    ngx.req.set_uri_args({  
		type = "waf",
		cache_key = err,
		mode = mode
	})
    ngx.req.set_uri("/waferr/", true)
end


return _M