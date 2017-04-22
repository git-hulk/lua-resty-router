Name
====

lua-resty-router - Lua http router for the ngx_lua based on the cosocket API

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [new](#new) 
    * [route](#route) 
    * [run](#run) 
* [Limitations](#limitations)
* [Author](#author)
* [Copyright and License](#copyright-and-license)
* [See Also](#see-also)

Status
======

This library is considered production ready.

Description
===========

This Lua library is a http router for the ngx_lua nginx module:

http://wiki.nginx.org/HttpLuaModule

This Lua library takes advantage of ngx_lua's cosocket API, which ensures
100% nonblocking behavior.

Note that at least [ngx_lua 0.5.0rc29](https://github.com/chaoslawful/lua-nginx-module/tags) or [OpenResty 1.0.15.7](http://openresty.org/#Download) is required.

Synopsis
========

```lua
    lua_package_path "/path/to/lua-resty-memcached/lib/?.lua;;";

    server {
        location /test {
            content_by_lua '
                local Router = require "resty.router"
              router = Router:new()
              router:get("/a/:b/:c", function(params)
                ngx.print(params["b"].."-"..parmams["c"])
              end)
              router:post("/b/c/*.html", function(params)
                ngx.print("echo html")
              end)
              router:any("/c/d/", function(params)
                ngx.print("hello, world")
              end)
            ';
        }
    }
```

[Back to TOC](#table-of-contents)

Methods
=======

The `key` argument provided in the following methods will be automatically escaped according to the URI escaping rules before sending to the memcached server.

[Back to TOC](#table-of-contents)

new
-------
`syntax: r, err = router:new()`

Creates a router object, never return an error.

[Back to TOC](#table-of-contents)

route
-------
#### Using GET, POST, HEAD, PUT, PATCH, DELETE, ANY and OPTIONS

```
local R = require("resty.router")
local router = R:new()
router:get("/GetRoute", handler)
router:post("/PostRoute", handler)
router:head("/HeadRoute", handler)
router:put("/PutRoute", handler)
router:delete("/DeleteRoute", handler)
router:patch("/PatchRoute", handler)
router:options("/OptionsRoute", handler)
router:any("/AnyRoute", handler)
router:run()
```

#### Parameters in path

```
    local R = require("resty.router")
    local router = R:new()

    // This handler will match /user/john but will not match neither /user/ or /user
    router:get("/user/:name", function(params)
        local name = params["name"]
        ngx.print("Hello", name)
        ngx.exit(200)
    end)

    // However, this one will match /user/john/ and also /user/john/send
    // If no other routers match /user/john, it will redirect to /user/john/
    router.get("/user/:name/*", function(params)
        local name = params("name")
        ngx.print("Hello", name)
        ngx.exit(200)
    end)
    
    // This one will match /user/jhon/send.html, also match any uri start with /user/jhon/ and end with .html
    router:get("/user/jhon/*.html", function(params)
        ngx.print("Hello")
        ngx.exit(200)
    end)
    
    router:run()
```

#### handler

Type of parameter handler should be function or string, when type is:

* function, handler would be called when uri is matched
* string, router would require `a.b`, when ret type is table, search method `handle`, if ret type is function, return function would be called.

#### Tips

* '*' rule can be used at the end of the route
* throw http code 500 when route conflicts

run
-------

Method run would find route, and callback the handler. when not handler was found and notfound_handler is set, callback the handler.


```
    local R = require("resty.router")
    local router = R:new()
    router:run() or router:run(ontfound_handler)
``` 

[Back to TOC](#table-of-contents)


Limitations
===========

* This library cannot be used in code contexts like `set_by_lua*`, `log_by_lua*`, and
`header_filter_by_lua*` where the ngx\_lua cosocket API is not available.
* The `resty.memcached` object instance cannot be stored in a Lua variable at the Lua module level,
because it will then be shared by all the concurrent requests handled by the same nginx
 worker process (see
http://wiki.nginx.org/HttpLuaModule#Data_Sharing_within_an_Nginx_Worker ) and
result in bad race conditions when concurrent requests are trying to use the same `resty.memcached` instance.
You should always initiate `resty.memcached` objects in function local
variables or in the `ngx.ctx` table. These places all have their own data copies for
each request.

[Back to TOC](#table-of-contents)


Author
======

Yichun "agentzh" Zhang (章亦春) <agentzh@gmail.com>, OpenResty Inc.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2012-2017, by Tianyi "git-hulk" Lin (林添毅) <hulk.website@gmail.com>.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)


#lua-resty-router
