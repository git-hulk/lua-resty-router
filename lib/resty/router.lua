-- Copyright (C) Tianyi Lin (hulk)

local _M = {_VERSION = "0.1"}
local _mt = {__index = _M}

local _P = require "resty.path_parser"
local _nodeType = {normal = 1, wildcard = 2, catchall = 3}
local _methods = {'head', 'get', 'post', 'put', 'delete', 'patch', 'trace', 'connect', 'options'}

function _M.new()
    local self = {}
    self.routes = {}
    self.const_routes = {}
    return setmetatable(self, _mt)
end

function _M._new_child(self, token)
    local c
    local n = string.len(token)
    local nodeType = _nodeType.normal
    if not token then
        return nil
    end
    c = string.byte(token, 1) 
    if c == 58 then -- char(:)
        token = string.sub(token, 2)
        nodeType = _nodeType.wildcard  
    elseif c == 42 and n == 1 then -- char(*)
        nodeType = _nodeType.catchall
    elseif c == 42 and n > 2 and string.byte(token, 2) == 46 then -- char(.)
        nodeType = _nodeType.catchall
        token = string.sub(token, 3)
    end
    return {
        token = token,
        childs = {},
        nchild = 0,
        handler = nil,
        nodeType = nodeType
    }
end

function _M.throw(self, exception)
    ngx.header.content_type = "text/plain"
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.say(string.format("{\"error\": \"%s\"}", exception))
    ngx.exit(ngx.OK)
end

local function trim_slash(str)
    if not str or str == "" then
        return str
    end
    local n = string.len(str)
    local c = string.byte(str, n)
    while n > 1 and c ==  47 do -- char(/)
        n = n - 1
        c = string.byte(str, n)
    end
    return string.sub(str, 1, n)
end

function _M.add_route(self, method, route, handler)
    if not method or not route or not handler then
        return "method, route, handler can't be empty" 
    end
    local typ = type(handler)
    if typ ~= "function" and typ ~= "string" then
        return string.format("handler type %s is not allowed", typ)
    end
    if typ == "string" then
        handler = require(handler)
        typ = type(handler)
        if typ == "table" then
            handler = handler["handle"]
        end
        typ = type(handler)
        if typ ~= "function" then
            return string.format("handler type %s is not allowed", typ)
        end
    end
    
    if not self.const_routes[method] then
        self.const_routes[method] = {}
    end

    method = string.lower(method)
    route = string.lower(route)
    route = trim_slash(route)

    if route == "*" or route == "/*" then -- catch all url
        self.const_routes[method]["*"] = handler
        return
    end
    local _, nparam = string.gsub(route, "[:*]", " ")
    if nparam == 0 then
        self.const_routes[method][route] = handler
        return
    end

    local node = self.routes[method]
    if not node then -- add root node
        node = self:_new_child("/") 
        self.routes[method] = node
    end
    local child = nil
    local parser = _P:new(route)
    local token, err = parser:next_token()
    while token and not err do
        if string.len(token) == 0 then
            goto continue
        end
        child = self:_new_child(token)
        if not child then
            self:throw("new child error")
        end
        if node.childs[":token"] then
            self:throw("conflicts, while the wildcard param already exists")
        end
        if child.nodeType == _nodeType.normal then
            if not node.childs[token] then
                node.childs[token] = child
                node.nchild = node.nchild + 1
                node = child
            else
                node = node.childs[token]
            end
        elseif child.nodeType == _nodeType.wildcard then
            if node.nchild > 0 then
                self:throw("conflicts, nchild > 0 when add wildcard param")
            end
            node.nchild = 1
            node.childs[":token"] = child
            node = child
        end
        token, err = parser:next_token()
        if child.nodeType == _nodeType.catchall and token then
            self:throw("`*` shouldn't at the middle of route")
        end
        ::continue::
    end
    if err then
        self:throw(err)
    end
    if child.nodeType == _nodeType.catchall then
        child.handler =  handler 
        if node.childs[":token"] then
            self:throw("conflicts, add `*` when wildcard param already exists")
        end
        if not node.childs["*"] then
            node.childs["*"] = {}
        end
        node.childs["*"][child.token] = child
        node.nchild = node.nchild + 1
    else
        node.handler = handler -- add handler for the last token
    end
end

function _M._catchall(self, node, path)
    if not node or not node.childs["*"] then
        return nil
    end
    node = node.childs["*"]
    local ind = string.find(string.reverse(path), ".", 1, true)
    if ind then
        local suffix = string.sub(path, string.len(path) - ind + 2)
        if node and node[suffix] then
            return node[suffix].handler 
        end
    end
    node = node["*"]
    if node then
        return node.handler
    end
    return nil
end

function _M.find_route(self, method, path) 
    local params = {}
    if not method or not path then
        return nil, params, "method or path can't be empty"
    end

    method = string.lower(method)
    path = string.lower(path)
    path = trim_slash(path)
    if self.const_routes[method] and self.const_routes[method][path] then
        return self.const_routes[method][path], params, nil
    end
    local node = self.routes[method]
    if not node then
        if self.const_routes[method] and self.const_routes[method]["*"] then
            return self.const_routes[method]["*"]
        end
        return nil, params, nil
    end

    local parser = _P:new(path)
    local token, err = parser:next_token()
    while token and not err do
        if node.childs[token] and token ~= ":token" then
            node = node.childs[token]
        elseif node.childs[":token"] then
            node = node.childs[":token"]
            params[node.token] = token
        else
            token, err = parser:next_token()
            if token == nil and err == nil then
                handler = self:_catchall(node, path)
                if handler then
                    return handler, params, nil
                end
            end
            goto not_found
        end
        token, err = parser:next_token()
        if token == nil and err == nil then -- last token in path
            handler = node.handler
        end
    end
    if err then
        return nil, params, err
    end
    if handler then
        return handler, params, nil
    end
    handler = self:_catchall(node, path)
    if handler then
        return handler, params, nil
    end

    ::not_found::
    handler = self.const_routes[method]["*"]
    return handler, params, nil
end

function _M._dump_routes(self, root)
    function tprint (tbl, indent)
        if not indent then indent = 0 end
        for k, v in pairs(tbl) do
            if k ~= "nodeType" and k ~= "token" and k ~= "nchild" then
                formatting = string.rep("..", indent).. "[" .. k .. "]=> "
                if type(v) == "table" then
                    print(formatting)
                    tprint(v, indent+1)
                else
                    print(formatting .. tostring(v))
                end
            end
        end
    end
    tprint(root)
end

for _, method in ipairs(_methods) do
    _M[method] = function(self, path, handler)
        return self:add_route(method, path, handler)
    end
end

function _M.any(self, path, handler)
    for _, method in ipairs(_methods) do
        local err = self:add_route(method, path, handler)
        if err then
            return err
        end
    end
end

function _M.run(self, notfound_handler)
    local method = ngx.req.get_method()
    local uri = ngx.var.uri
    local handle, params, err = self:find_route(method, uri)
    if err then
        return err
    end
    if not handle then
        if type(notfound_handler) == "function" then
            return notfound_handler()
        end
        return "not handler found"
    end
    return handle(params)
end

return _M
