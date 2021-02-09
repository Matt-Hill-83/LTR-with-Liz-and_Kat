local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

local configs = {
    FRONT = {
        offsetConfig = {
            useParentNearEdge = Vector3.new(0, 1, -1),
            useChildNearEdge = Vector3.new(0, -1, -1)
        },
        getSize = function(part, height, thickness)
            return Vector3.new(part.Size.X, height, thickness)
        end
    },
    BACK = {
        useParentNearEdge = Vector3.new(0, 1, 1),
        useChildNearEdge = Vector3.new(0, -1, 1)
    },
    LEFT = {
        useParentNearEdge = Vector3.new(-1, 1, 0),
        useChildNearEdge = Vector3.new(-1, -1, 0)
    },
    RIGHT = {
        useParentNearEdge = Vector3.new(-1, 1, 0),
        useChildNearEdge = Vector3.new(-1, -1, 0)
    }
}

function module.setInvisiWallsFront(props)
    local parentFolder = props.parentFolder or workspace
    local height = props.height or 16
    local thickness = props.thickness or 1
    local wallProps = props.wallProps or {}

    local parts = Utils.getByTagInParent(
                      {parent = parentFolder, tag = "InvisiWallFront"})

    local config = configs.FRONT
    local offsetConfig = config.offsetConfig

    for _, part in ipairs(parts) do
        local size = config.getSize(part, height, thickness)
        -- local size = Vector3.new(part.Size.X, height, thickness)
        module.setInvisiWall(part, wallProps, size, offsetConfig)
    end
end

function module.setInvisiWall(part, wallProps, size, offsetConfig)
    local newWall = Instance.new("Part")
    Utils.mergeTables(newWall, wallProps)

    newWall.Parent = part.Parent
    newWall.Size = size
    newWall.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                         {
            parent = part,
            child = newWall,
            offsetConfig = offsetConfig
        })
    -- part.Transparency = 1
    newWall.Transparency = 0.8
    newWall.CanCollide = true
    newWall.Anchored = false

    local weld = Instance.new("WeldConstraint")
    weld.Name = "WeldConstraint-wall"
    weld.Parent = newWall
    weld.Part0 = newWall
    weld.Part1 = part

    return newWall
end

return module

