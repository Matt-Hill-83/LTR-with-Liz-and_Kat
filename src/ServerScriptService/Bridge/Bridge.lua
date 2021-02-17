local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.createBridge(props)
    local templateName = props.templateName
    local p0 = props.p0
    local p1 = props.p1

    local bridgeTemplate = Utils.getFromTemplates(templateName)

    local newBridge = bridgeTemplate:Clone()
    newBridge.Parent = workspace
    local bridgePart = newBridge.PrimaryPart

    local Distance = (p0 - p1).Magnitude
    bridgePart.CFrame = CFrame.new(p0, p1) * CFrame.new(0, 0, -Distance / 2)

    bridgePart.Size = Vector3.new(bridgePart.Size.X, bridgePart.Size.Y, Distance)

    bridgePart.Anchored = true
    local walls = Utils.getDescendantsByName(newBridge, 'Wall')

    local strayRegion = Utils.getFirstDescendantByName(newBridge, 'StrayRegion')

    strayRegion.Size = Vector3.new(strayRegion.Size.X, strayRegion.Size.Y, Distance)

    for _, wall in ipairs(walls) do
        wall.Size = Vector3.new(wall.Size.X, wall.Size.Y, Distance)
    end
    return newBridge
end

function module.initBridges(props)
    local parentFolder = props.parentFolder or workspace
    local rods = Utils.getDescendantsByName(parentFolder, 'RodConstraint')

    local bridges = {}
    for i, rod in ipairs(rods) do
        local hasAtt0 = Utils.hasProperty(rod, 'Attachment0')
        local hasAtt1 = Utils.hasProperty(rod, 'Attachment1')

        if hasAtt0 == true and hasAtt1 == true then
            local hasParent0 = Utils.hasProperty(rod.Attachment0, 'Parent')
            local hasParent1 = Utils.hasProperty(rod.Attachment1, 'Parent')

            if hasParent0 and hasParent1 then
                local bridge =
                    module.createBridge(
                    {
                        p0 = rod.Attachment0.Parent.Position,
                        p1 = rod.Attachment1.Parent.Position,
                        templateName = 'Bridge'
                    }
                )
                rod:Destroy()
                if rod.Color.Name == 'Bright yellow' then
                    local cloneProps = {
                        parentTo = bridge,
                        positionToPart = bridge.PrimaryPart,
                        templateName = 'Rink',
                        fromTemplate = true,
                        modelToClone = nil,
                        offsetConfig = {
                            useParentNearEdge = Vector3.new(0, 0, 0),
                            useChildNearEdge = Vector3.new(0, 0, 0),
                            offsetAdder = Vector3.new(0, 20, 0)
                        }
                    }

                    local rinkModel = Utils.cloneModel(cloneProps)
                    rinkModel.Name = 'yyy'

                    table.insert(bridges, bridge)
                end
            end
        end
    end
    return bridges
end

return module
