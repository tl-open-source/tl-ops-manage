-- tl_ops_limit
-- en : limit api
-- zn : 限流器对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local cache_limit               = require("cache.tl_ops_cache_core"):new("tl-ops-limit");
local tl_ops_constant_limit     = require("constant.tl_ops_constant_limit")
local cjson                     = require("cjson.safe");
local tl_ops_utils_func         = require("utils.tl_ops_utils_func");
local shared                    = ngx.shared.tlopsbalance;

local _M = {}

-- 获取限流器
function _M:tl_ops_limit_get_limiter( service_name, node_id )
    -- 服务熔断配置列表
    local limit_list_str, _ = cache_limit:get(tl_ops_constant_limit.fuse.cache_key.options_list);
    if not limit_list_str then
        return nil
    end

    local limit_list_table = cjson.decode(limit_list_str);
    if not limit_list_table and type(limit_list_table) ~= 'table' then
        return nil
    end

    for _, limit_option in pairs(limit_list_table) do
        if limit_option.service_name == service_name then
            if not limit_option.depend then
                return nil
            end
            return limit_option.depend
        end
    end
end


-- incr limit failed count
-- 路由失败次数增加 , 限流用
function _M:tl_ops_limit_fuse_incr_fail( service_name, node_id )
    local failed_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.node_req_fail,service_name, node_id)
    local failed_count = shared:get(failed_key)
    if not failed_count then
        shared:set(failed_key, 0);
    end
    shared:incr(failed_key, 1)
end


-- incr limit succ count
-- 路由成功次数增加 , 限流用
function _M:tl_ops_limit_fuse_incr_succ( service_name, node_id )
    local succ_key = tl_ops_utils_func:gen_node_key(tl_ops_constant_limit.fuse.cache_key.node_req_succ, service_name, node_id)
    local success_count = shared:get(succ_key)
    if not success_count then
        shared:set(succ_key, 0);
    end
    shared:incr(succ_key, 1)
end


return _M