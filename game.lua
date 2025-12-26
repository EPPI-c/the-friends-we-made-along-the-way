local helper = require 'helper'
local ui = require 'ui'
local levelLib = require 'level'
local composer = require 'composer'
local judge = require 'judge'
local counter = require 'counter'
local characters = require 'character'

local game = {}

function game:init(sm, menu, pause, endLevelState)
    self.sm = sm
    self.menuState = menu
    self.pauseState = pause
    self.endLevelState = endLevelState
    self.levelName = ''
    self.levelIndex = 1
    self.playing = false
    self.effect:init()
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

game.effect = {
    colour = { 0, 0, 0, 0 },
    timer = 0,
    timerAmount = 0.6,
}

function game.effect:init()
    self.fadeout = helper.generate_linear_function(1, self.timerAmount, 0, 0)
    Events.on("perfect", self.perfect)
    Events.on("good", self.good)
    Events.on("ok", self.ok)
    Events.on("miss", self.miss)
end

function game.effect:update(dt)
    if self.timer <= 0 then
        self.timer = 0
        return
    end
    self.timer = self.timer - dt
end

function game.effect.perfect()
    game.effect.colour = { 1, 1, 1, 1 }
    game.effect.timer = game.effect.timerAmount
end

function game.effect.good()
    game.effect.colour = { 0, 0, 1, 1 }
    game.effect.timer = game.effect.timerAmount
end

function game.effect.ok()
    game.effect.colour = { 0, 1, 0, 1 }
    game.effect.timer = game.effect.timerAmount
end

function game.effect.miss()
    game.effect.colour = { 1, 0, 0, 1 }
    game.effect.timer = game.effect.timerAmount
end

function game.effect:draw()
    self.colour[4] = self.fadeout(self.timer)
    love.graphics.setColor(self.colour)
    love.graphics.rectangle('fill', 0, 0, RealWidth, RealHeight)
end

function game:draw()
    self.effect:draw()

    -- play area
    love.graphics.setColor(0, 0.3, 0)
    love.graphics.rectangle('fill', PlayAreaHitbox.topLeft.x, PlayAreaHitbox.topLeft.y, PlayArea, PlayArea)

    -- lanes
    love.graphics.setColor(0, 0.3, 0.4)
    local width = PlayArea / 8
    for _, v in pairs(self.laneCoords) do
        love.graphics.rectangle('fill', v.x - width / 2, PlayAreaHitbox.topLeft.y, width, PlayArea)
    end

    -- notes
    for _, line in ipairs(composer.lines) do
        if line.lastbeat + line.crochet >= Music.level.sound:tell()
            and
            line.lastbeat <= Music.level.sound:tell() + PlayArea / self.noteSize * line.crochet then
            line:draw(self.noteSize, Music.level.sound:tell(), self.laneCoords)
        end
    end
    counter:draw()
end

function game:update(dt)
    composer:updateMeasures(Music.level.sound:tell())


    if self.playing and not Music.level.sound:isPlaying() then
        self.sm:changestate(self.endLevelState, self.selectedCharacters, judge.history, counter)
    end

    self.effect:update(dt)
    counter:update(dt)
end

function game:initMap(map)
    local perfectTiming = 0.03
    local goodTiming = 0.06
    local okTiming = 0.10
    self.level = levelLib:createMapExisting(map, self.selectedCharacters)
    composer:init(self.level)
    if characters.niko:get(self.selectedCharacters) then
        Music.level.sound:setPitch(2)
        perfectTiming = perfectTiming * 2
        goodTiming = goodTiming * 2
        okTiming = okTiming * 2
    end
    judge:init(composer, perfectTiming, goodTiming, okTiming)
    counter:init(20, 15, 10, -5, self.selectedCharacters)
    Music.level.sound:stop()
    Music.level.sound:play()
    self.playing = true


    self.levelInitial = helper.deepcopy(self.level)
end

function game:reset()
    self.level = helper.deepcopy(self.levelInitial)
end

function game:changedstate(context)
    if context.from == 'menu' or context.from == 'reset' then
        self.selectedCharacters = { characters.niko, characters.yasashika }
        -- self.selectedCharacters = {}
        self:initMap("levels/Tetoris/Tetoris.ssc")
    elseif context.from == 'pause' then
        Music.level.sound:play()
        self.playing = true
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
        self.playing = false
        Music.level.sound:pause()
        return
    end
end

---@param key string Character of the released key.
---@param scancode string The scancode representing the released key.
function game:keypressed(key, scancode, isrepeat)
    if not isrepeat and
        (key == "left"
            or key == "right"
            or key == "up"
            or key == "down") then
        Events.emit(key, Music.level.sound:tell())
    end
end

return game
