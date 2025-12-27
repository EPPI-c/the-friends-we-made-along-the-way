local helper = require 'helper'

local M = {
    timer = 0,
    duration = 1,
    message = '',
    colour = { 1, 1, 1 },
    points = 0,
}

function M:init(perfect, good, ok, miss, selectedCharacters)
    self.points = 0
    self.perfect = perfect
    self.good = good
    self.ok = ok
    self.miss = miss
    self.selectedCharacters = selectedCharacters
    self.fadeout = helper.generate_linear_function(0.5, 1, 0, 0)
end

function M:calculate(history)
    local points = 0
    for _, v in ipairs(history) do
        points = points + self[v]
    end
    return points
end

function M:update(dt)
    if self.timer <= 0 then
        self.timer = 0
        return
    end
    self.timer = self.timer - dt
end

function M:draw()
    if self.timer > 0 then
        self.colour[4] = self.fadeout(self.timer)
        love.graphics.setColor(self.colour)
        love.graphics.print(self.message, PlayAreaHitbox.bottomRight.x - 200, PlayAreaHitbox.topLeft.y + 50, -0.2)
    end
    love.graphics.setColor(1, 0, 1)
    love.graphics.print(tostring(self.points), PlayAreaHitbox.topLeft.x + 50, PlayAreaHitbox.topLeft.y + 50)
end

function M.addPerfect()
    M.points = M.points + M.perfect
    M.colour = { 1, 1, 1, 1 }
    M.timer = M.duration
    M.message = "PERFECT"
end

function M.addGood()
    M.points = M.points + M.good
    M.colour = { 0, 0, 1, 1 }
    M.timer = M.duration
    M.message = "GOOD"
end

function M.addOk()
    M.points = M.points + M.ok
    M.colour = { 0, 1, 0, 1 }
    M.timer = M.duration
    M.message = "OK"
end

function M.addMiss()
    M.points = M.points + M.miss
    M.colour = { 1, 0, 0, 1 }
    M.timer = M.duration
    M.message = "MISS"
end

Events.on("perfect", M.addPerfect)
Events.on("good", M.addGood)
Events.on("ok", M.addOk)
Events.on("miss", M.addMiss)

return M
