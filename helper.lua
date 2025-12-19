local M = {}

---Coordinate class
---@class Coord
---@field x number x position
---@field y number y position
---@field distance function
function M.create_coord(x, y)
    local coord = { x = x, y = y }
    ---@param point Coord coordinate to calculate distance to
    ---calculates Chebyshev distance to point
    function coord:distance(point)
        return math.max(math.abs(self.x - point.x), math.abs(self.y - point.y))
    end

    return coord
end

function M.createImage(path, drawFunction)
    local image = {
        image = love.graphics.newImage(path),
        drawFunction = drawFunction
    }
end

function M.deepcopy(obj, seen)
    -- Handle non-tables and previously-seen tables.
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end

    -- New table; mark it as seen an copy recursively.
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in next, obj do res[M.deepcopy(k, s)] = M.deepcopy(v, s) end
    return setmetatable(res, getmetatable(obj))
end

function M.generate_linear_function(x1, y1, x2, y2)
    local a = (y2 - y1) / (x2 - x1)
    local b = y1 - a * x1
    return function(x) return a * x + b end
end

function M.hex_to_rgb(rgb)
    -- clamp between 0x000000 and 0xffffff
    rgb = rgb % 0x1000000 -- 0xffffff + 1

    -- extract each color
    local b = rgb % 0x100         -- 0xff + 1 or 256
    local g = (rgb - b) % 0x10000 -- 0xffff + 1
    local r = (rgb - g - b)
    -- shift right
    g = g / 0x100   -- 0xff + 1 or 256
    r = r / 0x10000 -- 0xffff + 1

    return { r / 255, g / 255, b / 255 }
end

function M.round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

---@class Hitbox
---@field topLeft Coord
---@field bottomRight Coord
---@field check_collision function
---@field draw function

-- creates a hitbox object which comes with collision detection out of the box
---@param coord1 Coord
---@param coord2 Coord
---@return Hitbox
function M.create_hitbox(coord1, coord2)
    local hitbox = {
        topLeft = coord1,
        bottomRight = coord2,
    }
    ---@param other_hitbox Hitbox
    function hitbox:check_collision(other_hitbox)
        -- it uses the most simple algorithm ever, which works fine if you only use square hitboxes
        if other_hitbox.bottomRight.x < self.topLeft.x
            or other_hitbox.bottomRight.y < self.topLeft.y
            or other_hitbox.topLeft.x > self.bottomRight.x
            or other_hitbox.topLeft.y > self.bottomRight.y
        then
            return false
        else
            return true
        end
    end

    function hitbox:isIn(x, y)
        if x < self.topLeft.x
            or y < self.topLeft.y
            or x > self.bottomRight.x
            or y > self.bottomRight.y
        then
            return false
        else
            return true
        end
    end

    function hitbox:draw()
        love.graphics.setColor({ 0.3, 0.3, 0.3, 0.3 })
        local width = self.bottomRight.x - self.topLeft.x
        local height = self.bottomRight.y - self.topLeft.y
        love.graphics.rectangle('fill', self.topLeft.x, self.topLeft.y, width, height)
    end

    return hitbox
end

-- split string on delimiter
function M.split(s, delimiter)
    delimiter = delimiter or '%s'
    local t = {}
    local i = 1
    for str in string.gmatch(s, '([^' .. delimiter .. ']+)') do
        t[i] = str
        i = i + 1
    end
    return t
end

-- split string on delimiter
function M.splitFirst(s, delimiter)
    delimiter = delimiter or '%s'
    local startPos, endPos = string.find(s, delimiter, 1, true)
    if not startPos then
        return s, nil
    end
    local left = string.sub(s, 1, startPos - 1)
    local right = string.sub(s, endPos + 1)
    return left, right
end

function M.create_stats()
    local types = { 'score', 'secondsalive', 'deaths' }
    local stats = {
        game = {},
        high = {},
        sum = {},
    }
    for _, v in pairs(types) do
        stats.game[v] = 0
        stats.high[v] = 0
        stats.sum[v] = 0
    end
    function stats:update(otherstats)
        for k, v in pairs(otherstats.game) do
            self.sum[k] = self.sum[k] + v
            if self.high[k] < v then
                self.high[k] = v
            end
        end
    end

    function stats:init_from_string(string)
        for _, line in pairs(M.split(string, '\n')) do
            local k, v = unpack(M.split(line, '='))
            local firstkey, secondkey = unpack(M.split(k, '>'))
            v = tonumber(v)
            if self[firstkey] then
                if secondkey then
                    self[firstkey][secondkey] = v
                end
            end
        end
    end

    function stats:tostring()
        string = ''
        for k, v in pairs(self.high) do
            string = string .. 'high>' .. k .. '=' .. tostring(v) .. '\n'
        end
        for k, v in pairs(self.sum) do
            string = string .. 'sum>' .. k .. '=' .. tostring(v) .. '\n'
        end
        return string
    end

    return stats
end

function M.loadHighScore(hsFile)
    local stats = M.create_stats()
    if love.filesystem.getInfo(hsFile, "file") then
        local data, _ = love.filesystem.read(hsFile)
        stats:init_from_string(data)
        return stats
    end
    return stats
end

function M.writeHighScore(hsFile, stats)
    love.filesystem.write(hsFile, stats:tostring())
end

-- see if the file exists
function M.file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function M.lines_from(file)
    if not M.file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

-- shallow copy a table
function M.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

---creates a list of centered spaced coords in a rectangle this is useful for ui stuff
---@return table
---@param upperLeft Coord
---@param bottomRight Coord
---@param items number number of coords
---@param horizontal boolean
function M.center_coords(upperLeft, bottomRight, items, horizontal)
    local dir = 'y'
    local nondir = 'x'
    if horizontal then
        dir = 'x'
        nondir = 'y'
    end
    local space = bottomRight[dir] - upperLeft[dir]
    local spacer = space / (items * 2 + 1)
    local positions = {}
    local icoords = {}
    icoords[nondir] = (bottomRight[nondir] - upperLeft[nondir]) / 2
    icoords[dir] = upperLeft[dir]
    for i = 1, items do
        local c = M.create_coord(upperLeft.x + icoords.x, upperLeft.y + icoords.y)
        c[dir] = icoords[dir] + spacer * i + spacer * (i - 1) + spacer / 2
        table.insert(positions, c)
    end

    return positions
end

return M
