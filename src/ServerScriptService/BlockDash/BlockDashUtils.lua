local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

local function clearWordRack(miniGameState)
    local renderedWords = miniGameState.renderedWords

    -- delete objects
    for i, obj in ipairs(renderedWords) do
        if obj.word then obj.word:Destroy() end
        renderedWords[i] = nil
    end
    -- clear table entries
    Utils.clearTable(miniGameState.renderedWords)
end

-- module.clearBlockRack = clearBlockRack
module.clearWordRack = clearWordRack
return module
