-- tl_ops_api 
-- en : set health config
-- zn : 更新健康检查配置信息
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local cache = require("cache.tl_ops_cache"):new("tl-ops-health");
local tl_ops_constant_health = require("constant.tl_ops_constant_health");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_health_check_version = require("health.tl_ops_health_check_version")


local Router = function() 
    local tl_ops_health_list, _ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_health.cache_key.options_list, 1);
    if not tl_ops_health_list or tl_ops_health_list == nil then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.args_error ,"h args err1", _);
        return;
    end
    
    local cache_list, _ = cache:set(tl_ops_constant_health.cache_key.options_list, cjson.encode(tl_ops_health_list));
    if not cache_list then
        tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.error, "set list err ", _)
        return;
    end
    
    -- 对service version更新，通知worker更新所有conf
    for _, option in ipairs(tl_ops_health_list) do
        tl_ops_health_check_version.incr_service_version(option.check_service_name);
    end
    
    
    local res_data = {}
    res_data[tl_ops_constant_health.cache_key.options_list] = tl_ops_health_list
    
    tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
 end
 
return Router
