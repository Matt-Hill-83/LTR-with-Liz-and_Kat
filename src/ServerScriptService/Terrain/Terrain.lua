local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initTerrain(props)
    local parentFolder = props.parentFolder or workspace

    local config = {

        -- 
    }

    local materials = Enum.Material:GetEnumItems()

    for _, material in ipairs(materials) do
        local tagName = "T-" .. material.Name

        local parts = Utils.getByTagInParent(
                          {parent = parentFolder, tag = tagName})

        for _, part in ipairs(parts) do
            Utils.convertItemAndChildrenToTerrain(
                {parent = part, material = material, ignoreKids = true})
        end
    end
end

return module

