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

=== TEST 1: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/c.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /a/b/c
--- response_body: 1
--- error_code: 200

=== TEST 2: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/c.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /a/bc/c
--- response_body: bc
--- error_code: 200

=== TEST 3: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/c.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /c/bc/cd
--- response_body: bccd
--- error_code: 200

=== TEST 4: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/c.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /a/b/
--- response_body:
--- error_code: 200

=== TEST 5: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new() 
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/*.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /d/c/b.html
--- response_body: 2 
--- error_code: 200

=== TEST 6: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/*.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /d/c/bmm.pdf
--- response_body: 3 
--- error_code: 200

=== TEST 7: run normal case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/b/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
            router:get("/c/:b/:c/", function(params)
                ngx.print(params["b"]..params["c"])
            end)
            router:get("/d/c/*.html", function(params)
                ngx.print("2")
            end)
            router:get("/d/c/*.pdf", function(params)
                ngx.print("3")
            end)
            router:run()
        ';
    }
--- request
GET /d/c/b
--- response_body:
--- error_code: 200

=== TEST 8: run normal case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/c/*.html", function(params)
                ngx.print("1")
            end)
            router:get("/a/c/*", function(params)
                ngx.print("2")
            end)
            router:run()
        ';
    }
--- request
GET /a/c/b
--- response_body: 2 
--- error_code: 200

=== TEST 9: run normal case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/c/*.html", function(params)
                ngx.print("1")
            end)
            router:get("/a/c/*", function(params)
                ngx.print("2")
            end)
            router:run()
        ';
    }
--- request
GET /a/c/ccc.html
--- response_body: 1 
--- error_code: 200

=== TEST 10: run normal case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/c/*.html", function(params)
                ngx.print("1")
            end)
            router:get("/a/c/*", function(params)
                ngx.print("2")
            end)
            router:run()
        ';
    }
--- request
GET /a/c/
--- response_body: 2
--- error_code: 200

=== TEST 11: route conflicts case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/:d/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/:b/c/", function(params)
                ngx.print(params["b"])
            end)
        ';
    }
--- request
GET /d/c/b
--- response_body_like: conflicts, while the wildcard param already exists 
--- error_code: 500

=== TEST 12: route conflicts case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/c/:c/", function(params)
                ngx.print(2)
            end)
            router:get("/a/:d/c/", function(params)
                ngx.print("1")
            end)
        ';
    }
--- request
GET /d/c/b
--- response_body_like: conflicts, nchild > 0 when add wildcard param 
--- error_code: 500

=== TEST 13: route conflicts case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/*.h/:c", function(params)
                ngx.print(params["b"])
             end)
        ';
    }
--- request
GET /d/c/b
--- response_body_like: `*` shouldn't at the middle of route 
--- error_code: 500

=== TEST 14: route conflicts case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:get("/a/:d/c/", function(params)
                ngx.print("1")
            end)
            router:get("/a/c/:c/", function(params)
                ngx.print(2)
            end)
        ';
    }
--- request
GET /d/c/b
--- response_body_like: conflicts, while the wildcard param already exists
--- error_code: 500

=== TEST 15: catchall case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:any("/a/b/c/:d", function(params)
                ngx.print("token")
            end)
            router:any("/*", function(params)
                ngx.print("all")
            end)
            router:run()
        ';
    }
--- request
GET /a/b/c/d/e
--- response_body: all
--- error_code: 200

=== TEST 16: catchall case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:any("/a/b/c/:d", function(params)
                ngx.print("token")
            end)
            router:any("/*", function(params)
                ngx.print("all")
            end)
            router:run()
        ';
    }
--- request
GET /a/b/c/ccc
--- response_body: token
--- error_code: 200

=== TEST 17: multi token case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:any("/a/:b/", function(params)
                ngx.print("1")
            end)
            router:any("/a/:b/:c", function(params)
                ngx.print("2")
            end)
            router:run()
        ';
    }
--- request
GET /a/b
--- response_body: 1
--- error_code: 200

=== TEST 18: multi token case 
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:any("/a/:b/", function(params)
                ngx.print("1")
            end)
            router:any("/a/:b/:c", function(params)
                ngx.print("2")
            end)
            router:run()
        ';
    }
--- request
GET /a/b/c
--- response_body: 2
--- error_code: 200

=== TEST 19: 404 case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:run(function()
                ngx.status = 404
                ngx.print("not found")
                ngx.exit(ngx.OK)
            end)
        ';
    }
--- request
GET /test/b
--- response_body: not found
--- error_code: 404

=== TEST 20: any method case
--- http_config eval: $::HttpConfig
--- config
    location ~ .* {
        content_by_lua '
            local R = require("resty.router")
            local router = R:new()
            router:any("/a//:b//*", function(params)
                ngx.print("any")
            end)
            router:run()
        ';
    }
--- request
GET /a/////b//c
--- response_body: any
--- error_code: 200

