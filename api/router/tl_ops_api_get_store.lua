-- tl_ops_api 
-- en : get store data
-- zn : 获取持久化数据
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_rt         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tlog              = require("utils.tl_ops_utils_log"):new("tl_ops_api_store");
local tl_ops_manage_env = require("tl_ops_manage_env")
local cjson             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


-- 读取文件
local read = function( filename )
    local store_file_name = tl_ops_manage_env.path.store .. filename
    local store_file_io, _ = io.open(store_file_name, "r")
    if not store_file_io then
        tlog:err("failed to open file in read: " .. store_file_name)
        return
    end

    store_file_io:seek("set", 0);

    local data = {}
    local content_json = store_file_io:read('*l')

    while content_json do
        local content = cjson.decode(content_json)
        table.insert(data, content)
        content_json = store_file_io:read('*l')
    end

    local size = store_file_io:seek("end");

    store_file_io:close()

    return data, size
end


local Router = function() 
    local api_content, api_size = read("tl-ops-balance-api.tlstore");
    if not api_content then
        api_content = {}
    end
    local body_content, body_size = read("tl-ops-balance-body.tlstore");
    if not body_content then
        body_content = {}
    end
    local cookie_content, cookie_size = read("tl-ops-balance-cookie.tlstore");
    if not cookie_content then
        cookie_content = {}
    end
    local header_content, header_size = read("tl-ops-balance-header.tlstore");
    if not header_content then
        header_content = {}
    end
    local param_content, param_size = read("tl-ops-balance-param.tlstore");
    if not param_content then
        param_content = {}
    end
    local service_content, service_size = read("tl-ops-service.tlstore");
    if not service_content then
        service_content = {}
    end
    local health_content, health_size = read("tl-ops-health.tlstore");
    if not health_content then
        health_content = {}
    end
    local plugins_manage_content, plugins_manage_size = read("tl-ops-plugins-manage.tlstore");
    if not plugins_manage_content then
        plugins_manage_content = ""
    end
    local limit_content, limit_size = read("tl-ops-limit.tlstore");
    if not limit_content then
        limit_content = {}
    end
    local balance_content, balance_size = read("tl-ops-balance.tlstore");
    if not balance_content then
        balance_content = {}
    end
    local waf_content, waf_size = read("tl-ops-waf.tlstore");
    if not waf_content then
        waf_content = {}
    end
    local waf_api_content, waf_api_size = read("tl-ops-waf-api.tlstore");
    if not waf_api_content then
        waf_api_content = {}
    end
    local waf_ip_content, waf_ip_size = read("tl-ops-waf-ip.tlstore");
    if not waf_ip_content then
        waf_ip_content = {}
    end
    local waf_cookie_content, waf_cookie_size = read("tl-ops-waf-cookie.tlstore");
    if not waf_cookie_content then
        waf_cookie_content = {}
    end
    local waf_param_content, waf_param_size = read("tl-ops-waf-param.tlstore");
    if not waf_param_content then
        waf_param_content = {}
    end
    local waf_header_content, waf_header_size = read("tl-ops-waf-header.tlstore");
    if not waf_header_content then
        waf_header_content = {}
    end
    local waf_cc_content, waf_cc_size = read("tl-ops-waf-cc.tlstore");
    if not waf_cc_content then
        waf_cc_content = {}
    end
    local auth, auth_size = read("tl-ops-auth.tlstore");
    if not auth then
        auth = {}
    end
    local time_alert, time_alert_size = read("tl-ops-time-alert.tlstore");
    if not time_alert then
        time_alert = {}
    end
        local time_alert, time_alert_size = read("tl-ops-time-alert.tlstore");
    if not time_alert then
        time_alert = {}
    end

    local res_data = {
        api = {
            id = 1,
            name = "tl-ops-balance-api.tlstore",
            size = api_size,
            version = #api_content/2,
            list = api_content,
        },
        body = {
            id = 1,
            name = "tl-ops-balance-body.tlstore",
            size = body_size,
            version = #body_content/2,
            list = body_content,
        },
        cookie = {
            id = 2,
            name = "tl-ops-balance-cookie.tlstore",
            size = cookie_size,
            version = #cookie_content/2,
            list = cookie_content,
        },
        header = {
            id = 3,
            name = "tl-ops-balance-header.tlstore",
            size = header_size,
            version = #header_content/2,
            list = header_content,
        },
        param = {
            id = 4,
            name = "tl-ops-balance-param.tlstore",
            size = param_size,
            version = #param_content/2,
            list = param_content,
        },
        service = {
            id = 5,
            name = "tl-ops-service.tlstore",
            size = service_size,
            version = #service_content/2,
            list = service_content,
        },
        health = {
            id = 6,
            name = "tl-ops-health.tlstore",
            size = health_size,
            version = #health_content,
            list = health_content,
        },
        limit = {
            id = 7,
            name = "tl-ops-limit.tlstore",
            size = limit_size,
            version = #limit_content/3,
            list = limit_content,
        },
        plugins_manage = {
            id = 8,
            name = "tl-ops-plugins-manage.tlstore",
            size = plugins_manage_size,
            version = #plugins_manage_content,
            list = plugins_manage_content,
        },
        balance = {
            id = 8,
            name = "tl-ops-balance.tlstore",
            size = balance_size,
            version = #balance_content,
            list = balance_content,
        },
        waf = {
            id = 9,
            name = "tl-ops-waf.tlstore",
            size = waf_size,
            version = #waf_content,
            list = waf_content,
        },
        waf_api = {
            id = 10,
            name = "tl-ops-waf-api.tlstore",
            size = waf_api_size,
            version = #waf_api_content,
            list = waf_api_content,
        },
        waf_ip = {
            id = 11,
            name = "tl-ops-waf-ip.tlstore",
            size = waf_ip_size,
            version = #waf_ip_content,
            list = waf_ip_content,
        },
        waf_cookie = {
            id = 12,
            name = "tl-ops-waf-cookie.tlstore",
            size = waf_cookie_size,
            version = #waf_cookie_content,
            list = waf_cookie_content,
        },
        waf_param = {
            id = 13,
            name = "tl-ops-waf-param.tlstore",
            size = waf_param_size,
            version = #waf_param_content,
            list = waf_param_content,
        },
        waf_header = {
            id = 14,
            name = "tl-ops-waf-header.tlstore",
            size = waf_header_size,
            version = #waf_header_content,
            list = waf_header_content,
        },
        waf_cc = {
            id = 15,
            name = "tl-ops-waf-cc.tlstore",
            size = waf_cc_size,
            version = #waf_cc_content,
            list = waf_cc_content,
        },
        auth = {
            id = 16,
            name = "tl-ops-auth.tlstore",
            size = auth_size,
            version = #auth,
            list = auth,
        },
        time_alert = {
            id = 17,
            name = "tl-ops-time-alert.tlstore",
            size = time_alert_size,
            version = #time_alert,
            list = time_alert,
        }
    }

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
 end
 
return Router
