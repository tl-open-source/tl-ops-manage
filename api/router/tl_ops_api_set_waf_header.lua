-- tl_ops_header 
-- en : set header config list
-- zn : 更新waf header配置列表
-- @author iamtsm
-- @email 1905333456@qq.com

local snowflake                     = require("lib.snowflake");
local cache                         = require("cache.tl_ops_cache_core"):new("tl-ops-waf-header");
local tl_ops_constant_waf_header    = require("constant.tl_ops_constant_waf_header");
local tl_ops_rt                     = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func             = require("utils.tl_ops_utils_func");
local cjson                         = require("cjson.safe");
cjson.encode_empty_table_as_object(false)

local Handler = function()

    local scope, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf_header.cache_key.scope, 1);
    if not scope or scope == nil then
        return tl_ops_rt.args_error ,"wh args err1", _
    end

    local open, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf_header.cache_key.open, 1);
    if open == nil then
        return tl_ops_rt.args_error ,"wh args err2", _
    end
    
    local list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_waf_header.cache_key.list, 1);
    if not list or list == nil then
        return tl_ops_rt.args_error ,"wh args err3", _
    end
    
    -- 更新生成id
    for _, header in ipairs(list) do
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

    local cache_list, _ = cache:set(tl_ops_constant_waf_header.cache_key.list, cjson.encode(list));
    if not cache_list then
        return tl_ops_rt.error, "set list err ", _
    end

    local cache_scope, _ = cache:set(tl_ops_constant_waf_header.cache_key.scope, scope);
    if not cache_scope then
        return tl_ops_rt.error, "set scope err ", _
    end

    local cache_open, _ = cache:set(tl_ops_constant_waf_header.cache_key.open, open);
    if not cache_open then
        return tl_ops_rt.error, "set open err ", _
    end

    local res_data = {}
    res_data[tl_ops_constant_waf_header.cache_key.scope] = scope
    res_data[tl_ops_constant_waf_header.cache_key.open] = open
    res_data[tl_ops_constant_waf_header.cache_key.list] = list

    return tl_ops_rt.ok, "success", res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}