use Test::Nginx::Socket::Lua 'no_plan';

workers(4);
repeat_each(1);
no_long_string();
no_root_location();
log_level('info');

no_shuffle();
run_tests;

__DATA__

=== TEST 1: /tlops/service/list
--- http_config
include "/Users/iamtsm/Desktop/code/tl-ops-manage/conf/tl_ops_manage.conf";
lua_package_path "/usr/local/openresty/lualib/?.lua;/Users/iamtsm/Desktop/code/tl-ops-manage/?.lua";
lua_package_cpath "/usr/local/openresty/lualib/?.so;;";
--- config
    location = /tlops/service/list {
        content_by_lua_block {
            local tl_ops_constant_service = require("constant.tl_ops_constant_service");
            local api_core = require("api.tl_ops_api_core")
            local code, msg, data = api_core["/tlops/service/list"].Handler()
            
            assert(code == 0)
            assert(msg == "success")
            assert(type (data) == 'table')
            assert(data[tl_ops_constant_service.cache_key.service_rule] == 'auto_load')
            assert(type (data[tl_ops_constant_service.cache_key.service_list]) == 'table')

            ngx.status = 200;
            ngx.say(code);
            ngx.flush();
            ngx.exit(200);
        }
    }
--- request
GET /tlops/service/list
--- response_body
0
