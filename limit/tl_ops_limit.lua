-- tl_ops_limit
-- en : limit api
-- zn : 限流器对外接口
-- @author iamtsm
-- @email 1905333456@qq.com


local cache_limit = require("cache.tl_ops_cache"):new("tl-ops-limit");
local tl_ops_constant_limit = require("constant.tl_ops_constant_limit")
local cjson = require("cjson");

-- 获取限流器
local tl_ops_limit_get_limiter = function( service_name, node_id )
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



return {
    tl_ops_limit_get_limiter = tl_ops_limit_get_limiter
}