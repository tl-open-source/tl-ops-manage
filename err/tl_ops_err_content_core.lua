-- tl_ops_err_content
-- en : err content state
-- zn : 自定义错误内容
-- @author iamtsm
-- @email 1905333456@qq.com
      
local cjson                 = require("cjson.safe");
local tl_ops_utils_func     = require("utils.tl_ops_utils_func");
local cache_balance         = require("cache.tl_ops_cache_core"):new("tl-ops-balance");
local cache_waf             = require("cache.tl_ops_cache_core"):new("tl-ops-waf");


local _M = {
    _VERSION = '0.02',
}
local mt = { __index = _M }


function _M:new()
	return setmetatable({}, mt)
end


-- 负载自定义错误内容处理逻辑
local tl_ops_err_content_balance_handler = function(args)

    ngx.header['Tl-Proxy-Server'] = args.server
    ngx.header['Tl-Proxy-State'] = args.state
    ngx.header['Tl-Proxy-Mode'] = args.mode

    local str = cache_balance:get(args.cache_key)
    if not str then
        ngx.exit(502)
        return
    end

    local data = cjson.decode(str);
    if not data and type(data) ~= 'table' then
        ngx.exit(502)
        return
    end

    tl_ops_utils_func:set_ngx_req_return_content(data.code, data.content, data.content_type)

    return
end



-- WAF自定义错误内容处理逻辑
local tl_ops_err_content_waf_handler = function(args)

    ngx.header['Tl-Waf-Mode'] = args.mode

    local str = cache_waf:get(args.cache_key)
    if not str then
        ngx.exit(502)
        return
    end

    local data = cjson.decode(str);
    if not data and type(data) ~= 'table' then
        ngx.exit(502)
        return
    end

    tl_ops_utils_func:set_ngx_req_return_content(data.code, data.content, data.content_type)

    return
end



-- 主逻辑
-- 通过在rewrite阶段重写uri到此location进行内容输出
function _M:tl_ops_err_content_handler()

    local args = ngx.req.get_uri_args()
    if not args then
        ngx.exit(502)
        return
    end

    if args.type == 'balance' then
        tl_ops_err_content_balance_handler(args)
        return
    end

    if args.type == 'waf' then
        tl_ops_err_content_waf_handler(args)
        return
    end

    ngx.exit(502)
    return
end


return _M