local M = {}

function M:init(composer, perfect, good, ok)
    self.history = {}
    self.hits = { false, false, false, false }
    self.composer = composer
    self.timings = {
        { "perfect", perfect },
        { "good",    good },
        { "ok",      ok },
    }
    Events.on("removeLine", self.resetHits)
    Events.on("left", self.checkLeft)
    Events.on("down", self.checkDown)
    Events.on("up", self.checkUp)
    Events.on("right", self.checkRight)
end

function M.resetHits(line)
    for lane, hit in pairs(M.hits) do
        if line.lanes[lane] == '1' and not hit then
            table.insert(M.history, "miss")
            Events.emit("miss")
        end
        M.hits[lane] = false
    end
end

function M:check(lane, line, playerbeat)
    if not line then print('nil') end
    -- no note
    if line.lanes[lane] ~= '1' or self.hits[lane] then
        table.insert(self.history, "miss")
        Events.emit("miss")
        return
    end

    -- check note timing
    local truebeat = line.lastbeat
    local offset = math.abs(truebeat - playerbeat)
    for _, v in pairs(self.timings) do
        if offset <= v[2] then
            self.hits[lane] = true
            table.insert(self.history, v[1])
            line.drawlanes[lane] = false
            Events.emit(v[1])
            return
        end
    end

    -- missed timing
    table.insert(self.history, "miss")
    Events.emit("miss")
end

function M.checkLeft(playerbeat)
    -- left
    M:check(1, M.composer.lines[1], playerbeat)
end

function M.checkDown(playerbeat)
    -- down
    M:check(2, M.composer.lines[1], playerbeat)
end

function M.checkUp(playerbeat)
    -- up
    M:check(3, M.composer.lines[1], playerbeat)
end

function M.checkRight(playerbeat)
    -- right
    M:check(4, M.composer.lines[1], playerbeat)
end

return M
