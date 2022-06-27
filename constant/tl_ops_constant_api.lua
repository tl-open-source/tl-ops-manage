local tl_ops_constant_api = {}

-- balance
tl_ops_constant_api["/tlops/balance/get"] = require("api.router.tl_ops_api_get_balance")
tl_ops_constant_api["/tlops/balance/set"] = require("api.router.tl_ops_api_set_balance")
tl_ops_constant_api["/tlops/balance/api/list"] = require("api.router.tl_ops_api_get_balance_api")
tl_ops_constant_api["/tlops/balance/api/set"] = require("api.router.tl_ops_api_set_balance_api")
tl_ops_constant_api["/tlops/balance/cookie/list"] = require("api.router.tl_ops_api_get_balance_cookie")
tl_ops_constant_api["/tlops/balance/cookie/set"] = require("api.router.tl_ops_api_set_balance_cookie")
tl_ops_constant_api["/tlops/balance/header/list"] = require("api.router.tl_ops_api_get_balance_header")
tl_ops_constant_api["/tlops/balance/header/set"] = require("api.router.tl_ops_api_set_balance_header")
tl_ops_constant_api["/tlops/balance/param/list"] = require("api.router.tl_ops_api_get_balance_param")
tl_ops_constant_api["/tlops/balance/param/set"] = require("api.router.tl_ops_api_set_balance_param")

-- waf
tl_ops_constant_api["/tlops/waf/get"] = require("api.router.tl_ops_api_get_waf")
tl_ops_constant_api["/tlops/waf/set"] = require("api.router.tl_ops_api_set_waf")
tl_ops_constant_api["/tlops/waf/api/list"] = require("api.router.tl_ops_api_get_waf_api")
tl_ops_constant_api["/tlops/waf/api/set"] = require("api.router.tl_ops_api_set_waf_api")
tl_ops_constant_api["/tlops/waf/cookie/list"] = require("api.router.tl_ops_api_get_waf_cookie")
tl_ops_constant_api["/tlops/waf/cookie/set"] = require("api.router.tl_ops_api_set_waf_cookie")
tl_ops_constant_api["/tlops/waf/param/list"] = require("api.router.tl_ops_api_get_waf_param")
tl_ops_constant_api["/tlops/waf/param/set"] = require("api.router.tl_ops_api_set_waf_param")
tl_ops_constant_api["/tlops/waf/header/list"] = require("api.router.tl_ops_api_get_waf_header")
tl_ops_constant_api["/tlops/waf/header/set"] = require("api.router.tl_ops_api_set_waf_header")
tl_ops_constant_api["/tlops/waf/ip/list"] = require("api.router.tl_ops_api_get_waf_ip")
tl_ops_constant_api["/tlops/waf/ip/set"] = require("api.router.tl_ops_api_set_waf_ip")
tl_ops_constant_api["/tlops/waf/cc/list"] = require("api.router.tl_ops_api_get_waf_cc")
tl_ops_constant_api["/tlops/waf/cc/set"] = require("api.router.tl_ops_api_set_waf_cc")

-- service
tl_ops_constant_api["/tlops/service/list"] = require("api.router.tl_ops_api_get_service")
tl_ops_constant_api["/tlops/service/set"] = require("api.router.tl_ops_api_set_service")

-- state
tl_ops_constant_api["/tlops/state/get"] = require("api.router.tl_ops_api_get_state")
tl_ops_constant_api["/tlops/state/set"] = require("api.router.tl_ops_api_set_state")

-- health
tl_ops_constant_api["/tlops/health/list"] = require("api.router.tl_ops_api_get_health")
tl_ops_constant_api["/tlops/health/set"] = require("api.router.tl_ops_api_set_health")

-- limit
tl_ops_constant_api["/tlops/limit/list"] = require("api.router.tl_ops_api_get_limit")
tl_ops_constant_api["/tlops/limit/set"] = require("api.router.tl_ops_api_set_limit")

-- store
tl_ops_constant_api["/tlops/store/list"] = require("api.router.tl_ops_api_get_store")

-- sync
tl_ops_constant_api["/tlops/sync"] = require("api.router.tl_ops_api_sync")


return tl_ops_constant_api