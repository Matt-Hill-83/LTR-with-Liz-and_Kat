local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

function module.initHexJunctions(props)
    local parent = workspace
    local hexJunctions = Utils.getDescendantsByName(parent, "HexJunction")

    for _, hex in ipairs(hexJunctions) do
        Utils.convertItemAndChildrenToTerrain({parent = hex})
    end
end

return module

