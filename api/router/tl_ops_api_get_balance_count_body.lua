-- tl_ops_api
-- en : get balance body count data list
-- zn : 获取路由负载详情列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-balance-count");
local cache_balance_body                = require("cache.tl_ops_cache_core"):new("tl-ops-balance-body")
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local tl_ops_constant_balance_body      = require("constant.tl_ops_constant_balance_body")
local tl_ops_constant_balance_count     = require("constant.tl_ops_constant_balance_count")
local cjson                             = require("cjson.safe"); 
cjson.encode_empty_table_as_object(false)

local Router = function()

    -- 支持只获取某个服务节点的路由规则统计
    local args = ngx.req.get_uri_args()
    local args_service = args['service']
    local args_node = args['node']
    args_node = tonumber(args_node)
   
    local rule, _ = cache_balance_body:get(tl_ops_constant_balance_body.cache_key.rule);
    if not rule or rule == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err1", _);
        return;
    end
    
    local list_str, _ = cache_balance_body:get(tl_ops_constant_balance_body.cache_key.list);
    if not list_str or list_str == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err2", _);
        return;
    end

    local list = cjson.decode(list_str);
    if not list or list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err3", _);
        return;
    end

    local body_rule_list = list[rule];
    if not body_rule_list or body_rule_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err4", _);
        return;
    end

    local res_data = {}

    for _, body in ipairs(body_rule_list) do
        repeat
            local id = body.id;
            local service_name = body.service;
            local node_id = body.node;

            if not id then
                break
            end
            if not service_name then
                break
            end
            if rule == tl_ops_constant_balance_body.rule.point then
                if node_id == nil or node_id == '' then
                    break
                end
            end
            
            -- 支持只获取某个服务节点的路由规则统计
            if args_service and args_service ~= service_name then
                break
            end
            if args_node ~= nil and args_node ~= "" and node_id ~= args_node then
                break
            end

            local body_counting_list = cache:get001(
                tl_ops_utils_func:gen_node_key( tl_ops_constant_balance_count.cache_key.body_counting_list, service_name, node_id, id)
            ) 
            if not body_counting_list then
                body_counting_list = "{}"
            end

            table.insert(res_data, {
                id = id,
                service_name = service_name,
                node_id = node_id,
                content = body.body,
                count_list = cjson.decode(body_counting_list)
            })
            break
        until true
    end

    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router