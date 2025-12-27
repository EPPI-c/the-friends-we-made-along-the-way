local ui = require 'ui'
local helper = require 'helper'

local M = {}

function M:init(stateMachine, gameState, menuState)
    self.sm = stateMachine
    self.gameState = gameState
    self.menuState = menuState
    self.timer = helper.createTimer()
    self.history = {}
    self.timerMax = 2
    local upStart = 1.1
    local upEnd = 1
    local downEnd = 0.9
    local normalFont = PlayArea / 10
    local biggestFont = PlayArea / 5
    self.points = {
        points = 0,
        newpoints = 0,
        scaleUp = helper.generate_linear_function(upStart, normalFont, upEnd, biggestFont),
        scaleDown = helper.generate_linear_function(upEnd, biggestFont, downEnd, normalFont),
        color = { 0, 1, 0 },
    }
    function M.points:draw()
        local scaleFactor = normalFont
        if M.timer.timer <= upStart and M.timer.timer > upEnd then
            scaleFactor = self.scaleUp(M.timer.timer)
            love.graphics.setColor(self.color)
        elseif M.timer.timer <= upEnd and M.timer.timer > downEnd then
            love.graphics.setColor(self.color)
            self.points = self.newpoints
            scaleFactor = self.scaleDown(M.timer.timer)
        else
            love.graphics.setColor(1, 1, 1)
        end
        local font = love.graphics.setNewFont(scaleFactor)
        local h = font:getHeight()
        love.graphics.printf(tostring(self.points), 0, RealHeight / 4 - h / 2, RealWidth, "center")
    end
end

function M:update(dt)
    self.timer:update(dt)
end

local function doCharacterStuff(arg)
    M.points.newpoints = arg.character:calculate(arg.history, arg.counter)
    print(arg.character.name, M.points.newpoints - M.points.points)
    if M.points.newpoints > M.points.points then
        M.points.color = { 0, 1, 0 }
    elseif M.points.newpoints < M.points.points then
        M.points.color = { 1, 0, 0 }
    else
        M.points.color = { 1, 1, 1 }
    end
end

local function doCounterStuff(arg)
    M.points.newpoints = arg.counter:calculate(arg.history)
end

function M:changedstate(selectedCharacters, history, counter)
    self.selectedCharacters = selectedCharacters
    self.history = history
    self.counter = counter
    self.timer:reset()
    self.timer.events = {}
    self.timer:addEvent(2, doCounterStuff, { history = history, counter = counter })
    for i, character in ipairs(selectedCharacters) do
        self.timer:addEvent(2, doCharacterStuff, { character = character, history = history, counter = counter })
    end
    self.timer:start()
end

function M:draw()
    love.graphics.setColor(0.23, 0.23, 0.23)
    love.graphics.rectangle('fill', 0, 0, RealWidth, RealHeight)
    self.points:draw()
end

---@param x number Mouse x position, in pixels.
---@param y number Mouse y position, in pixels.
---@param button number The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param istouch boolean True if the mouse button press originated from a touchscreen touch-press.
---@param presses number The number of presses in a short time frame and small area, used to simulate double, triple clicks.
---@diagnostic disable-next-line: unused-local
function M:mousepressed(x, y, button, istouch, presses)
end

---@param x number The mouse position on the x-axis.
---@param y number The mouse position on the y-axis.
---@param dx number  The amount moved along the x-axis since the last time love.mousemoved was called.
---@param dy number  The amount moved along the y-axis since the last time love.mousemoved was called.
---@param istouch boolean True if the mouse button press originated from a touchscreen touch-press.
---@diagnostic disable-next-line: unused-local
function M:mousemoved(x, y, dx, dy, istouch)
end

---@param key string Character of the released key.
---@param scancode string The scancode representing the released key.
---@param isrepeat boolean Whether this keypress event is a repeat. The delay between key repeats depends on the user's system settings.
---Callback function triggered when a keyboard key is pressed.
---@diagnostic disable-next-line: unused-local
function M:keypressed(key, scancode, isrepeat)
end

return M
