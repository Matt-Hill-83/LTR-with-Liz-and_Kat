local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local Door = require(Sss.Source.Door.Door)

local module = {}

function module.initHexWalls(props)
    local parentFolder = props.parentFolder or workspace
    local wallPositioners =
        Utils.getDescendantsByName(parentFolder, "WallProxy")

    for _, positioner in ipairs(wallPositioners) do
        local label = Utils.getFirstDescendantByName(positioner,
                                                     "WallProxyLabel")

        local word = label.Text

        if word ~= "---" then
            local doorProps = {
                positioner = positioner,
                parentFolder = parentFolder,
                keyName = word,
                width = 20
                -- width = 32
            }

            local newDoor = Door.initDoor(doorProps)
            local doorPart = newDoor.PrimaryPart

            doorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                  {
                    parent = positioner,
                    child = doorPart,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(0, 1, 0),
                        useChildNearEdge = Vector3.new(0, -1, 0),
                        offsetAdder = Vector3.new(0, 0, 0)
                    }
                })

            doorPart.CFrame = doorPart.CFrame *
                                  CFrame.Angles(0, math.rad(90), 0)
        end
    end
end

return module

