-- tl_ops_waf_count
-- en : waf count core api
-- zn : waf统计对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local tl_ops_waf_count_core     = require("waf.count.tl_ops_waf_count_core");
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local shared                    = ngx.shared.tlopswaf;

local _M = {}


function _M:init( )
    -- 启动路由统计
    local waf_count = tl_ops_waf_count_core:new();
    waf_count:tl_ops_waf_count_timer_start()
end


return _M