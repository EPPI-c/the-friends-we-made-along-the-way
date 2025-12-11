local helper = require 'helper'

local M = {
}

function M:init()
end

function M:trim(s)
    return s:match("^%s*(.-)%s*$")
end

function M:parseMetaData(rest)
    local left, right = helper.splitFirst(rest, ":")
    if not left or not right then return nil, nil, nil end
    local _, key = helper.splitFirst(left, "#")
    local value, rest = helper.splitFirst(right, ";")
    return key, value, rest
end

function M:createMapExisting(map)
    local rest = map
    local key, value
    repeat
        key, value, rest = self:parseMetaData(rest)
    until rest == nil
end

return M
