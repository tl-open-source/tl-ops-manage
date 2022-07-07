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
   local code_str = cache:get(tl_ops_constant_waf.cache_key.options)
   if not code_str then
      tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.not_found, "not found options", _);
      return;
   end

   tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", cjson.decode(code_str));
end

return Router
