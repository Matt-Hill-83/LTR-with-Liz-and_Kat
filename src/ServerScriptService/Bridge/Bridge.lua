local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initBridges(props)
    local parentFolder = props.parentFolder or workspace
    local rods = Utils.getDescendantsByName(parentFolder, "RodConstraint")

    for i, rod in ipairs(rods) do
        if rod.Attachment0.Parent and rod.Attachment1.Parent then
            Utils.createBridge({
                p0 = rod.Attachment0.Parent.Position,
                p1 = rod.Attachment1.Parent.Position,
                templateName = "Bridge"
            })
            -- rod:Destroy()
        end
    end

end

return module

