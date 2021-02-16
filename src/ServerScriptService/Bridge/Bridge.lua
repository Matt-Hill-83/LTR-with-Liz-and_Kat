local Sss = game:GetService("ServerScriptService")

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

    bridgePart.Size =
        Vector3.new(bridgePart.Size.X, bridgePart.Size.Y, Distance)

    bridgePart.Anchored = true
    local walls = Utils.getDescendantsByName(newBridge, "Wall")

    for _, wall in ipairs(walls) do
        wall.Size = Vector3.new(wall.Size.X, wall.Size.Y, Distance)

        -- local parent = props.parent
        -- local material = props.material or Enum.Material.LeafyGrass
        -- module.convertItemAndChildrenToTerrain(
        --     {parent = wall, material = Enum.Material.Grass})
        game.Workspace.Terrain:FillBlock(wall.CFrame, wall.Size,
                                         Enum.Material.Grass)
    end
end

function module.initBridges(props)
    local parentFolder = props.parentFolder or workspace
    local rods = Utils.getDescendantsByName(parentFolder, "RodConstraint")

    for i, rod in ipairs(rods) do
        if rod.Attachment0.Parent and rod.Attachment1.Parent then
            module.createBridge({
                p0 = rod.Attachment0.Parent.Position,
                p1 = rod.Attachment1.Parent.Position,
                templateName = "Bridge"
            })
            -- rod:Destroy()
        end
    end

end

return module

