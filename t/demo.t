use Test::Nginx::Socket::Lua 'no_plan';

workers(4);
repeat_each(1);
no_long_string();
no_root_location();
log_level('info');

no_shuffle();
run_tests;

__DATA__


=== TEST 1: demo1
--- config
    location /t {
        content_by_lua_block {
            ngx.say("demo1");
        }
    }
--- request
GET /t
--- response_body
demo1
--- no_error_log
[error]



=== TEST 2: demo2
--- http_config
charset utf-8;
--- config
    location /t {
        content_by_lua_block {
            ngx.say("demo2");
        }
    }
--- request
GET /t
--- response_body
demo2
--- no_error_log
[error]