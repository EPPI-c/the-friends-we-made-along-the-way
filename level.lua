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

function M:parseMeasure(notes)
    local left, right = helper.splitFirst(notes, ",")
    return left, right
end

function M:createMapExisting(map)
    local level = {
        meta = {},
        measures = {}
    }

    local rest = map
    local key, value
    repeat
        key, value, rest = self:parseMetaData(rest)
        if key then
            level.meta[key] = value
        end
    until rest == nil

    local rest = level.meta["BPMS"]
    local left
    local key, value
    local bpmsTable = {}
    repeat
        left, rest = helper.splitFirst(rest, ",")
        key, value = helper.splitFirst(left, "=")
        table.insert(bpmsTable, 1, {tonumber(key), tonumber(value)})
    until rest == nil
    function level:getBPMS(beat)
        local bpm
        for _, v in pairs(bpmsTable) do
            if bpm == nil and beat >= v[1] then
                bpm = v[2]
            end
        end
        return bpm
    end

    local rest = level.meta["NOTES"]
    local measure
    local beat = 0
    repeat
        measure, rest = self:parseMeasure(rest)
        level.measures[beat] = measure
        beat = beat + 4 -- hardcoded 4/4 signature
    until rest == nil

    return level
end

return M
