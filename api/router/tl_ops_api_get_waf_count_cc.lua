-- tl_ops_api
-- en : get waf cc count data list
-- zn : 获取WAF拦截详情列表
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-waf-count");
local cache_waf_cc                      = require("cache.tl_ops_cache_core"):new("tl-ops-waf-cc")
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local tl_ops_constant_waf_cc            = require("constant.tl_ops_constant_waf_cc")
local tl_ops_constant_waf_count         = require("constant.tl_ops_constant_waf_count")
local cjson                             = require("cjson.safe"); 
cjson.encode_empty_table_as_object(false)

local Handler = function()

    -- 支持只获取某个服务节点的路由规则统计
    local args = ngx.req.get_uri_args()
    local args_service = args['service']
    local args_node = args['node']
    args_node = tonumber(args_node)

    local list_str, _ = cache_waf_cc:get(tl_ops_constant_waf_cc.cache_key.list);
    if not list_str or list_str == nil then
        return tl_ops_rt.args_error ,"bca args err1", _
    end

    local cc_rule_list = cjson.decode(list_str);
    if not cc_rule_list or cc_rule_list == nil then
        return tl_ops_rt.args_error ,"bca args err2", _
    end

    local res_data = {}

    local global_cc_counting_list = cache:get001(
        tl_ops_utils_func:gen_node_key(tl_ops_constant_waf_count.cache_key.cc_counting_list)
    ) 
    if not global_cc_counting_list then
        global_cc_counting_list = "{}"
    end

    table.insert(res_data, {
        id = "-",
        service_name = "global",
        node_id = "global",
        content = "-",
        count_list = cjson.decode(global_cc_counting_list)
    })

    for _, cc in ipairs(cc_rule_list) do
        repeat
            local id = cc.id;
            local service_name = cc.service;
            local node_id = cc.node;

            if not id then
                break
            end
            if not service_name then
                break
            end
            if node_id == nil or node_id == '' then
                break
            end

            if args_service and args_service ~= service_name then
                break
            end
            if args_node ~= nil and args_node ~= "" and node_id ~= args_node then
                break
            end

            local cc_counting_list = cache:get001(
                tl_ops_utils_func:gen_node_key( tl_ops_constant_waf_count.cache_key.cc_counting_list, service_name, node_id, id)
            ) 
            if not cc_counting_list then
                cc_counting_list = "{}"
            end

            table.insert(res_data, {
                id = id,
                service_name = service_name,
                node_id = node_id,
                content = cjson.encode({
                    time = cc.time,
                    count = cc.count
                }),
                count_list = cjson.decode(cc_counting_list)
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