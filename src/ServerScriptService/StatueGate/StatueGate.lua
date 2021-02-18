local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initStatueGates(props)
    local hexConfigs = props.configs

    local parentFolder = props.parentFolder
    local statueGates = Utils.getDescendantsByName(parentFolder, 'StatueGate')

    local hexIslandsFolder = Utils.getFirstDescendantByName(parentFolder, 'HexIslands')
    local hexIslandFolders = hexIslandsFolder:getDescendants()
    Utils.sortListByObjectKey(hexIslandFolders, 'Name')

    for hexIndex, hexIsland in ipairs(hexIslandFolders) do
        local hexConfig = hexConfigs[hexIndex]

        local statueConfigs = hexConfig.statueConfigs

        print('statueConfigs' .. ' - start')
        print(statueConfigs)
        print('hexConfigs' .. ' - start')
        print(hexConfigs)
        print('statueGates' .. ' - start')
        print(statueGates)
        if not statueConfigs then
            return
        end

        local bridges = {}

        return bridges
    end
end

return module
