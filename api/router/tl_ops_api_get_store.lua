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

local store_list = {
    "tl-ops-balance-api","tl-ops-balance-body","tl-ops-balance-cookie",
    "tl-ops-balance-header","tl-ops-balance-param","tl-ops-service",
    "tl-ops-health","tl-ops-plugins-manage","tl-ops-limit",
    "tl-ops-balance","tl-ops-waf","tl-ops-waf-api", "tl-ops-waf-ip",
    "tl-ops-waf-header","tl-ops-waf-param","tl-ops-waf-cookie","tl-ops-waf-cc",
    "tl-ops-auth","tl-ops-time-alert","tl-ops-ssl","tl-ops-page-proxy"
}

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
    ngx.req.read_body()
    local args = ngx.req.get_post_args()

    local page = args.page
    if not page then
        page = 1
    end
    page = tonumber(page)

    local limit = args.limit
    if not limit then
        limit = #store_list
    end
    limit = tonumber(limit)

    local start = (page - 1) * limit + 1
    local tail = page * limit

    local res_data = { 
        count = #store_list,
        list = {}
    }

    for index, value in ipairs(store_list) do
        if index >= start and index <= tail then
            local name = value .. ".tlstore";
            local content, size = read(name);
            if not content then
                content = {}
            end
            table.insert(res_data.list, {
                id = index,
                name = value .. ".tlstore",
                size = size,
                version = "暂不统计",
                list = content,
            })
        end
    end

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
 end


return Router
