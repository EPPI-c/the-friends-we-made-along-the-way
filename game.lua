local helper = require 'helper'
local ui = require 'ui'
local levelLib = require 'level'

local game = {}

function game:init(sm, menu, pause, endLevelState)
    self.sm = sm
    self.sizeOfNotes = 40
    self.menuState = menu
    self.pauseState = pause
    self.endLevelState = endLevelState
    self.levelName = ''
    self.levelIndex = 1
    self.measure = nil
    self.measures = {}
    for i = 1, 12, 1 do
        self.measures[i] = {'0','0','0','0'}
    end
    self.beat = 0     -- measured in beats
    self.lastbeat = 0 -- measured in seconds
    self.songPosition = 0
    self.playAreaX = ScreenAreaWidth / 4
    self.laneCoords = helper.center_coords(helper.create_coord(self.playAreaX, 0), helper.create_coord(3 * self.playAreaX, 0), 4, true)
    local noteSize = ScreenAreaHeight / 13
end

function game:createLine(line, lastbeat)
    line = {
        one = string.sub(line, 1, 1),
        two = string.sub(line, 2, 2),
        three = string.sub(line, 3, 3),
        four = string.sub(line, 4, 4),
        lastbeat = lastbeat,
    }
    function line:draw()
        local y = (ScreenAreaHeight - game.sizeOfNotes) - (self.crochet * (lastbeat - game.lastbeat))
    end
end

function game:mousepressed(x, y, button, istouch, presses)
end

function game:draw()
    love.graphics.setColor(0, .2, 0)
    love.graphics.rectangle('fill', ScreenAreaWidth / 4, 0, 2 * ScreenAreaWidth / 4, ScreenAreaHeight)

    local playAreaWidth = 2 * ScreenAreaWidth / 4

    love.graphics.setColor(0, 0.3, 0)
    love.graphics.rectangle('fill', self.playAreaX, 0, playAreaWidth, ScreenAreaHeight)

    print(self.playAreaX)

    love.graphics.setColor(0, 0.3, 0.4)
    local width = playAreaWidth / 8
    for k, v in pairs(self.laneCoords) do
        love.graphics.rectangle('fill', v.x - width / 2, v.y, width, ScreenAreaHeight)
    end

    love.graphics.setColor(1, 1, 1)
    local size = ScreenAreaHeight / 13
    love.graphics.rectangle('fill', 20, 00, size, size)
    love.graphics.rectangle('fill', 20, 720-size, size, size)
end

function game:update(dt)
    self.songPosition = self.songPosition + dt
    if self.songPosition > self.lastbeat + self.crochet then
        self.lastbeat = self.lastbeat + self.crochet
        self.beat = self.beat + 1
        local measure = self.level.measures[self.beat]
        if measure then
            table.insert(self.measures, measure)
        end
    end
    self.bpms = self.level:getBPMS(self.beat)
    self.crochet = 60 / self.bpms
end

function game:initMap(map)
    local map, _ = love.filesystem.read(map)

    self.level = levelLib:createMapExisting(map)
    self.bpms = self.level:getBPMS(self.beat)
    self.crochet = 60 / self.bpms

    self.levelInitial = helper.deepcopy(self.level)
end

function game:reset()
    self.level = helper.deepcopy(self.levelInitial)
end

function game:changedstate(context)
    self:initMap("levels/Tetoris/Tetoris.ssc")
    -- if context.from == 'menu' then
    --     self.levelName = context.levelName
    --     self.levelIndex = context.levelIndex
    --     self:initMap(self.levelName)
    --     -- Music.music.sound:setLooping(true)
    --     -- Music.music.sound:play()
    -- elseif context.from == 'pause' then
    --     -- local musicPos = Music.reverbmusic.sound:tell()
    --     -- Music.reverbmusic.sound:stop()
    --     -- Music.music.sound:seek(musicPos)
    --     -- Music.music.sound:setLooping(true)
    --     -- Music.music.sound:play()
    --     if context.reset then
    --         self:reset()
    --     end
    -- else
    --     -- Music.music.sound:setLooping(true)
    --     -- Music.music.sound:play()
    --     self:reset()
    -- end
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
