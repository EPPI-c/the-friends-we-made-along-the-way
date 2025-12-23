local M = {}

function M:init(level)
    self.lines = {}
    for _, measure in ipairs(level.measures) do
        for _, line in ipairs(measure) do
            table.insert(self.lines, line)
        end
    end
end

function M:updateMeasures(songPosition)
    local oneth = self.lines[1]
    local second = self.lines[2]
    if not oneth or not second then return end
    if math.abs(songPosition - oneth.lastbeat)
        >
        math.abs(songPosition - second.lastbeat) then
        Events.emit("removeLine", self.lines[1])
        table.remove(self.lines, 1)
    end
end

return M
