local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

function module.initBridge(props)
    local rodParent = props.rodParent or workspace

    local rods = Utils.getDescendantsByName(rodParent, "RodConstraint")
    print('rods' .. ' - start');
    print(rods);

    for _, rod in ipairs(rods) do
        print('rod.Attachment0' .. ' - start');
        print(rod.Attachment0);
        print(rod.Attachment1);

        Utils.createBridge({
            part = rodParent,
            p0 = rod.Attachment0.Parent.Position,
            p1 = rod.Attachment1.Parent.Position,
            templateName = "Bridge"
        })
    end
end

return module

