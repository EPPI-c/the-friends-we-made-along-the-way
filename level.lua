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

function M:getBPMS(beat, bpmsTable)
    local bpm
    for _, v in pairs(bpmsTable) do
        if bpm == nil and beat >= v[1] then
            bpm = v[2]
        end
    end
    return bpm
end

function M:parseNotes(measureString, bpmsTable, nextbeat)
    local rest, left
    rest = helper.remove_empty_lines(measureString)
    local measure = {}
    repeat
        left, rest = helper.splitFirst(rest, '\n')
        local line = {
            lanes = {
                string.sub(left, 1, 1),
                string.sub(left, 2, 2),
                string.sub(left, 3, 3),
                string.sub(left, 4, 4),
            },
            lastbeat = nextbeat,
        }

        table.insert(measure, line)
    until rest == nil

    assert(#measure ~= 0, 'empty measure')
    local beatPerLine = 4 / #measure -- hardcoded 4/4 signature
    for _, line in pairs(measure) do
        line.lastbeat = nextbeat
        line.crochet = 60 / M:getBPMS(nextbeat, bpmsTable)
        nextbeat = nextbeat + line.crochet * beatPerLine -- might delay because of approximation?
        function line:draw(noteSize, songPosition, coords, blue)
            local y = (PlayAreaHitbox.bottomRight.y - noteSize) - (noteSize * (self.lastbeat - songPosition) / self.crochet)
            love.graphics.setColor(1, blue, blue)
            local halfNote = noteSize / 2
            for i, lane in pairs(self.lanes) do
                if lane == '1' then
                    love.graphics.rectangle('fill', coords[i].x - halfNote, y, noteSize, noteSize)
                end
            end
        end
    end
    return measure, nextbeat
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
    level.bpmsTable = {}
    repeat
        left, rest = helper.splitFirst(rest, ",")
        key, value = helper.splitFirst(left, "=")
        table.insert(level.bpmsTable, 1, { tonumber(key), tonumber(value) })
    until rest == nil

    local rest = level.meta["NOTES"]
    local measure
    local beat = 0
    local nextbeat = 0
    repeat
        measure, rest = self:parseMeasure(rest)
        measure, nextbeat = self:parseNotes(measure, level.bpmsTable, nextbeat)
        level.measures[beat] = measure
        beat = beat + 4 -- hardcoded 4/4 signature
    until rest == nil
    level.finalbeat = nextbeat
    return level
end

return M
