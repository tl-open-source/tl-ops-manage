-- tl_ops_api
-- en : get share dict state
-- zn : 获取share dict状态
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_rt         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local balance_shared    = ngx.shared.tlopsbalance
local plugin_shared     = ngx.shared.tlopsplugin
local waf_shared        = ngx.shared.tlopswaf
local cache_shared      = ngx.shared.tlopscache
local cjson             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function()

    local res_data = {}

    local args = ngx.req.get_uri_args()

    local type = args.type

    if not type then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error, "type nil");
        return
    end

    if type and type == 'balance' then
        res_data = {
            free_space = balance_shared:free_space(),
            capacity = balance_shared:capacity(),
            keys = balance_shared:get_keys(),
        }
    end

    if type and type == 'waf' then
        res_data = {
            free_space = waf_shared:free_space(),
            capacity = waf_shared:capacity(),
            keys = waf_shared:get_keys(),
        }
    end

    if type and type == 'plugin' then
        res_data = {
            free_space = plugin_shared:free_space(),
            capacity = plugin_shared:capacity(),
            keys = plugin_shared:get_keys(),
        }
    end

    if type and type == 'cache' then
        res_data = {
            free_space = cache_shared:free_space(),
            capacity = cache_shared:capacity(),
            keys = cache_shared:get_keys(),
        }
    end

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router
