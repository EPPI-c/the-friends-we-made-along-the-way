local ui = require 'ui'
local helper = require 'helper'
local M = {}

function M:init(stateMachine, gameState, menuState, configuration)
    self.sm = stateMachine
    self.gameState = gameState
    self.menuState = menuState
    self.buttonState = self.menuState
    self.configuration = configuration
    self.menubutton = {
        text = 'menu',
        clicked = function()
            self.sm:changestate(self.buttonState)
        end
    }
    local options = {
        {
            text = 'continue',
            clicked = function()
                self.sm:changestate(self.gameState)
            end
        },

        {
            text = 'reset',
            clicked = function()
                self.sm:changestate(self.gameState)
            end
        },

        {
            text = 'configuration',
            clicked = function()
                self.sm:changestate(self.configuration, self)
            end,
        },

        self.menubutton
    }

    local positions = helper.center_coords(
        helper.create_coord(0, 0),
        helper.create_coord(ScreenAreaWidth, ScreenAreaHeight),
        #options,
        false
    )

    local buttonwidth = 120
    local buttonheight = 30
    local halfheight = buttonheight / 2
    local halfbutton = buttonwidth / 2

    local buttons = {}
    for i, option in ipairs(options) do
        local draw = ui.createButtonDraw(option.text, { 1, 1, 1 }, { 0, 0.7, 0 }, { 0.3, 0.3, 0.3 }, { 0, 0.7, 0 })
        local button = ui.createButton(
            positions[i].x - halfbutton,
            positions[i].y - halfheight,
            buttonwidth,
            buttonheight,
            draw,
            option.clicked,
            i,
            0.2
        )
        table.insert(buttons, button)
    end
    self.menu = ui.createKeyBoardNavigation(buttons)
    self.menu.selected = 1
end

function M:update(dt)
    M.menu:update(dt)
end

function M:changedstate()
    MusicPos = Music.music.sound:tell()
    Music.music.sound:stop()
    Music.reverbmusic.sound:seek(MusicPos)
    Music.reverbmusic.sound:setLooping(true)
    Music.reverbmusic.sound:play()
    self.buttonState = self.menuState
    self.menubutton.text = 'menu'
    self.menubutton.clicked = function()
        self.sm:changestate(self.menuState, nil)
    end
end

function M:draw()
    self.gameState:draw()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, ScreenAreaWidth, ScreenAreaHeight)
    self.menu:draw()
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
