local ui = require 'ui'
local M = {}


function M:init(stateMachine, gameState, menuState)
    self.sm = stateMachine
    self.gameState = gameState
    self.menuState = menuState
    self.level = '1'

    local menu = ui.createButtonDraw('menu', { 1, 1, 1 }, { 0.7, 0.7, 0 }, { 0.3, 0.3, 0.3 }, { 0, 0.7, 0 })
    local menu_func = function()
        self.sm:changestate(self.menuState, nil)
    end
    local buttonwidth = 100
    local buttons = {
        ui.createButton((ScreenAreaWidth-buttonwidth)/2, ScreenAreaHeight - 100, buttonwidth, 50, menu,
            menu_func, 1, 0.2),
    }
    self.menu = ui.createKeyBoardNavigationHorizontal(buttons)
    self.menu.selected = 1
end

function M:update(dt)
    self.menu:update(dt)
end

function M:changedstate(level)
    Music.music.sound:stop()
    Music.reverbmusic.sound:stop()
    if level + 1 > LevelBlock then
        LevelBlock = level + 1
        love.filesystem.write('level-block', tostring(LevelBlock))
    end
    self.level = level
end

function M:draw()
    self.gameState:draw()
    love.graphics.setColor(0, 1, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, ScreenAreaWidth, ScreenAreaHeight)
    love.graphics.setColor(1, 1, 1)
    self.menu:draw()
    love.graphics.setFont(FontBig)
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.printf("CLEARED", 0, 100, ScreenAreaWidth, 'center')
    love.graphics.setFont(Font)
end

---@param x number Mouse x position, in pixels.
---@param y number Mouse y position, in pixels.
---@param button number The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
---@param istouch boolean True if the mouse button press originated from a touchscreen touch-press.
---@param presses number The number of presses in a short time frame and small area, used to simulate double, triple clicks.
---@diagnostic disable-next-line: unused-local
function M:mousepressed(x, y, button, istouch, presses)
    local hit, nohit = self.menu:checkHit(x, y)
    for _, b in ipairs(hit) do
        b.state = 'clicked'
        b:click()
    end
    for _, b in ipairs(nohit) do
        b.state = 'normal'
    end
end

---@param x number The mouse position on the x-axis.
---@param y number The mouse position on the y-axis.
---@param dx number  The amount moved along the x-axis since the last time love.mousemoved was called.
---@param dy number  The amount moved along the y-axis since the last time love.mousemoved was called.
---@param istouch boolean True if the mouse button press originated from a touchscreen touch-press.
---@diagnostic disable-next-line: unused-local
function M:mousemoved(x, y, dx, dy, istouch)
    self.menu:mousemoved(x, y)
end

---@param key string Character of the released key.
---@param scancode string The scancode representing the released key.
---@param isrepeat boolean Whether this keypress event is a repeat. The delay between key repeats depends on the user's system settings.
---Callback function triggered when a keyboard key is pressed.
---@diagnostic disable-next-line: unused-local
function M:keypressed(key, scancode, isrepeat)
    self.menu:key(key, isrepeat)
end

return M
