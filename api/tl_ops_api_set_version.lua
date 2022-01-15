-- tl_ops_api 
-- en : update version
-- zn : 更新版本信息
-- @author iamtsm
-- @email 1905333456@qq.com

local cjson = require("cjson");
cjson.encode_empty_table_as_object(false)
local tl_ops_constant_health = require("constant.tl_ops_constant_health");
local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local cache_dict = ngx.shared.tlopsbalance;


---- 服务新增标志位
local cache_service_options_version_key,_ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_health.cache_key.service_options_version, 1);
if cache_service_options_version_key and cache_service_options_version_key == true then

end

---- 服务变动标志位
local cache_version_table,_ = tl_ops_utils_func:get_req_post_args_by_name(tl_ops_constant_health.cache_key.service_version, 1);
if cache_version_table then

end