local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initStatueGates(props)
    local parentFolder = props.parentFolder or workspace
    local statueGates = Utils.getDescendantsByName(parentFolder, 'StatueGate')

    print('statueGates' .. ' - start')
    print(statueGates)

    local bridges = {}

    return bridges
end

return module
