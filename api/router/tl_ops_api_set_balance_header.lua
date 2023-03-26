-- tl_ops_header 
-- en : set header config list
-- zn : 更新路由header配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local snowflake                         = require("lib.snowflake");
local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-balance-header");
local tl_ops_constant_balance_header    = require("constant.tl_ops_constant_balance_header");
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local cjson                             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()
    local rule, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_header.cache_key.rule, 1);
    if not rule or rule == nil then
        return tl_ops_rt.args_error ,"bh args err1", _
    end

    if rule ~= tl_ops_constant_balance_header.rule.point and rule ~= tl_ops_constant_balance_header.rule.random then
        return tl_ops_rt.args_error ,"bh args err2", _
    end

    local rule_match_mode, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_header.cache_key.rule_match_mode, 1);
    if not rule_match_mode or rule_match_mode == nil then
        return tl_ops_rt.args_error ,"bh args err3", _
    end

    if rule_match_mode ~= tl_ops_constant_balance_header.mode.header and rule_match_mode ~= tl_ops_constant_balance_header.mode.host then
        return tl_ops_rt.args_error ,"bh args err4", _
    end

    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_header.cache_key.list, 1);
    if not list or list == nil then
        return tl_ops_rt.args_error ,"bh args err5", _
    end

    -- 获取当前策略
    local list_single = list[rule];
    if not list_single or list_single == nil then
        return tl_ops_rt.args_error ,"bh args err6", _
    end

    -- 更新生成id
    for _, header in ipairs(list_single) do
        if not header.id or header.id == nil or header.id == '' then
            header.id = snowflake.generate_id( 100 )
        end
        if not header.updatetime or header.updatetime == nil or header.updatetime == '' then
            header.updatetime = ngx.localtime()
        end
        if header.change and header.change == true then
            header.updatetime = ngx.localtime()
            header.change = nil
        end
    end

    -- 放回
    list[rule] = list_single;

    local res, _ = cache:set(tl_ops_constant_balance_header.cache_key.list, cjson.encode(list));
    if not res then
        return tl_ops_rt.error, "set list err ", _
    end

    res, _ = cache:set(tl_ops_constant_balance_header.cache_key.rule, rule);
    if not res then
        return tl_ops_rt.error, "set rule err ", _
    end

    res, _ = cache:set(tl_ops_constant_balance_header.cache_key.rule_match_mode, rule_match_mode);
    if not res then
        return tl_ops_rt.error, "set rule_match_mode err ", _
    end

    local res_data = {}
    res_data[tl_ops_constant_balance_header.cache_key.rule] = rule
    res_data[tl_ops_constant_balance_header.cache_key.rule_match_mode] = rule_match_mode
    res_data[tl_ops_constant_balance_header.cache_key.list] = list

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}