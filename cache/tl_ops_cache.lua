-- cache业务集合

local service           = require("cache.tl_ops_cache_core"):new("tl-ops-service");
local limit             = require("cache.tl_ops_cache_core"):new("tl-ops-limit");
local health            = require("cache.tl_ops_cache_core"):new("tl-ops-health");

local balance           = require("cache.tl_ops_cache_core"):new("tl-ops-balance");
local balance_api       = require("cache.tl_ops_cache_core"):new("tl-ops-balance-api");
local balance_body      = require("cache.tl_ops_cache_core"):new("tl-ops-balance-body");
local balance_param     = require("cache.tl_ops_cache_core"):new("tl-ops-balance-param");
local balance_header    = require("cache.tl_ops_cache_core"):new("tl-ops-balance-header");
local balance_cookie    = require("cache.tl_ops_cache_core"):new("tl-ops-balance-cookie");

local waf               = require("cache.tl_ops_cache_core"):new("tl-ops-waf");
local waf_api           = require("cache.tl_ops_cache_core"):new("tl-ops-waf-api");
local waf_ip            = require("cache.tl_ops_cache_core"):new("tl-ops-waf-ip");
local waf_cookie        = require("cache.tl_ops_cache_core"):new("tl-ops-waf-cookie");
local waf_header        = require("cache.tl_ops_cache_core"):new("tl-ops-waf-header");
local waf_cc            = require("cache.tl_ops_cache_core"):new("tl-ops-waf-cc");
local waf_param         = require("cache.tl_ops_cache_core"):new("tl-ops-waf-param");

local plugins_manage    = require("cache.tl_ops_cache_core"):new("tl-ops-plugins-manage");

return {
    service         = service,
    health          = health,
    limit           = limit,
    balance         = balance,
    balance_api     = balance_api,
    balance_body    = balance_body,
    balance_param   = balance_param,
    balance_header  = balance_header,
    balance_cookie  = balance_cookie,
    waf             = waf,
    waf_ip          = waf_ip,
    waf_api         = waf_api,
    waf_cc          = waf_cc,
    waf_header      = waf_header,
    waf_cookie      = waf_cookie,
    waf_param       = waf_param,
    plugins_manage  = plugins_manage,
}