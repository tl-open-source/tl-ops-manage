-- tl_ops_page_proxy
-- en : page_proxy
-- zn : 静态页面代理实现
-- @author iamtsm
-- @email 1905333456@qq.com

local constant      = require("plugins.tl_ops_page_proxy.tl_ops_plugin_constant");
local cache         = require("cache.tl_ops_cache_core"):new("tl-ops-page-proxy");
local tlog          = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_page_proxy");
local env           = tlops.env
local cjson         = require("cjson.safe")
cjson.encode_empty_table_as_object(false)

local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 加载静态页面路由配置
local get_page_proxy_cache = function( request_uri,  api )
    local list_str, _ = cache:get(constant.cache_key.list);
    if not list_str or list_str == nil then
        return nil
    end

    local list = cjson.decode(list_str)
    if not list then 
        return nil 
    end

    for i = 1, #list do
        local data = list[i]
        if ngx.re.find(api, data.api, 'jo') then
            return data
        end
    end

    return nil
end

-- 核心逻辑
function _M:page_proxy_core(ctx)

    -- 请求uri
    local request_uri = ctx.request_uri
    -- 参数
    local args = ngx.req.get_uri_args()

    if ngx.re.find(request_uri, "/tlopsmanage/", 'jo') then
        ngx.var.tlopsmanage = env.path.tlopsmanage
        return true, "ok"
    end

    if ngx.re.find(request_uri, "/website/", 'jo') then
        ngx.var.website = env.path.website
        return true, "ok"
    end

    -- 静态页面代理路径
    if args.url then
        local match = get_page_proxy_cache(request_uri, args.url);
        if match and match.path then
            ngx.var.pageproxy = match.path .. args.url;
            tlog:dbg("page_proxy match : ",match, ", args : ", args, ",request_uri : ",request_uri)
        else 
            tlog:dbg("page_proxy not match : ",match, ", args : ", args, ",request_uri : ",request_uri)
            ngx.exit(404)
            return true, "ok"
        end
    end

    tlog:dbg("page_proxy plugin ok ")

    return true, "ok"
end


function _M:new()
	return setmetatable({}, mt)
end

return _M