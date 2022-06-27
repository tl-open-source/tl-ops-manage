-- tl_ops_api 
-- en : get store data
-- zn : 获取持久化数据
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_api_store");
local tl_ops_env = require("tl_ops_manage_env")

-- 读取文件
local read = function( filename )
    local store_file_name = tl_ops_env.log.store_dir .. filename
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
        service_content = ""
    end
    local health_content, health_size = read("tl-ops-health.tlstore");
    if not health_content then
        health_content = ""
    end
    local limit_content, limit_size = read("tl-ops-limit.tlstore");
    if not limit_content then
        limit_content = {}
    end
    local balance_content, balance_size = read("tl-ops-balance.tlstore");
    if not balance_content then
        balance_content = {}
    end

    local res_data = {
        api = {
            id = 1,
            name = "tl-ops-balance-api.tlstore",
            size = api_size,
            version = #api_content/2,
            list = api_content,
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
        balance = {
            id = 8,
            name = "tl-ops-balance.tlstore",
            size = balance_size,
            version = #balance_content,
            list = balance_content,
        },
    }

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
 end
 
return Router
