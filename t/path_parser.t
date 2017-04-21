# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(1);
plan tests => 2 * repeat_each() * blocks();

my $pwd = cwd();
our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;;";
};

#no_diff();
$ENV{PATH} .= ":/usr/local/nginx/sbin";
run_tests();

__DATA__

=== TEST 1: next_token normal
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local P = require("resty.path_parser")
            local parser = P:new("/a/b/c/")
            local token, err = parser:next_token()
            local ret = ""
            while token and not err do
                ret = ret .. token
                token, err = parser:next_token()
            end
            ngx.say(ret)
        ';
    }
--- request
GET /t
--- response_body_like: ^abc$
--- error_code: 200

=== TEST 2: next_token cornor case emtpy
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local P = require("resty.path_parser")
            local parser = P:new("/")
            local token, err = parser:next_token()
            local ret = ""
            while token and not err do
                ret = ret .. token
                token, err = parser:next_token()
            end
            if err then
                ngx.print(err)
            else
                ngx.print(ret)
            end
        ';
    }
--- request
GET /t
--- response_body:
--- error_code: 200
