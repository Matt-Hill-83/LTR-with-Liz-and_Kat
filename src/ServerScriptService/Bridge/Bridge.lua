local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initBridge(props)
    local rodParent = props.rodParent or workspace
    local rods = Utils.getDescendantsByName(rodParent, "RodConstraint")
    print('rods' .. ' - start');
    print(rods);

    for i, rod in ipairs(rods) do
        print('i' .. ' - start');
        print(i);
        if rod.Attachment0.Parent and rod.Attachment1.Parent then

            Utils.createBridge({
                part = rodParent,
                p0 = rod.Attachment0.Parent.Position,
                p1 = rod.Attachment1.Parent.Position,
                templateName = "Bridge"
            })
        else
            -- 
            print('bad');
            print('rod' .. ' - start');
            print(rod);
        end
    end

end

return module

