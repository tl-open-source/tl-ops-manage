-- tl_ops_cookie 
-- en : set cookie config list
-- zn : 更新路由cookie配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local snowflake                         = require("lib.snowflake");
local cache                             = require("cache.tl_ops_cache_core"):new("tl-ops-balance-cookie");
local tl_ops_constant_balance_cookie    = require("constant.tl_ops_constant_balance_cookie");
local tl_ops_rt                         = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func                 = require("utils.tl_ops_utils_func");
local cjson                             = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 
    local rule, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_cookie.cache_key.rule, 1);
    if not rule or rule == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err1", _);
        return;
    end

    if rule ~= tl_ops_constant_balance_cookie.rule.point and rule ~= tl_ops_constant_balance_cookie.rule.random then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err2", _);
        return;
    end

    local rule_match_mode, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_cookie.cache_key.rule_match_mode, 1);
    if not rule_match_mode or rule_match_mode == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err3", _);
        return;
    end

    if rule_match_mode ~= tl_ops_constant_balance_cookie.mode.cookie and rule_match_mode ~= tl_ops_constant_balance_cookie.mode.host then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err4", _);
        return;
    end
    
    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_cookie.cache_key.list, 1);
    if not list or list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err5", _);
        return;
    end
    
    -- 获取当前策略
    local list_single = list[rule];
    if not list_single or list_single == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err6", _);
        return;
    end
    
    -- 更新生成id
    for _, cookie in ipairs(list_single) do
        if not cookie.id or cookie.id == nil or cookie.id == '' then
            cookie.id = snowflake.generate_id( 100 )
        end
        if not cookie.updatetime or cookie.updatetime == nil or cookie.updatetime == '' then
            cookie.updatetime = ngx.localtime()
        end
        if cookie.change and cookie.change == true then
            cookie.updatetime = ngx.localtime()
            cookie.change = nil
        end
    end
    
    -- 放回
    list[rule] = list_single;
    
    
    local res, _ = cache:set(tl_ops_constant_balance_cookie.cache_key.list, cjson.encode(list));
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
        return;
    end
    
    res, _ = cache:set(tl_ops_constant_balance_cookie.cache_key.rule, rule);
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", _)
        return;
    end

    res, _ = cache:set(tl_ops_constant_balance_cookie.cache_key.rule_match_mode, rule_match_mode);
    if not res then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule_match_mode err ", _)
        return;
    end
    
    local res_data = {}
    res_data[tl_ops_constant_balance_cookie.cache_key.rule] = rule
    res_data[tl_ops_constant_balance_cookie.cache_key.rule_match_mode] = rule_match_mode
    res_data[tl_ops_constant_balance_cookie.cache_key.list] = list
    
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", res_data)
 end
 
return Router

 
 