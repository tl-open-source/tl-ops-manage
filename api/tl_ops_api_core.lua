local tl_ops_api_core = {}

-- balance
tl_ops_api_core["/tlops/balance/get"] = require("api.router.tl_ops_api_get_balance")
tl_ops_api_core["/tlops/balance/set"] = require("api.router.tl_ops_api_set_balance")
tl_ops_api_core["/tlops/balance/api/list"] = require("api.router.tl_ops_api_get_balance_api")
tl_ops_api_core["/tlops/balance/api/set"] = require("api.router.tl_ops_api_set_balance_api")
tl_ops_api_core["/tlops/balance/body/list"] = require("api.router.tl_ops_api_get_balance_body")
tl_ops_api_core["/tlops/balance/body/set"] = require("api.router.tl_ops_api_set_balance_body")
tl_ops_api_core["/tlops/balance/cookie/list"] = require("api.router.tl_ops_api_get_balance_cookie")
tl_ops_api_core["/tlops/balance/cookie/set"] = require("api.router.tl_ops_api_set_balance_cookie")
tl_ops_api_core["/tlops/balance/header/list"] = require("api.router.tl_ops_api_get_balance_header")
tl_ops_api_core["/tlops/balance/header/set"] = require("api.router.tl_ops_api_set_balance_header")
tl_ops_api_core["/tlops/balance/param/list"] = require("api.router.tl_ops_api_get_balance_param")
tl_ops_api_core["/tlops/balance/param/set"] = require("api.router.tl_ops_api_set_balance_param")

-- waf
tl_ops_api_core["/tlops/waf/get"] = require("api.router.tl_ops_api_get_waf")
tl_ops_api_core["/tlops/waf/set"] = require("api.router.tl_ops_api_set_waf")
tl_ops_api_core["/tlops/waf/api/list"] = require("api.router.tl_ops_api_get_waf_api")
tl_ops_api_core["/tlops/waf/api/set"] = require("api.router.tl_ops_api_set_waf_api")
tl_ops_api_core["/tlops/waf/cookie/list"] = require("api.router.tl_ops_api_get_waf_cookie")
tl_ops_api_core["/tlops/waf/cookie/set"] = require("api.router.tl_ops_api_set_waf_cookie")
tl_ops_api_core["/tlops/waf/param/list"] = require("api.router.tl_ops_api_get_waf_param")
tl_ops_api_core["/tlops/waf/param/set"] = require("api.router.tl_ops_api_set_waf_param")
tl_ops_api_core["/tlops/waf/header/list"] = require("api.router.tl_ops_api_get_waf_header")
tl_ops_api_core["/tlops/waf/header/set"] = require("api.router.tl_ops_api_set_waf_header")
tl_ops_api_core["/tlops/waf/ip/list"] = require("api.router.tl_ops_api_get_waf_ip")
tl_ops_api_core["/tlops/waf/ip/set"] = require("api.router.tl_ops_api_set_waf_ip")
tl_ops_api_core["/tlops/waf/cc/list"] = require("api.router.tl_ops_api_get_waf_cc")
tl_ops_api_core["/tlops/waf/cc/set"] = require("api.router.tl_ops_api_set_waf_cc")

-- service
tl_ops_api_core["/tlops/service/list"] = require("api.router.tl_ops_api_get_service")
tl_ops_api_core["/tlops/service/set"] = require("api.router.tl_ops_api_set_service")

-- state
tl_ops_api_core["/tlops/state/get"] = require("api.router.tl_ops_api_get_state")
tl_ops_api_core["/tlops/state/set"] = require("api.router.tl_ops_api_set_state")

-- health
tl_ops_api_core["/tlops/health/list"] = require("api.router.tl_ops_api_get_health")
tl_ops_api_core["/tlops/health/set"] = require("api.router.tl_ops_api_set_health")

-- limit
tl_ops_api_core["/tlops/limit/list"] = require("api.router.tl_ops_api_get_limit")
tl_ops_api_core["/tlops/limit/set"] = require("api.router.tl_ops_api_set_limit")

-- plugins
tl_ops_api_core["/tlops/plugins/get"] = require("api.router.tl_ops_api_get_plugins_manage")
tl_ops_api_core["/tlops/plugins/set"] = require("api.router.tl_ops_api_set_plugins_manage");

-- store
tl_ops_api_core["/tlops/store/list"] = require("api.router.tl_ops_api_get_store")

return tl_ops_api_core