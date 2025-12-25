local M = {}

local function createCharacter(name)
    local character = {
        name = name,
    }

    function character:remove(list)
        local k, v
        v = nil
        repeat
            k, v = next(list, k)
        until v == self
        table.remove(list, k)
    end

    return character
end

M.clara = createCharacter("Clara")
M.koko = createCharacter("Koko")

return M
