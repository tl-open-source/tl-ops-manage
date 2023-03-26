-- tl_ops_api 
-- en : set waf config
-- zn : 更新waf配置
-- @author iamtsm
-- @email 1905333456@qq.com

local cache                 = require("cache.tl_ops_cache_core"):new("tl-ops-waf");
local tl_ops_constant_waf   = require("constant.tl_ops_constant_waf");
local tl_ops_rt             = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func     = require("utils.tl_ops_utils_func");
local cjson                 = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Handler = function()
    local change = "success"

    local waf_ip, _ = tl_ops_utils_func:get_req_post_args_by_name("waf_ip", 1);
    if waf_ip then
        local res, _ = cache:set(tl_ops_constant_waf.cache_key.waf_ip, cjson.encode(waf_ip));
        if not res then
            return tl_ops_rt.error, "set waf_ip err ", _
        end
        change = "waf_ip succeess"
    end

    local waf_api, _ = tl_ops_utils_func:get_req_post_args_by_name("waf_api", 1);
    if waf_api then
        local res, _ = cache:set(tl_ops_constant_waf.cache_key.waf_api, cjson.encode(waf_api));
        if not res then
            return tl_ops_rt.error, "set waf_api err ", _
        end
        change = "waf_api succeess"
    end

    local waf_cc, _ = tl_ops_utils_func:get_req_post_args_by_name("waf_cc", 1);
    if waf_cc then
        local res, _ = cache:set(tl_ops_constant_waf.cache_key.waf_cc, cjson.encode(waf_cc));
        if not res then
            return tl_ops_rt.error, "set waf_cc err ", _
        end
        change = "waf_cc succeess"
    end

    local waf_header, _ = tl_ops_utils_func:get_req_post_args_by_name("waf_header", 1);
    if waf_header then
        local res, _ = cache:set(tl_ops_constant_waf.cache_key.waf_header, cjson.encode(waf_header));
        if not res then
            return tl_ops_rt.error, "set waf_header err ", _
        end
        change = "waf_header succeess"
    end

    local waf_cookie, _ = tl_ops_utils_func:get_req_post_args_by_name("waf_cookie", 1);
    if waf_cookie then
        local res, _ = cache:set(tl_ops_constant_waf.cache_key.waf_cookie, cjson.encode(waf_cookie));
        if not res then
            return tl_ops_rt.error, "set waf_cookie err ", _
        end
        change = "waf_cookie succeess"
    end

    local waf_param, _ = tl_ops_utils_func:get_req_post_args_by_name("waf_param", 1);
    if waf_param then
        local res, _ = cache:set(tl_ops_constant_waf.cache_key.waf_param, cjson.encode(waf_param));
        if not res then
            return tl_ops_rt.error, "set waf_param err ", _
        end
        change = "waf_param succeess"
    end

    local res_data = {}

    return tl_ops_rt.ok, change, res_data
end


local Router = function ()
    tl_ops_utils_func:set_ngx_req_return_ok(Handler())
end

return {
    Handler = Handler,
    Router = Router
}