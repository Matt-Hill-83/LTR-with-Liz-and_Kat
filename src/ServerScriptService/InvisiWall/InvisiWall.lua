local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

function module.setInvisiWallsFront(props)
    local parentFolder = props.parentFolder or workspace
    local height = props.height or 16
    local thickness = props.thickness or 16
    local wallProps = props.wallProps or {}

    local parts = Utils.getByTagInParent(
                      {parent = parentFolder, tag = "InvisiWallFront"})

    for _, part in ipairs(parts) do
        local newWall = Instance.new("Part")
        newWall.Parent = part.Parent
        -- local newWall = Instance.new("Part", part.Parent)
        newWall.Size = Vector3.new(part.Size.X, height, thickness)

        newWall.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                             {
                parent = part,
                child = newWall,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, 1, 1),
                    useChildNearEdge = Vector3.new(0, -1, 1),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            })

        -- part.Transparency = 1
        newWall.Transparency = 0.8
        newWall.CanCollide = true
        newWall.Anchored = false

        Utils.mergeTables(newWall, wallProps)

        local weld = Instance.new("WeldConstraint")
        weld.Name = "WeldConstraint-wall"
        weld.Parent = newWall
        weld.Part0 = newWall
        weld.Part1 = part
    end
end

return module

