-- tl_ops_plugin_page_proxy
-- en : page_proxy  
-- zn : 页面转发插件
-- @author iamtsm
-- @email 1905333456@qq.com

local utils                 = tlops.utils
local env                   = tlops.env
local sync                  = require("plugins.tl_ops_page_proxy.sync");

local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }


function _M:new(options)
    if not options then
        options = {}
    end
    return setmetatable(options, mt)
end


-- 页面转发插件实现
function _M:tl_ops_process_before_init_rewrite(ctx)

    local request_uri = utils:get_req_uri()

    if ngx.re.find(request_uri, "/tlopsmanage/", 'jo') then
        ngx.var.tlopsmanage = env.path.tlopsmanage
    end

    if ngx.re.find(request_uri, "/website/", 'jo') then
        ngx.var.website = env.path.website
    end

    return true, "ok"
end


-- 插件数据同步
function _M:sync_data()
    return sync.sync_data()
end


-- 插件数据字段同步
function _M:sync_fields()
    return sync.sync_fields()
end


return _M
