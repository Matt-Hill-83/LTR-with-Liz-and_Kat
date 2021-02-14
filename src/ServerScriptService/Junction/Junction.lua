local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local Utils5 = require(Sss.Source.Utils.U005LetterGrabberUtils)

local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local module = {}

function module.initJunctions(props)
    local parentFolder = props.parentFolder or workspace

    local positioners = Utils.getDescendantsByName(parentFolder, "Junction")
    local template = Utils.getFromTemplates("HexJunction")

    print('positioners' .. ' - start');
    print(positioners);
    for _, positioner in ipairs(positioners) do
        local newHex = template:Clone()
        newHex.Parent = positioner.Parent

        local newHexPart = newHex.PrimaryPart
        local positionerPart = positioner.HexIsland_001_Md_Shell.PrimaryPart
        print('newHexPart' .. ' - start');
        print(newHexPart);
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
        -- positioner:Destroy()
    end
end

return module

