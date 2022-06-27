-- tl_ops_cookie 
-- en : set cookie config list
-- zn : 更新路由cookie配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-balance-cookie");
local tl_ops_constant_balance_cookie = require("constant.tl_ops_constant_balance_cookie");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local Router = function() 
    local tl_ops_balance_cookie_rule, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_cookie.cache_key.rule, 1);
    if not tl_ops_balance_cookie_rule or tl_ops_balance_cookie_rule == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err1", _);
        return;
    end
    
    local tl_ops_balance_cookie_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_cookie.cache_key.list, 1);
    if not tl_ops_balance_cookie_list or tl_ops_balance_cookie_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err2", _);
        return;
    end
    
    if tl_ops_balance_cookie_rule ~= tl_ops_constant_balance_cookie.rule.point and tl_ops_balance_cookie_rule ~= tl_ops_constant_balance_cookie.rule.random then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err3", _);
        return;
    end
    
    -- 获取当前策略
    local tl_ops_balance_cookie_list_single, _ = tl_ops_balance_cookie_list[tl_ops_balance_cookie_rule];
    if not tl_ops_balance_cookie_list_single or tl_ops_balance_cookie_list_single == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bc args err4", _);
        return;
    end
    
    -- 更新生成id
    for _, cookie in ipairs(tl_ops_balance_cookie_list_single) do
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
    tl_ops_balance_cookie_list[tl_ops_balance_cookie_rule] = tl_ops_balance_cookie_list_single;
    
    
    local cache_list, _ = cache:set(tl_ops_constant_balance_cookie.cache_key.list, cjson.encode(tl_ops_balance_cookie_list));
    if not cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
        return;
    end
    
    
    local cache_rule, _ = cache:set(tl_ops_constant_balance_cookie.cache_key.rule, tl_ops_balance_cookie_rule);
    if not cache_rule then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", _)
        return;
    end
    
    local res_data = {}
    res_data[tl_ops_constant_balance_cookie.cache_key.rule] = tl_ops_balance_cookie_rule
    res_data[tl_ops_constant_balance_cookie.cache_key.list] = tl_ops_balance_cookie_list
    
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", res_data)
 end
 
return Router

 
 