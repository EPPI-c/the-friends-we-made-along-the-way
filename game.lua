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
    self:resize()
end

function game:resize()
    local x = (RealWidth - PlayArea) / 2
    local y = (RealHeight - PlayArea) / 2
    local xe = x + PlayArea
    local ye = y + PlayArea
    local upperLeft = helper.create_coord(x, y)
    local lowerRight = helper.create_coord(xe, ye)
    PlayAreaHitbox = helper.create_hitbox(upperLeft, lowerRight)
    self.laneCoords = helper.center_coords(upperLeft, lowerRight, 4, true)
    self.noteSize = PlayArea / 13
    
end

function game:mousepressed(x, y, button, istouch, presses)
end

function game:draw()
    love.graphics.setColor(0, .2, 0)
    love.graphics.rectangle('fill', PlayAreaHitbox.topLeft.x, PlayAreaHitbox.topLeft.y, PlayArea, PlayArea)

    love.graphics.setColor(0, 0.3, 0)
    love.graphics.rectangle('fill', PlayAreaHitbox.topLeft.x, PlayAreaHitbox.topLeft.y, PlayArea, PlayArea)

    love.graphics.setColor(0, 0.3, 0.4)
    local width = PlayArea / 8
    for _, v in pairs(self.laneCoords) do
        love.graphics.rectangle('fill', v.x - width / 2, PlayAreaHitbox.topLeft.y, width, PlayArea)
    end

    local blue = 1
    for _, measure in pairs(self.level.measures) do
        for _, line in pairs(measure) do
            if blue == 1 then
                blue = 0
            else
                blue = 1
            end
            if line.lastbeat + self.crochet >= self.songPosition and line.lastbeat <= self.songPosition + PlayArea / self.noteSize * self.crochet then
                line:draw(self.noteSize, self.songPosition, self.laneCoords, blue)
            end
        end
    end
end

function game:update(dt)
    self.songPosition = self.songPosition + dt
    if self.songPosition > self.lastbeat + self.crochet then
        self.lastbeat = self.lastbeat + self.crochet
        self.beat = self.beat + 1
    end
    if self.lastbeat > self.level.finalbeat then
        os.exit()
    end
end

function game:initMap(map)
    local map, _ = love.filesystem.read(map)

    self.level = levelLib:createMapExisting(map)

    self.bpm = levelLib:getBPMS(0, self.level.bpmsTable)
    self.crochet = 60 / self.bpm
    self.beat = 0     -- measured in beats
    self.lastbeat = 0 -- measured in seconds
    self.songPosition = 0

    self.levelInitial = helper.deepcopy(self.level)
end

function game:reset()
    self.level = helper.deepcopy(self.levelInitial)
end

function game:changedstate(context)
    if context.from == 'menu' then
        self:initMap("levels/Tetoris/Tetoris.ssc")
    end
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
