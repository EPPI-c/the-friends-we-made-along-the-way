local M = {}
local helper = require 'helper'

local function createCharacter(name, description)
    local character = {
        name = name,
        description = description,
    }

    function character:remove(list)
        for k, v in pairs(list) do
            if v == self then
                table.remove(list, k)
                return
            end
        end
    end

    function character:get(list)
        for _, v in pairs(list) do
            if v == self then
                return v
            end
        end
        return nil
    end

    function character:calculate(history, counter)
        return counter:calculate(history)
    end

    return character
end

M.shu = createCharacter("Shu-chan", "Aspiring musician trying to build a band")

M.niko = createCharacter("Niko", "Doubles the points but also doubles the speed")
function M.niko:calculate(history, counter)
    counter.perfect = counter.perfect * 2
    counter.good = counter.good * 2
    counter.ok = counter.ok * 2
    return counter:calculate(history), history
end

M.yasashika = createCharacter("Yasashika", "Turns good into perfect")
function M.yasashika:calculate(history, counter)
    for i, v in ipairs(history) do
        if v == "good" then
            history[i] = "perfect"
        end
    end
    return counter:calculate(history), history
end

M.earRing = createCharacter("Mysterious Ear Ring", "???")

M.kibishika = createCharacter("Kibishika", "dismisses Ok points, in turn increases points by 25%")
function M.kibishika:calculate(history, counter)
    counter.perfect = counter.perfect * 1.25
    counter.good = counter.good * 1.25
    counter.ok = counter.ok * 1.25
    for i, v in ipairs(history) do
        if v == "ok" then
            history[i] = "miss"
        end
    end
    return counter:calculate(history), history
end

M.kibishu = createCharacter("Kibishu", "dismisses everything except Perfect points, increases points by 2x")
function M.kibishu:calculate(history, counter)
    counter.perfect = counter.perfect * 2
    for i, v in ipairs(history) do
        if v == "ok" or v == "good" then
            history[i] = "miss"
        end
    end
    return counter:calculate(history), history
end

M.haru = createCharacter("Haru", "Ignores all misses, never stop trying")
function M.haru:calculate(history, counter)
    local totalItems = #history
    local removedItems = 0
    for i, v in ipairs(history) do
        if v == "miss" then
            history[i] = nil
            removedItems = removedItems + 1
        end
    end

    local i = 1
    local j = 1
    repeat
        if j > totalItems - removedItems then
            history[j] = nil
            j = j + 1
        elseif history[i] then
            history[j] = history[i]
            j = j + 1
        end
        i = i + 1
    until j > totalItems

    return counter:calculate(history), history
end

M.taida = createCharacter("Taida", "slows music down to half speed")

M.kisu = createCharacter("Kisu", "points will only be counted when the score on screen is odd, but they will be doubled")
function M.kisu:calculate(history, counter) -- hardcoded points 20, 15, 10, -5
    local points = 0
    local values = { perfect = 20, good = 15, ok = 10, miss = -5 }
    local double = {}
    local totalItems = #history
    local itemDelta = 0
    for i, v in ipairs(history) do
        if v ~= "miss" then
            if points % 2 == 0 then
                history[i] = nil
                itemDelta = itemDelta - 1
            else
                table.insert(double, i)
                itemDelta = itemDelta + 1
            end
        end
        points = points + values[v]
    end
    -- double items
    for _, v in ipairs(double) do
        table.insert(history, history[v])
    end
    -- reindex
    local i = 1
    local j = 1
    repeat
        if j > totalItems + itemDelta then
            history[j] = nil
            j = j + 1
        elseif history[i] then
            history[j] = history[i]
            j = j + 1
        end
        i = i + 1
    until j > totalItems
    return counter:calculate(history), history
end

return M
