-- Copyright (C) Tianyi Lin (hulk)

local _M = {}
local _mt = {__index = _M}

function _M.new(self, path)
    local self = {}
    self.pos = 1
    self.len = string.len(path)
    self.path = path
    self.state = 0 
    return setmetatable(self, _mt)
end

function _M.next_token(self)
    local c
    local sub_start = -1
    local _state = {none = 0, slash = 1, sub = 2, finish = 3}

    if self.state == _state.finish then
        return nil, nil
    end
    while self.pos <= self.len do
        c = string.byte(self.path, self.pos)
        if self.state == _state.none then
            if c == 47 then -- char(/)
                self.state = _state.slash
            else
                self.state = _state.finish
                return nil, "exception"
            end
        elseif self.state == _state.slash then
            if c == 47 then -- char(/)
                goto continue
            end
            self.state = _state.sub
            sub_start = self.pos
        elseif self.state == _state.sub then
            if c == 47 then -- char(/)
                self.state = _state.slash
                return string.sub(self.path, sub_start, self.pos-1), nil
            end
        end
        ::continue::
        self.pos = self.pos + 1
    end
    if self.state == _state.sub and sub_start < self.pos then
        self.state = _state.finsh
        return string.sub(self.path, sub_start, self.pos-1), nil
    end
    self.state = _state.finish
    return nil, nil
end

return _M
