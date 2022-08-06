-- tl_ops_api 
-- en : get waf config
-- zn : 获取waf 配置列表
-- @author iamtsm
-- @email 1905333456@qq.com


local snowflake            = require("lib.snowflake");
local cache                = require("cache.tl_ops_cache_core"):new("tl-ops-waf");
local tl_ops_constant_waf  = require("constant.tl_ops_constant_waf");
local tl_ops_rt            = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func    = require("utils.tl_ops_utils_func");
local cjson                = require("cjson.safe");
cjson.encode_empty_table_as_object(false)


local Router = function() 
   local waf_ip = cache:get(tl_ops_constant_waf.cache_key.waf_ip)
   if not waf_ip then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found waf_ip", _);
      return;
   end

   local waf_api = cache:get(tl_ops_constant_waf.cache_key.waf_api)
   if not waf_api then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found waf_api", _);
      return;
   end

   local waf_cc = cache:get(tl_ops_constant_waf.cache_key.waf_cc)
   if not waf_cc then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found waf_cc", _);
      return;
   end

   local waf_header = cache:get(tl_ops_constant_waf.cache_key.waf_header)
   if not waf_header then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found waf_header", _);
      return;
   end

   local waf_cookie = cache:get(tl_ops_constant_waf.cache_key.waf_cookie)
   if not waf_cookie then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found waf_cookie", _);
      return;
   end

   local waf_param = cache:get(tl_ops_constant_waf.cache_key.waf_param)
   if not waf_param then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found waf_param", _);
      return;
   end

   local res_data = {
      waf_ip = cjson.decode(waf_ip),
      waf_api = cjson.decode(waf_api),
      waf_cc = cjson.decode(waf_cc),
      waf_header = cjson.decode(waf_header),
      waf_cookie = cjson.decode(waf_cookie),
      waf_param = cjson.decode(waf_param),
   }

   tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", res_data);
end

return Router
