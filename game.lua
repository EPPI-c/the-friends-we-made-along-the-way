local helper = require 'helper'
local ui = require 'ui'
local levelLib = require 'level'

local game = {}

function game:init(sm, menu, pause, endLevelState)
    self.sm = sm
    self.menuState = menu
    self.pauseState = pause
    self.endLevelState = endLevelState
    self.levelName = ''
    self.levelIndex = 1
end


function game:mousepressed(x, y, button, istouch, presses)
end

function game:draw()
end

function game:update(dt)
end

function game:initMap(map)
    local map, _ = love.filesystem.read(map)

    self.level = levelLib:createMapExisting(map)

    self.levelInitial = helper.deepcopy(self.level)
end

function game:reset()
    self.level = helper.deepcopy(self.levelInitial)
end

function game:changedstate(context)
    if context.from == 'menu' then
        self.levelName = context.levelName
        self.levelIndex = context.levelIndex
        self:initMap(self.levelName)
        Music.music.sound:setLooping(true)
        Music.music.sound:play()
    elseif context.from == 'pause' then
        local musicPos = Music.reverbmusic.sound:tell()
        Music.reverbmusic.sound:stop()
        Music.music.sound:seek(musicPos)
        Music.music.sound:setLooping(true)
        Music.music.sound:play()
        if context.reset then
            self:reset()
        end
    else
        Music.music.sound:setLooping(true)
        Music.music.sound:play()
        self:reset()
    end
end

---@param f boolean the state if focused or not
---for when game is focused or unfocused
---@diagnostic disable-next-line: unused-local
function game:focus(f)
    if not f then
        self.sm:changestate(self.pauseState)
        return
    end
end

---@param key string Character of the released key.
---@param scancode string The scancode representing the released key.
function game:keypressed(key, scancode, isrepeat)
end

return game
