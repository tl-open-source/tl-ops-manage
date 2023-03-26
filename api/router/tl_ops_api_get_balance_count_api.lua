-- tl_ops_api 
-- en : get balance api count data list
-- zn : 获取路由负载详情列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-balance-count");
local cache_balance_api                 = require("cache.tl_ops_cache_core"):new("tl-ops-balance-api")
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_api       = require("constant.tl_ops_constant_balance_api")
local tl_ops_constant_balance_count     = require("constant.tl_ops_constant_balance_count")
local cjson                             = require("cjson.safe"); 
cjson.encode_empty_table_as_object(false)


local Handler = function()

    -- 支持只获取某个服务节点的路由规则统计
    local args = ngx.req.get_uri_args()
    local args_service = args['service']
    local args_node = args['node']
    args_node = tonumber(args_node)
   
    local rule, _ = cache_balance_api:get(tl_ops_constant_balance_api.cache_key.rule);
    if not rule or rule == nil then
        return tl_ops_rt.args_error ,"bca args err1", _
    end
    
    local list_str, _ = cache_balance_api:get(tl_ops_constant_balance_api.cache_key.list);
    if not list_str or list_str == nil then
        return tl_ops_rt.args_error ,"bca args err2", _
    end

    local list = cjson.decode(list_str);
    if not list or list == nil then
        return tl_ops_rt.args_error ,"bca args err3", _
    end

    local api_rule_list = list[rule];
    if not api_rule_list or api_rule_list == nil then
        return tl_ops_rt.args_error ,"bca args err4", _
    end

    local res_data = {}

    for _, api in ipairs(api_rule_list) do
        repeat
            local id = api.id;
            local service_name = api.service;
            local node_id = api.node;

            if not id then
                break
            end
            if not service_name then
                break
            end
            if rule == tl_ops_constant_balance_api.rule.point then
                if node_id == nil or node_id == '' then
                    break
                end
            end
            
            if args_service and args_service ~= service_name then
                break
            end
            if args_node ~= nil and args_node ~= "" and node_id ~= args_node then
                break
            end

            local api_counting_list = cache:get001(
                tl_ops_utils_func:gen_node_key( tl_ops_constant_balance_count.cache_key.api_counting_list, service_name, node_id, id)
            ) 
            if not api_counting_list then
                api_counting_list = "{}"
            end

            table.insert(res_data, {
                id = id,
                service_name = service_name,
                node_id = node_id,
                content = api.url,
                count_list = cjson.decode(api_counting_list)
            })
            break
        until true
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