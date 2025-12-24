local sm = require("state")
Events = require("events")
local gameState = require("game")
local menuState = require("menu")
local helper = require('helper')
local pauseState = require("pause")
local endLevelState = require("victory")
local configuration = require('configuration')
local levelLib = require 'level'

local function create_sound(path, mode, vol)
    if not vol then vol = 1 end
    return { sound = love.audio.newSource(path, mode), vol = vol }
end

function love.load()
    RealWidth = love.graphics.getWidth()
    RealHeight = love.graphics.getHeight()
    ScreenAreaWidth = RealWidth
    ScreenAreaHeight = RealHeight
    PlayArea = math.min(RealWidth, RealHeight)

    if love.filesystem.getInfo('level-block', "file") then
        local data, _ = love.filesystem.read('level-block')
        LevelBlock, _ = tonumber(data)
    else
        LevelBlock = 1
    end

    -- use nearest for pixel art and linear for other things
    love.graphics.setDefaultFilter("nearest")
    love.keyboard.setKeyRepeat(true)
    HsFile = "highscore.txt"
    Stats = helper.loadHighScore(HsFile)
    -- FontFile = 'Alkhemikal.ttf'
    -- Font = love.graphics.newFont(FontFile, 20)
    -- FontBig = love.graphics.newFont(FontFile, 40)
    love.graphics.setNewFont(40)
    -- Font:setFilter("nearest", "nearest")
    -- FontBig:setFilter("nearest", "nearest")
    -- love.graphics.setFont(Font)
    Volumes = {
        generalVolume = 1,
        soundfxVolume = 1,
        musicVolume = 1,
    }
    Soundfx = {
        -- bark = create_sound('sound-fx/bark.mp3', 'static', 0.4),
        -- keyPickUp = create_sound('sound-fx/key-get-39925.mp3', 'static', 0.6),
        -- eat = create_sound('sound-fx/eat-323883.mp3', 'static', 0.4),
        -- growl = create_sound('sound-fx/dogs-growling-3-309525.mp3', 'static', 0.6),
        -- step = create_sound('sound-fx/footstep.mp3', 'static', 2),
        -- point = create_sound('sound-fx/pickupCoin.wav.mp3', 'static', 0.8),
        -- door = create_sound('sound-fx/dooropening.mp3', 'static', 0.7),
        -- select = create_sound('sound-fx/blipSelect.wav.mp3', "static", 0.5),
        -- click = create_sound('sound-fx/click.wav.mp3', "static"),
        -- thunder = create_sound('sound-fx/thunder-for-anime-161022.mp3', 'static'),
        -- startlevel = create_sound('sound-fx/start-level.mp3', 'static'),
    }
    Music = {
        -- music = create_sound('sound-fx/alkan-etude-a-minor-woo.mp3', "stream", 0.5),
        -- reverbmusic = create_sound('sound-fx/alkan-etude-a-minor-woo-reverb.mp3', "stream", 0.5),
    }
    ChangeVolume()

    -- initialize states
    gameState:init(sm, menuState, pauseState, endLevelState)
    menuState:init(sm, gameState, configuration)
    pauseState:init(sm, gameState, menuState, configuration)
    endLevelState:init(sm, gameState, menuState)
    configuration:init(sm)
    sm:changestate(gameState, {from='menu'})
end

function ChangeVolume()
    for _, sound in pairs(Soundfx) do
        sound.sound:setVolume(Volumes.generalVolume * Volumes.soundfxVolume * sound.vol)
    end

    for _, sound in pairs(Music) do
        sound.sound:setVolume(Volumes.generalVolume * Volumes.musicVolume * sound.vol)
    end
end

function love.update(dt)
    -- verify if current state implements the update method
    if sm.state.update then
        -- call update method
        sm.state:update(dt)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if sm.state.keypressed then
        sm.state:keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode, isrepeat)
    if sm.state.keyreleased then
        sm.state:keyreleased(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if sm.state.mousepressed then
        sm.state:mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if sm.state.mousereleased then
        sm.state:mousereleased(x, y, button, istouch, presses)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if sm.state.mousemoved then
        sm.state:mousemoved(x, y, dx, dy, istouch)
    end
end

function love.draw()
    if sm.state.draw then
        sm.state:draw()
    end
end

function love.focus(f)
    if sm.state.focus then
        sm.state:focus(f)
    end
end

function love.resize(w, he)
    RealWidth = w
    RealHeight = he
    PlayArea = math.min(RealWidth, RealHeight)
    if sm.state.resize then
        sm.state:resize()
    end
end
