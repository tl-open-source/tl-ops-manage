-- tl_ops_header 
-- en : set header config list
-- zn : 更新路由header配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local snowflake = require("lib.snowflake");
local cache = require("cache.tl_ops_cache"):new("tl-ops-balance-header");
local tl_ops_constant_balance_header = require("constant.tl_ops_constant_balance_header");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");


local Router = function() 
    local tl_ops_balance_header_rule, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_header.cache_key.rule, 1);
    if not tl_ops_balance_header_rule or tl_ops_balance_header_rule == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bh args err1", _);
        return;
    end
    
    local tl_ops_balance_header_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_balance_header.cache_key.list, 1);
    if not tl_ops_balance_header_list or tl_ops_balance_header_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bh args err2", _);
        return;
    end
    
    if tl_ops_balance_header_rule ~= tl_ops_constant_balance_header.rule.point and tl_ops_balance_header_rule ~= tl_ops_constant_balance_header.rule.random then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bh args err3", _);
        return;
    end
    
    -- 获取当前策略
    local tl_ops_balance_header_list_single, _ = tl_ops_balance_header_list[tl_ops_balance_header_rule];
    if not tl_ops_balance_header_list_single or tl_ops_balance_header_list_single == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"bh args err4", _);
        return;
    end
    
    -- 更新生成id
    for _, header in ipairs(tl_ops_balance_header_list_single) do
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
    tl_ops_balance_header_list[tl_ops_balance_header_rule] = tl_ops_balance_header_list_single;
    
    
    local cache_list, _ = cache:set(tl_ops_constant_balance_header.cache_key.list, cjson.encode(tl_ops_balance_header_list));
    if not cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
        return;
    end
    
    
    local cache_rule, _ = cache:set(tl_ops_constant_balance_header.cache_key.rule, tl_ops_balance_header_rule);
    if not cache_rule then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set rule err ", _)
        return;
    end
    
    local res_data = {}
    res_data[tl_ops_constant_balance_header.cache_key.rule] = tl_ops_balance_header_rule
    res_data[tl_ops_constant_balance_header.cache_key.list] = tl_ops_balance_header_list
    
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "ok", res_data)
 end
 
return Router
 