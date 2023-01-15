-- sync_cluster_data
-- en : sync master data to slave
-- zn : 组装同步主节点数据到从节点
-- @author iamtsm
-- @email 1905333456@qq.com

-- cache
local cache_service             =   tlops.cache.service
local cache_limit               =   tlops.cache.limit
local cache_health              =   tlops.cache.health
local cache_balance_api         =   tlops.cache.balance_api
local cache_balance_body        =   tlops.cache.balance_body
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
local cache_plugins_manage      =   tlops.cache.plugins
-- constant
local constant_service          =   tlops.constant.service
local constant_health           =   tlops.constant.health
local constant_limit            =   tlops.constant.limit
local constant_balance          =   tlops.constant.balance
local constant_balance_api      =   tlops.constant.balance_api
local constant_balance_body     =   tlops.constant.balance_body
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
local constant_plugins_manage   =   tlops.constant.plugins
-- utils
local utils                     =   tlops.utils
local cjson                     =   require("cjson.safe")
cjson.encode_empty_table_as_object(false)
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync_cluster_data");

local _M = {
    _VERSION = '0.01'
}


-- service配置数据
local get_sync_cluster_data_service = function ()
    local all = {}

    local cache_keys = {
        service_list = constant_service.cache_key.service_list,
        service_rule = constant_service.cache_key.service_rule,
    }

    for key , cache_key in pairs(cache_keys) do
        local data_str, _ = cache_service:get(cache_key);
        if not data_str then
            data_str = "{}"
        end
        
        local content = cjson.decode(data_str)

        table.insert(all, {
            key = cache_key,
            content = content
        })
    end

    return all
end


-- limit配置数据
local get_sync_cluster_data_limit = function ()
    local all = {}

    local cache_keys = {
        fuse = constant_limit.fuse.cache_key.options_list,
        token = constant_limit.token.cache_key.options_list,
        leak = constant_limit.leak.cache_key.options_list
    }

    for key , cache_key in pairs(cache_keys) do
        local data_str, _ = cache_limit:get(cache_key);
        if not data_str then
            data_str = "{}"
        end
        
        local content = cjson.decode(data_str)

        table.insert(all, {
            key = cache_key,
            content = content
        })
    end

    return all
end


-- balance配置数据
local get_sync_cluster_data_balance = function ()
    local all = {}

    local cache_keys = {
        service_empty = constant_balance.cache_key.service_empty,
        mode_empty = constant_balance.cache_key.mode_empty,
        host_empty = constant_balance.cache_key.host_empty,
        host_pass = constant_balance.cache_key.host_pass,
        token_limit = constant_balance.cache_key.token_limit,
        leak_limit = constant_balance.cache_key.leak_limit,
        offline = constant_balance.cache_key.offline,
    }

    for key , cache_key in pairs(cache_keys) do
        local data_str, _ = cache_balance:get(cache_key);
        if not data_str then
            data_str = "{}"
        end
        
        local content = cjson.decode(data_str)

        table.insert(all, {
            key = cache_key,
            content = content
        })
    end

    return all
end


-- waf配置数据
local get_sync_cluster_data_waf = function ()
    local all = {}

    local cache_keys = {
        waf_ip = constant_waf.cache_key.waf_ip,
        waf_api = constant_waf.cache_key.waf_api,
        waf_cc = constant_waf.cache_key.waf_cc,
        waf_header = constant_waf.cache_key.waf_header,
        waf_cookie = constant_waf.cache_key.waf_cookie,
        waf_param = constant_waf.cache_key.waf_param
    }

    for key , cache_key in pairs(cache_keys) do
        local data_str, _ = cache_waf:get(cache_key);
        if not data_str then
            data_str = "{}"
        end
        
        local content = cjson.decode(data_str)

        table.insert(all, {
            key = cache_key,
            content = content
        })
    end

    return all
end


-- plugins_manage 配置数据
local get_sync_cluster_data_plugins_manage = function ()
    local content = nil

    local data_str, _ = cache_plugins_manage:get(constant_plugins_manage.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end


-- health配置数据
local get_sync_cluster_data_health = function ()
    local content = nil

    local data_str, _ = cache_health:get(constant_health.cache_key.options_list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end



-- api配置数据
local get_sync_cluster_data_balance_api = function ()
    local content = nil

    local data_str, _ = cache_balance_api:get(constant_balance_api.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- post body配置数据
local get_sync_cluster_data_balance_body = function ()
    local content = nil

    local data_str, _ = cache_balance_body:get(constant_balance_body.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- cookie配置数据
local get_sync_cluster_data_balance_cookie = function ()
    local content = nil

    local data_str, _ = cache_balance_cookie:get(constant_balance_cookie.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- header配置数据
local get_sync_cluster_data_balance_header = function ()
    local content = nil

    local data_str, _ = cache_balance_header:get(constant_balance_header.cache_key.list);
    if not data_str then
        data_str = "{}"
    end

    content = cjson.decode(data_str)

    return content
end

-- param配置数据
local get_sync_cluster_data_balance_param = function ()
    local content = nil

    local data_str, _ = cache_balance_param:get(constant_balance_param.cache_key.list);
    if not data_str then
        data_str = "{}"
    end

    content = cjson.decode(data_str)

    return content
end


-- waf ip配置数据
local get_sync_cluster_data_waf_ip = function ()
    local content = nil

    local data_str, _ = cache_waf_ip:get(constant_waf_ip.cache_key.list);
    if not data_str then
        data_str = "{}"
    end

    content = cjson.decode(data_str)

    return content
end

-- waf api配置数据
local get_sync_cluster_data_waf_api = function ()
    local content = nil

    local data_str, _ = cache_waf_api:get(constant_waf_api.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- waf cookie配置数据
local get_sync_cluster_data_waf_cookie = function ()
    local content = nil

    local data_str, _ = cache_waf_cookie:get(constant_waf_cookie.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- waf header配置数据
local get_sync_cluster_data_waf_header = function ()
    local content = nil

    local data_str, _ = cache_waf_header:get(constant_waf_header.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- waf param配置数据
local get_sync_cluster_data_waf_param = function ()
    local content = nil

    local data_str, _ = cache_waf_param:get(constant_waf_param.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end

-- waf cc配置数据
local get_sync_cluster_data_waf_cc = function ()
    local content = nil

    local data_str, _ = cache_waf_cc:get(constant_waf_cc.cache_key.list);
    if not data_str then
        data_str = "{}"
    end
    
    content = cjson.decode(data_str)

    return content
end


-- 获取某个插件
local get_sync_cluster_data_get_plugin = function(name)
    for i = 1, #tlops.plugins do
        local plugin = tlops.plugins[i]
        if plugin.name == name then
            return plugin
        end
    end
    return nil
end


-- 获取插件同步数据
local get_sync_cluster_data_plugin = function (module)
    local content = nil
    
    local plugin = get_sync_cluster_data_get_plugin(module)
    if not plugin then
        tlog:err("get_sync_cluster_data_plugin not plugin, module=",module)
        return nil
    end

    if type(plugin.func.get_sync_cluster_data) == 'function' then
        content, _ = plugin.func:get_sync_cluster_data()
        if not content then
            tlog:err("get_sync_cluster_data_plugin err, module=",module, ",content=",content,",err=",_)
            return nil
        end
    end

    tlog:dbg("get_sync_cluster_data_plugin done, module=",module,",content=",content)

    return content
end


-- 获取心跳数据接口
function _M:get_sync_cluster_data_module( modules )

    local sync_content = utils:new_tab(#modules, 0)
    
    for i = 1, #modules do
        local content = nil
        if modules[i] == 'balance_api' then
            content = get_sync_cluster_data_balance_api()
        elseif modules[i] == 'balance_body' then
            content = get_sync_cluster_data_balance_body()
        elseif modules[i] == 'balance_cookie' then
            content = get_sync_cluster_data_balance_cookie()
        elseif modules[i] == 'balance_header' then
            content = get_sync_cluster_data_balance_header()
        elseif modules[i] == 'balance_param' then
            content = get_sync_cluster_data_balance_param()
        elseif modules[i] == 'waf_api' then
            content = get_sync_cluster_data_waf_api()
        elseif modules[i] == 'waf_ip' then
            content = get_sync_cluster_data_waf_ip()
        elseif modules[i] == 'waf_header' then
            content = get_sync_cluster_data_waf_header()
        elseif modules[i] == 'waf_cookie' then
            content = get_sync_cluster_data_waf_cookie()
        elseif modules[i] == 'waf_param' then
            content = get_sync_cluster_data_waf_param()
        elseif modules[i] == 'waf_cc' then
            content = get_sync_cluster_data_waf_cc()
        elseif modules[i] == 'balance' then
            content = get_sync_cluster_data_balance()
        elseif modules[i] == 'waf' then
            content = get_sync_cluster_data_waf()
        elseif modules[i] == 'service' then
            content = get_sync_cluster_data_service()
        elseif modules[i] == 'health' then
            content = get_sync_cluster_data_health()
        elseif modules[i] == 'limit' then
            content = get_sync_cluster_data_limit()
        elseif modules[i] == 'plugins_manage' then
            content = get_sync_cluster_data_plugins_manage()
        else
            -- plugin
            content = get_sync_cluster_data_plugin(modules[i] )
        end

        table.insert(sync_content, {
            module = modules[i],
            content = content
        })
    end

    return cjson.encode(sync_content)
end



return _M