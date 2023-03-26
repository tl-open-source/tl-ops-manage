use Test::Nginx::Socket::Lua 'no_plan';

workers(4);
repeat_each(1);
no_long_string();
no_root_location();
log_level('info');

no_shuffle();
run_tests;

__DATA__

=== TEST 1: /tlops/balance/get
--- http_config
include "/Users/iamtsm/Desktop/code/tl-ops-manage/conf/tl_ops_manage.conf";
lua_package_path "/usr/local/openresty/lualib/?.lua;/Users/iamtsm/Desktop/code/tl-ops-manage/?.lua";
lua_package_cpath "/usr/local/openresty/lualib/?.so;;";
--- config
    location = /tlops/balance/get {
        content_by_lua_block {
            local tl_ops_constant_balance = require("constant.tl_ops_constant_balance");
            local api_core = require("api.tl_ops_api_core")
            local code, msg, data = api_core["/tlops/balance/get"].Handler()
            
            assert(code == 0)
            assert(msg == "success")
            assert(type (data) == 'table')
            assert(type (data.service_empty) == 'table')
            assert(type (data.mode_empty) == 'table')
            assert(type (data.host_empty) == 'table')
            assert(type (data.host_pass) == 'table')
            assert(type (data.token_limit) == 'table')
            assert(type (data.leak_limit) == 'table')
            assert(type (data.offline) == 'table')

            ngx.status = 200;
            ngx.say(code);
            ngx.flush();
            ngx.exit(200);
        }
    }
--- request
GET /tlops/balance/get
--- response_body
0
