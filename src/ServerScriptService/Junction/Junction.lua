local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

function module.initJunctions(props)
    local parentFolder = props.parentFolder or workspace

    local positioners = Utils.getDescendantsByName(parentFolder, "Junction")
    local template = Utils.getFromTemplates("HexJunction")

    for _, positioner in ipairs(positioners) do
        local newHex = template:Clone()
        newHex.Parent = positioner.Parent
        local newHexPart = newHex.PrimaryPart

        -- Weld packages to parent, b/c packages break extrenal welds when they update
        local packageBases = Utils.getDescendantsByName(newHex, "PackageBase")
        for _, packageBase in ipairs(packageBases) do
            local weld = Instance.new("WeldConstraint")
            weld.Name = "WeldConstraintHex-eee"
            weld.Parent = newHexPart
            weld.Part0 = newHexPart
            weld.Part1 = packageBase
        end

        local freeParts = Utils.freeAnchoredParts({item = newHex})

        local positionerPart = positioner.HexIsland_001_Md_Shell.PrimaryPart
        newHexPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                {
                parent = positionerPart,
                child = newHexPart,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, -1, 1),
                    useChildNearEdge = Vector3.new(0, -1, 1),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            })
        positioner:Destroy()

        Utils.anchorFreedParts(freeParts)
    end
end

return module

