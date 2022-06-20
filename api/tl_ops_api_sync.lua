-- tl_ops_api
-- en : version fields update 
-- zn : 版本迭代更新字段同步器
-- @author iamtsm
-- @email 1905333456@qq.com

local tl_ops_rt = require("constant.tl_ops_constant_comm").tl_ops_rt;
local tl_ops_utils_func = require("utils.tl_ops_utils_func");
local tl_ops_utils_sync = require("utils.tl_ops_utils_sync");

local service = tl_ops_utils_sync.tl_ops_utils_sync_module('service')
local health = tl_ops_utils_sync.tl_ops_utils_sync_module('health')
local limit = tl_ops_utils_sync.tl_ops_utils_sync_module('limit')
local token = tl_ops_utils_sync.tl_ops_utils_sync_module('token')
local leak = tl_ops_utils_sync.tl_ops_utils_sync_module('leak')
local balance = tl_ops_utils_sync.tl_ops_utils_sync_module('balance')
local api = tl_ops_utils_sync.tl_ops_utils_sync_module('api')
local cookie = tl_ops_utils_sync.tl_ops_utils_sync_module('cookie')
local header = tl_ops_utils_sync.tl_ops_utils_sync_module('header')
local param = tl_ops_utils_sync.tl_ops_utils_sync_module('param');

-- local res_data = {
--     "service" = service,
--     "health" = health,
--     "limit" = limit,
--     "token" = token,
--     "leak" = leak,
--     "balance" = balance,
--     "api" = api,
--     "cookie" = cookie,
--     "header" = header,
--     "param" = param
-- }

tl_ops_utils_func:set_ngx_req_return_ok(tl_ops_rt.ok, "success", health);