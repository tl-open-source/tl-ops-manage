-- tl_ops_ssl
-- en : ssl certificate
-- zn : 设置ssl证书
-- @author iamtsm
-- @email 1905333456@qq.com

local constant_ssl  = require("plugins.tl_ops_ssl.tl_ops_constant_ssl");
local tlog          = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_ssl");
local cache_ssl     = require("cache.tl_ops_cache_core"):new("tl-ops-ssl");
local shared 	    = tlops.plugin_shared
local utils         = tlops.utils
local ssl           = require("ngx.ssl")
local cjson         = require("cjson.safe")
cjson.encode_empty_table_as_object(false)

local _M = {
    _VERSION = '0.01',
}
local mt = { __index = _M }


-- 加载host的证书配置
local get_pem_key_cache = function(host)

    local list_str, _ = cache_ssl:get(constant_ssl.cache_key.list);
    if not list_str or list_str == nil then
        return nil
    end

    local list = cjson.decode(list_str)
    if not list then 
        return nil 
    end

    for i = 1, #list do
        local data = list[i]
        if data.host == host then
            return data
        end
    end

    return nil
end


-- 核心逻辑
function _M:ssl_core()

    local host = ssl.server_name()        

    local ok, err = ssl.clear_certs()
    if not ok then
        tlog:err("failed to clear existing certificates, ",err)
        return false, err
    end

    local host_pem_key = get_pem_key_cache(host)
    if not host_pem_key or not host_pem_key.pem or not host_pem_key.key then
        tlog:err("no host_pem_key ",err)
        return false, "no host_pem_key host=" .. host
    end

    local der_cert_chain, err = ssl.cert_pem_to_der(host_pem_key.pem)
    if not der_cert_chain then
        tlog:err("failed to convert certificate chain, ",err, ",pem=",host_pem_key.pem)
        return false, err
    end

    local ok, err = ssl.set_der_cert(der_cert_chain)
    if not ok then
        tlog:err("failed to set DER cert, ",err)
        return false, err
    end

    local passphrase = nil
    local der_pkey, err = ssl.priv_key_pem_to_der(host_pem_key.key, passphrase)
    if not der_pkey then
        tlog:err("failed to convert private key, ",err,",key=",host_pem_key.key)
        return false, err
    end

    local ok, err = ssl.set_der_priv_key(der_pkey)
    if not ok then
        tlog:err("failed to set DER private key, ",err)
        return false, err
    end

    tlog:dbg("ssl plugin ok, host=",host)

    return true, "ok"
end


function _M:new()
	return setmetatable({}, mt)
end

return _M