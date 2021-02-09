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
        end,
        tag = "InvisiWallFront"
    },
    BACK = {
        offsetConfig = {
            useParentNearEdge = Vector3.new(0, 1, 1),
            useChildNearEdge = Vector3.new(0, -1, 1)
        },
        getSize = function(part, height, thickness)
            return Vector3.new(part.Size.X, height, thickness)
        end,
        tag = "InvisiWallBack"
    },
    LEFT = {
        offsetConfig = {
            useParentNearEdge = Vector3.new(1, 1, 0),
            useChildNearEdge = Vector3.new(1, -1, 0)
        },
        getSize = function(part, height, thickness)
            return Vector3.new(thickness, height, part.Size.Z)
        end,
        tag = "InvisiWallLeft"
    },
    RIGHT = {
        offsetConfig = {
            useParentNearEdge = Vector3.new(-1, 1, 0),
            useChildNearEdge = Vector3.new(-1, -1, 0)
        },
        getSize = function(part, height, thickness)
            return Vector3.new(thickness, height, part.Size.Z)
        end,
        tag = "InvisiWallRight"
    }
}

function module.setAllInvisiWalls(props)
    module.setInvisiWalls(props, "FRONT")
    module.setInvisiWalls(props, "BACK")
    module.setInvisiWalls(props, "LEFT")
    module.setInvisiWalls(props, "RIGHT")
end

function module.setInvisiWalls(props, sideName)
    local parentFolder = props.parentFolder or workspace
    local height = props.height or 16
    local thickness = props.thickness or 1
    local wallProps = props.wallProps or {}

    local config = configs[sideName]

    local offsetConfig = config.offsetConfig
    local tag = config.tag
    local getSize = config.getSize

    local parts = Utils.getByTagInParent({parent = parentFolder, tag = tag})

    for _, part in ipairs(parts) do
        local newWall = Instance.new("Part")

        newWall.Parent = part.Parent
        newWall.Color = part.Color
        newWall.Size = getSize(part, height, thickness)
        newWall.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                             {
                parent = part,
                child = newWall,
                offsetConfig = offsetConfig
            })

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

