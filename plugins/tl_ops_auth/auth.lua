-- tl_ops_auth
-- en : auth impl
-- zn : 校验实现
-- @author iamtsm
-- @email 1905333456@qq.com

local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_auth")
local auth_constant     = require("plugins.tl_ops_auth.tl_ops_plugin_constant")
local login_router      = require("plugins.tl_ops_auth.login")
local cjson             = require("cjson.safe")
local shared            = tlops.plugin_shared
local utils             = tlops.utils

local _M = {
    _VERSION = '0.01'
}

local mt = { __index = _M }

function _M:new()
    return setmetatable({}, mt)
end

-- 添加登录态
function _M:auth_get_session(id)

    local key = auth_constant.cache_key.session .. id
    
    tlog:dbg("auth_get_session, key=",key)

    local value = shared:get(key)
    if not value then
        tlog:dbg("auth_get_session nil, key=",key)
        return nil
    end

    return cjson.decode(value)
end

-- 添加登录态
function _M:auth_add_session(id, user)

    local key = auth_constant.cache_key.session .. id
    local value = cjson.encode(user)
    local time = auth_constant.login.auth_time

    tlog:dbg("auth_add_session, key=",key,",value=",value,",time=",time)

    local ok, _ = shared:set(key, value, time)
    if not ok then
        tlog:dbg("auth_add_session failed, key=",key,",value=",value,",time=",time,",_=",_)
    end

    return ok
end

-- 删除登录态
function _M:auth_del_session(id)

    local key = auth_constant.cache_key.session .. id
    
    tlog:dbg("auth_del_session, key=",key)

    local ok, _ = shared:delete(key)
    if not ok then
        tlog:dbg("auth_del_session failed, key=",key)
    end

    return ok
end


local uri_in_intercept_uri = function(ctx)
    for i, intercept_uri in ipairs(auth_constant.login.intercept) do
        if ngx.re.find(ctx.request_uri, intercept_uri, 'jo') then
            return true
        end
    end
    return false
end


function _M:auth_core(ctx)

    -- 处理白名单
    for i, filter_ui in ipairs(auth_constant.login.filter) do
        if ngx.re.find(ctx.request_uri, filter_ui, 'jo') then
            return
        end
    end

    -- 处理拦截名单uri
    if not uri_in_intercept_uri(ctx) then
        return
    end

    -- cookie校验
    local cookie_utils = require("lib.cookie"):new();
    local auth_cid, _ = cookie_utils:get(auth_constant.login.auth_cid);
    if auth_cid ~= nil and auth_cid then
        local session = self:auth_get_session(auth_cid)
        if session then
            return
        end
    end

    -- header校验
    local headers = ngx.req.get_headers()
    local auth_hid = headers[auth_constant.login.auth_hid]
    if auth_hid ~= nil then
        local session = self:auth_get_session(auth_hid)
        if session then
            return
        end
    end

    tlog:dbg("req uri no auth, uri=",ctx.request_uri)

    utils:set_ngx_req_return_content(
        auth_constant.login.code, 
        auth_constant.login.content, 
        auth_constant.login.content_type
    )
    return
end



return _M