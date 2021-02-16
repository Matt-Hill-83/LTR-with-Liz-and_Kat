local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initRinks(props)
    local parentFolder = props.parentFolder or workspace
    local rinks = Utils.getDescendantsByName(parentFolder, "Rink")

    for i, rink in ipairs(rinks) do
        local puck = rink.Puck.PrimaryPart
        local thrust = Instance.new("BodyThrust", puck)
        thrust.Force = Vector3.new(0, 0, 2000)

        local av = Instance.new("BodyAngularVelocity", puck)
        av.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
        av.AngularVelocity = Vector3.new(0, 1, 0)
        av.P = 1250

        -- 
    end

end

return module

