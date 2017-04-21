# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;;";
};

#no_diff();

run_tests();

__DATA__

=== TEST 1: hmset key-pairs
--- http_config eval: $::HttpConfig
--- config
    location /t {
    }

--- request
GET /t

--- response_body

