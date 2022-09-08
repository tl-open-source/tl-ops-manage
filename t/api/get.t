use Test::Nginx::Socket::Lua 'no_plan';

workers(4);
repeat_each(1);
no_long_string();
no_root_location();
log_level('info');

no_shuffle();
run_tests;

__DATA__


=== TEST 1: get balance api
--- http_config
include "/usr/local/tl-ops-manage/conf/tl_ops_manage.conf";
lua_package_path "/usr/local/openresty/lualib/?.lua;/usr/local/tl-ops-manage/?.lua";
lua_package_cpath "usr/local/openresty/lualib/?.so;;";
--- config
    location = /tlops/balance/api {
        content_by_lua_block {
            local api_core = require("api.tl_ops_api_core")
            local router = api_core["/tlops/balance/get"]
            router()
        }
    }
--- request
GET /tlops/balance/api
--- response_body_like
xxxxx
--- no_error_log
[error]
