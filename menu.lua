local helper = require "helper"
local levelLib = require 'level'
local ui = require "ui"
local M = {}


local function createButtonDraw(text, textcolor, normalcolor, selectedcolor, clickedcolor)
    return function(x, y, xs, ys, state)
        local color
        if state == 'clicked' then
            color = clickedcolor
        else
            color = normalcolor
        end
        local opacity
        if state == 'selected' then
            love.graphics.setColor(selectedcolor)
            opacity = selectedcolor[4]
            -- love.graphics.rectangle('fill', x + 4, y + 4, xs, ys)
        else
            opacity = color[4]
            love.graphics.setColor(color)
        end
        love.graphics.rectangle('fill', x, y, xs, ys)

        textcolor[4] = opacity
        love.graphics.setColor(textcolor)
        local font = love.graphics.getFont()
        love.graphics.printf(text, x, y + (ys - font:getHeight()) / 2, xs, 'center')
    end
end

function M:getLevelStr()
    local map, _ = love.filesystem.read(self.files[self.index])
    return map
end

function M:createMenu()
    local options
    if self.index > LevelBlock and LevelBlock < self.normal then
        options = {}
    elseif self.index <= self.normal then
        options = {
            self.startButton,
            self.configButton,
        }
    elseif self.index <= self.custom then
        options = {
            self.startButton,
            self.copyButton,
            self.configButton,
            self.deleteButton,
        }
    else
        options = {
            self.levelEditorButton,
            self.pasteButton,
            self.configButton,
        }
    end

    local coords = helper.center_coords(
        helper.create_coord(0, 0),
        helper.create_coord(200, RealHeight),
        4,
        false
    )

    local w = 150
    local h = 30
    local buttons = {}
    local textcolor = { 1, 1, 1 }
    local normalcolor = { 0.4, 0.4, 0.4, 0.5 }
    local selectedcolor = { 0, 0.7, 0 }
    local clickedcolor = { 0.4, 0.4, 0.4 }

    for i, option in ipairs(options) do
        local buttondraw = createButtonDraw(option.text, textcolor, normalcolor, selectedcolor, clickedcolor)
        local button = ui.createButton(coords[#coords + 1 - i].x - w / 2,
            coords[#coords + 1 - i].y - h / 2,
            w,
            h,
            buttondraw,
            option.isPressed,
            #options + 1 - i,
            0.2
        )
        table.insert(buttons, button)
    end

    self.menu = ui.createKeyBoardNavigation(buttons)
    self.menu.selected = #self.menu.items
end

local function createButtonImage(x, y, image, clicked)
    local w, h = image:getDimensions()
    local draw = function(x, y, xs, ys, state)
	    love.graphics.setColor(1, 1, 1)
	    love.graphics.draw(image, x, y)
    end
    return ui.createButton(x, y, w, h, draw, clicked, 1, 0.2)
end

function M:init(sm, Game_state, configurationState)
    self.sm = sm
    self.Game_state = Game_state
    self.configurationState = configurationState
    self.index = 1
    -- self.background = love.graphics.newImage('images/background.png')
    -- self.house = love.graphics.newImage('images/house.png')
    -- self.houseCustom = love.graphics.newImage('images/houseCustom.png')
    -- self.housew, self.househ = self.house:getDimensions()
    -- self.mat = love.graphics.newImage('images/mat.png')
    -- self.moon = love.graphics.newImage('images/moon.png')
    -- self.vampireFront = love.graphics.newImage('images/vampireFront.png')
    self.dialog = ui.createDialog(200, RealHeight - 110, RealWidth - 400, 70)
    self.startlevel = false
    self.starttimer = 0
    -- local arrow = love.graphics.newImage('images/arrow.png')
    -- local arrowLeft = love.graphics.newImage('images/arrowleft.png')
    -- self.arrow = createButtonImage(ScreenAreaWidth - 33, ScreenAreaHeight / 2 - 13, arrow, right)
    -- self.arrowLeft = createButtonImage(20, ScreenAreaHeight / 2 - 13, arrowLeft, left)
    self.startfadein = helper.generate_linear_function(1, 0, 5, 1)
    self.copyButton = {
        text = 'COPY',
        isPressed = function()
            love.system.setClipboardText(self:getLevelStr())
            self.dialog:next()
            self.dialog:addtext('copied map to clipboard')
            self:readLevels()
        end
    }
    self.pasteButton = {
        text = 'PASTE',
        isPressed = function()
            local map = love.system.getClipboardText()
            if levelLib:validateMap(map) then
                levelLib:export(map)
                self.dialog:next()
                self.dialog:addtext('added custom map')
                self:readLevels()
                self:createMenu()
            else
                self.dialog:next()
                self.dialog:addtext('invalid map')
            end
        end
    }
    self.levelEditorButton = {
        text = 'LEVEL-EDITOR',
        isPressed = function()
            self.sm:changestate(self.levelEditor, nil)
        end
    }
    self.configButton = {
        text = 'CONFIG',
        isPressed = function()
            self.sm:changestate(self.configurationState, self)
        end
    }
    self.startButton = {
        text = 'START',
        isPressed = function()
            Soundfx.startlevel.sound:play()
            self.startlevel = true
        end
    }
    self.deleteButton = {
        text = 'DELETE',
        isPressed = function()
            self.dialog:next()
            self.dialog:addtext('level Deleted')
            love.filesystem.remove(self.files[self.index])
            self:readLevels()
            self:createMenu()
        end
    }
end

---for drawing stuff
function M:draw()
    love.graphics.setColor(1, 1, 1)
    -- love.graphics.draw(self.background, 0, 0)
    -- love.graphics.draw(self.moon, 15, 10)
    --
    -- love.graphics.push()
    -- love.graphics.translate((ScreenAreaWidth - self.housew) / 2, 5)
    -- if self.index > self.normal then
    --     love.graphics.draw(self.houseCustom)
    -- else
    --     love.graphics.draw(self.house)
    -- end
    -- if self.index <= LevelBlock or LevelBlock >= self.normal then
    --     love.graphics.draw(self.mat, 173, 187)
    -- end
    -- local font = love.graphics.getFont()
    -- local h = font:getHeight()
    -- love.graphics.setColor(0, 0, 0)
    -- if self.index > self.custom then
    --     love.graphics.printf('+', 304, 161 - h, 32, 'center')
    -- else
    --     love.graphics.printf(self.index, 304, 161 - h, 32, 'center')
    -- end
    -- love.graphics.pop()
    --
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.draw(self.vampireFront, 180, 180)
    -- self.menu:draw()
    -- self.dialog:draw()
    -- if self.startlevel then
    --     love.graphics.setColor(0, 0, 0, self.startfadein(self.starttimer))
    --     love.graphics.rectangle('fill', 0, 0, ScreenAreaWidth, ScreenAreaHeight)
    -- end
    -- self.arrow:draw()
    -- self.arrowLeft:draw()
end

---@param dt number seconds since the last time the function was called
---for game logic
function M:update(dt)
    if self.startlevel then
        if self.starttimer > 5 then
            self.sm:changestate(self.Game_state, { from = 'menu', levelName = self.level, levelIndex = self.index })
        end
        self.starttimer = self.starttimer + dt
        return
    end
    self.menu:update(dt)
    self.dialog:update(dt)
end

function M:readLevels()
    self.files = love.filesystem.getDirectoryItems('levels')
    for k, v in ipairs(self.files) do
        self.files[k] = 'levels/' .. v
    end
    self.normal = #self.files
    Normal = self.normal
    self.customfiles = love.filesystem.getDirectoryItems('customlevels')
    for _, v in ipairs(self.customfiles) do
        table.insert(self.files, 'customlevels/' .. v)
    end
    self.custom = #self.files
    if self.index > self.custom + 1 then
        self.index = #self.files
    end
    self:createMenu()
    self.level = self.files[self.index]
end

---called when state changed to this state
function M:changedstate()
    self.startlevel = false
    self.starttimer = 0
    -- Music.reverbmusic.sound:stop()
    -- Music.music.sound:stop()
    self:readLevels()
end

function M:mousepressed(x, y, button, istouch, presses)
    if self.startlevel or not x or not y then
        return
    end
    local hit, nohit = self.menu:checkHit(x, y)
    for _, b in ipairs(hit) do
        b.state = 'clicked'
        b:click()
    end
    for _, b in ipairs(nohit) do
        b.state = 'normal'
    end
    if self.arrowLeft:checkHit(x, y) then
	    self.arrowLeft:click()
    end
    if self.arrow:checkHit(x, y) then
	    self.arrow:click()
    end
end

function M:mousemoved(x, y, dx, dy, istouch)
    if self.startlevel then
        return
    end
    self.menu:mousemoved(x, y)
end

function M:countHouse()
    self.dialog:next()
    if self.index > LevelBlock and LevelBlock < self.normal then
        local str = "I'm not welcome in this home :("
        self.dialog:addtext(str, { 0.1, 0.1, 0.1 }, 1)
    else
        local str
        if self.index == 1 then
            str = '%d house AH AH AH'
        else
            str = '%d houses AH AH AH'
        end
        self.dialog:addtext(string.format(str, self.index), { 0.1, 0.1, 0.1 }, 1)
    end
end

function right()
    if M.index < #M.files + 1 then
        M.index = M.index + 1
    end
    M:createMenu()
    M.level = M.files[M.index]
    M:countHouse()
end

function left()
    if M.index > 1 then
        M.index = M.index - 1
    end
    M:createMenu()
    M:countHouse()
    M.level = M.files[M.index]
end

function M:keypressed(key, scancode, isrepeat)
    if self.startlevel then
        return
    end
    self.menu:key(key, isrepeat)
    if key == 'd' or key == 'right' then
	right()
    elseif key == 'a' or key == 'left' then
	left()
    end
end

return M
