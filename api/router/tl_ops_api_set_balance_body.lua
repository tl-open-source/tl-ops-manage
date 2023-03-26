-- tl_ops_body 
-- en : set body config list
-- zn : 更新路由body配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local snowflake                     = require("lib.snowflake");
local cache                         = require("cache.tl_ops_cache_core"):new("tl-ops-balance-body");
local tl_ops_constant_balance_body  = require("constant.tl_ops_constant_balance_body");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local cjson                         = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()

    local rule, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_body.cache_key.rule, 1);
    if not rule or rule == nil then
        return tl_ops_rt.args_error ,"bb args err1", _
    end

    if rule ~= tl_ops_constant_balance_body.rule.point and rule ~= tl_ops_constant_balance_body.rule.random then
        return tl_ops_rt.args_error ,"bb args err2", _
    end

    local rule_match_mode, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_body.cache_key.rule_match_mode, 1);
    if not rule_match_mode or rule_match_mode == nil then
        return tl_ops_rt.args_error ,"bb args err3", _
    end

    if rule_match_mode ~= tl_ops_constant_balance_body.mode.body and rule_match_mode ~= tl_ops_constant_balance_body.mode.host then
        return tl_ops_rt.args_error ,"bb args err4", _
    end

    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_body.cache_key.list, 1);
    if not list or list == nil then
        return tl_ops_rt.args_error ,"bb args err5", _
    end

    -- 获取当前策略
    local list_single = list[rule];
    if not list_single or list_single == nil then
        return tl_ops_rt.args_error ,"bb args err6", _
    end

    -- 更新生成id
    for _, body in ipairs(list_single) do
        if not body.id or body.id == nil or body.id == '' then
            body.id = snowflake.generate_id( 100 )
        end
        if not body.updatetime or body.updatetime == nil or body.updatetime == '' then
            body.updatetime = ngx.localtime()
        end
        if body.change and body.change == true then
            body.updatetime = ngx.localtime()
            body.change = nil
        end
    end

    -- 放回
    list[rule] = list_single;

    local res, _ = cache:set(tl_ops_constant_balance_body.cache_key.list, cjson.encode(list));
    if not res then
        return tl_ops_rt.error, "set list err ", _
    end

    res, _ = cache:set(tl_ops_constant_balance_body.cache_key.rule, rule);
    if not res then
        return tl_ops_rt.error, "set rule err ", _
    end

    res, _ = cache:set(tl_ops_constant_balance_body.cache_key.rule_match_mode, rule_match_mode);
    if not res then
        return tl_ops_rt.error, "set rule_match_mode err ", _
    end

    local res_data = {}
    res_data[tl_ops_constant_balance_body.cache_key.rule] = rule
    res_data[tl_ops_constant_balance_body.cache_key.rule_match_mode] = rule_match_mode
    res_data[tl_ops_constant_balance_body.cache_key.list] = list


    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}