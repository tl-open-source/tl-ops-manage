-- sync_cluster_data
-- en : sync master data to slave
-- zn : 解析同步主节点数据到从节点
-- @author iamtsm
-- @email 1905333456@qq.com

-- cache
local cache_service             =   tlops.cache.service
local cache_limit               =   tlops.cache.limit
local cache_health              =   tlops.cache.health
local cache_balance_api         =   tlops.cache.balance_api
local cache_balance_param       =   tlops.cache.balance_param
local cache_balance_header      =   tlops.cache.balance_header
local cache_balance_cookie      =   tlops.cache.balance_cookie
local cache_balance             =   tlops.cache.balance
local cache_waf_api             =   tlops.cache.waf_api
local cache_waf_ip              =   tlops.cache.waf_ip
local cache_waf_cookie          =   tlops.cache.waf_cookie
local cache_waf_header          =   tlops.cache.waf_header
local cache_waf_cc              =   tlops.cache.waf_cc
local cache_waf_param           =   tlops.cache.waf_param
local cache_waf                 =   tlops.cache.waf
-- constant
local constant_service          =   tlops.constant.service
local constant_health           =   tlops.constant.health
local constant_limit            =   tlops.constant.limit
local constant_balance          =   tlops.constant.balance
local constant_balance_api      =   tlops.constant.balance_api
local constant_balance_param    =   tlops.constant.balance_param
local constant_balance_header   =   tlops.constant.balance_header
local constant_balance_cookie   =   tlops.constant.balance_cookie
local constant_waf              =   tlops.constant.waf
local constant_waf_ip           =   tlops.constant.waf_ip
local constant_waf_api          =   tlops.constant.waf_api
local constant_waf_cc           =   tlops.constant.waf_cc
local constant_waf_header       =   tlops.constant.waf_header
local constant_waf_cookie       =   tlops.constant.waf_cookie
local constant_waf_param        =   tlops.constant.waf_param
-- utils
local utils                     =   tlops.utils
local nx_socket					=   ngx.socket.tcp
local tl_ops_rt                 =   tlops.constant.comm.tl_ops_rt
local cjson                     =   require("cjson.safe")
cjson.encode_empty_table_as_object(false)
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync_cluster_data");

local _M = {
    _VERSION = '0.01'
}


-- service配置数据
local parse_sync_cluster_data_service = function (all)
    for cache_key , ccontent in pairs(all) do
        local res, _ = cache_service:set(cache_key, cjson.encode(content))
        if not res then
            tlog:err("parse_sync_cluster_data_service  err, res=",res, ",cache_key=",cache_key,",content=",content)
            break
        end
    end

    return true
end


-- limit配置数据
local parse_sync_cluster_data_limit = function (all)
    for cache_key , ccontent in pairs(all) do
        local res, _ = cache_limit:set(cache_key, cjson.encode(content))
        if not res then
            tlog:err("parse_sync_cluster_data_limit  err, res=",res, ",cache_key=",cache_key,",content=",content)
            break
        end
    end

    return true
end

-- balance配置数据
local parse_sync_cluster_data_balance = function (all)
    for cache_key , ccontent in pairs(all) do
        local res, _ = cache_balance:set(cache_key, cjson.encode(content))
        if not res then
            tlog:err("parse_sync_cluster_data_balance  err, res=",res, ",cache_key=",cache_key,",content=",content)
            break
        end
    end

    return true
end


-- waf配置数据
local parse_sync_cluster_data_waf = function (all)
    for cache_key , ccontent in pairs(all) do
        local res, _ = cache_waf:set(cache_key, cjson.encode(content))
        if not res then
            tlog:err("parse_sync_cluster_data_waf  err, res=",res, ",cache_key=",cache_key,",content=",content)
            break
        end
    end

    return true
end

-- health配置数据
local parse_sync_cluster_data_health = function (content)
    local content = nil

    local data_str, _ = cache_health:get(constant_health.cache_key.options_list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end


-- api配置数据
local parse_sync_cluster_data_balance_api = function (content)
    local res, _ = cache_balance_api:set(constant_balance_api.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_balance_api  err, res=",res)
        return false
    end
    return true
end

-- cookie配置数据
local parse_sync_cluster_data_balance_cookie = function (content)
    local res, _ = cache_balance_cookie:set(constant_balance_cookie.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_balance_cookie  err, res=",res)
        return false
    end
    return true
end

-- header配置数据
local parse_sync_cluster_data_balance_header = function (content)
    local res, _ = cache_balance_header:set(constant_balance_header.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_balance_header  err, res=",res)
        return false
    end
    return true
end

-- param配置数据
local parse_sync_cluster_data_balance_param = function (content)
    local res, _ = cache_balance_param:set(constant_balance_param.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_balance_param  err, res=",res)
        return false
    end
    return true
end

-- waf ip配置数据
local parse_sync_cluster_data_waf_ip = function (content)
    local res, _ = cache_waf_ip:set(constant_waf_ip.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_waf_ip  err, res=",res)
        return false
    end
    return true
end

-- waf api配置数据
local parse_sync_cluster_data_waf_api = function (content)
    local res, _ = cache_waf_api:set(constant_waf_api.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_waf_api  err, res=",res)
        return false
    end
    return true
end

-- waf cookie配置数据
local parse_sync_cluster_data_waf_cookie = function (content)
    local res, _ = cache_waf_cookie:set(constant_waf_cookie.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_waf_cookie  err, res=",res)
        return false
    end
    return true
end

-- waf header配置数据
local parse_sync_cluster_data_waf_header = function (content)
    local res, _ = cache_waf_header:set(constant_waf_header.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_waf_header  err, res=",res)
        return false
    end
    return true
end

-- waf param配置数据
local parse_sync_cluster_data_waf_param = function (content)
    local res, _ = cache_waf_param:set(constant_waf_param.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_waf_param  err, res=",res)
        return false
    end
    return true
end

-- waf cc配置数据
local parse_sync_cluster_data_waf_cc = function (content)
    local res, _ = cache_waf_cc:set(constant_waf_cc.cache_key.list, cjson.encode(content))
    if not res then
        tlog:err("parse_sync_cluster_data_waf_cc  err, res=",res)
        return false
    end
    return true
end


-- 获取某个插件
local parse_sync_cluster_data_get_plugin = function(name)
    for i = 1, #tlops.plugins do
        local plugin = tlops.plugins[i]
        if plugin.name == name then
            return plugin
        end
    end
    return nil
end

-- 获取插件同步数据
local parse_sync_cluster_data_plugin = function (module, content)
    local res = nil
    
    local plugin = parse_sync_cluster_data_get_plugin(module)
    if not plugin then
        tlog:err("parse_sync_cluster_data_plugin not plugin, module=",module)
        return nil
    end

    if type(plugin.func.parse_sync_cluster_data) == 'function' then
        res, _ = plugin.func:parse_sync_cluster_data(content)
        if not res then
            tlog:err("parse_sync_cluster_data_plugin err, module=",module, ",res=",res,",err=",_)
            return nil
        end
    end

    tlog:dbg("parse_sync_cluster_data_plugin done, module=",module,",res=",res)

    return res
end


-- 解析心跳数据接口
function _M:parse_sync_cluster_data_module( sync_content )
    
    for i = 1, #sync_content do
        local module_data = sync_content[i]
        local res = ""
        if module_data.module == 'balance_api' then
            res = parse_sync_cluster_data_balance_api(module_data.content)
        elseif module_data.module == 'balance_cookie' then
            res = parse_sync_cluster_data_balance_cookie(module_data.content)
        elseif module_data.module == 'balance_header' then
            res = parse_sync_cluster_data_balance_header(module_data.content)
        elseif module_data.module == 'balance_param' then
            res = parse_sync_cluster_data_balance_param(module_data.content)
        elseif module_data.module == 'waf_api' then
            res = parse_sync_cluster_data_waf_api(module_data.content)
        elseif module_data.module == 'waf_ip' then
            res = parse_sync_cluster_data_waf_ip(module_data.content)
        elseif module_data.module == 'waf_header' then
            res = parse_sync_cluster_data_waf_header(module_data.content)
        elseif module_data.module == 'waf_cookie' then
            res = parse_sync_cluster_data_waf_cookie(module_data.content)
        elseif module_data.module == 'waf_param' then
            res = parse_sync_cluster_data_waf_param(module_data.content)
        elseif module_data.module == 'waf_cc' then
            res = parse_sync_cluster_data_waf_cc(module_data.content)
        else
            -- plugin
            res = parse_sync_cluster_data_plugin( module_data.module, module_data.content )
        end

        tlog:dbg("parse_sync_cluster_data_module module=",module_data.module,",res=",res)
    end

    return true
end



return _M