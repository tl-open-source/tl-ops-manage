-- tl_ops_api
-- en : get share dict key state
-- zn : 获取share dict key数据内容
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


local Handler = function()

    local res_data = {}

    local args = ngx.req.get_uri_args()

    local type = args.type
    if not type then
        return tl_ops_rt.args_error, "type nil"
    end

    local key = args.key

    if not key then
        return tl_ops_rt.args_error, "key nil"
    end

    if type and type == 'balance' then
        res_data = {
            value = balance_shared:get(key)
        }
    end

    if type and type == 'waf' then
        res_data = {
            value = waf_shared:get(key);
        }
    end

    if type and type == 'plugin' then
        res_data = {
            value = plugin_shared:get(key);
        }
    end

    if type and type == 'cache' then
        res_data = {
            value = cache_shared:get(key);
        }
    end

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}

