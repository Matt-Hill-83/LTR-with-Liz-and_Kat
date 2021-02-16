local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initTerrain(props)
    local parentFolder = props.parentFolder or workspace

    local parts = Utils.getByTagInParent({parent = parentFolder, tag = "T-Rock"})

    for _,part in ipairs(parts) do
        Utils.convertItemAndChildrenToTerrain({parent = parentFolder, material = "Rock"})
end

return module

