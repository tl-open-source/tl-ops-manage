-- tl_ops_api 
-- en : set limit fuse config
-- zn : 更新熔断限流检查配置信息
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)

local cache = require("cache.tl_ops_cache"):new("tl-ops-limit");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_limit_fuse_check_version = require("limit.fuse.tl_ops_limit_fuse_check_version")

local Router = function() 
    -- fuse配置
    local tl_ops_limit_fuse_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_limit.fuse.cache_key.options_list, 1);
    if not tl_ops_limit_fuse_list or tl_ops_limit_fuse_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"l args err1", _);
        return;
    end

    local fuse_cache_list, _ = cache:set(tl_ops_constant_limit.fuse.cache_key.options_list, cjson.encode(tl_ops_limit_fuse_list));
    if not fuse_cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set fuse list err ", _)
        return;
    end


    -- leak配置
    local tl_ops_limit_leak_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_limit.leak.cache_key.options_list, 1);
    if not tl_ops_limit_leak_list or tl_ops_limit_leak_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"l args err2", _);
        return;
    end

    local leak_cache_list, _ = cache:set(tl_ops_constant_limit.leak.cache_key.options_list, cjson.encode(tl_ops_limit_leak_list));
    if not leak_cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set leak list err ", _)
        return;
    end


    -- token配置
    local tl_ops_limit_token_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_limit.token.cache_key.options_list, 1);
    if not tl_ops_limit_token_list or tl_ops_limit_token_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"l args err3", _);
        return;
    end

    local token_cache_list, _ = cache:set(tl_ops_constant_limit.token.cache_key.options_list, cjson.encode(tl_ops_limit_token_list));
    if not token_cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set token list err ", _)
        return;
    end


    -- 对service version更新，通知worker更新所有conf
    for _, option in ipairs(tl_ops_limit_fuse_list) do
        tl_ops_limit_fuse_check_version.incr_service_version(option.service_name);
    end


    local res_data = {}
    res_data[tl_ops_constant_limit.fuse.cache_key.options_list] = tl_ops_limit_fuse_list
    res_data[tl_ops_constant_limit.leak.cache_key.options_list] = tl_ops_limit_leak_list
    res_data[tl_ops_constant_limit.token.cache_key.options_list] = tl_ops_limit_token_list


    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
 end
 
return Router

 