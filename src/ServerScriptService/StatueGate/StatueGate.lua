local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initStatueGates(props)
    local hexConfigs = props.configs

    local parentFolder = props.parentFolder

    local hexIslandFolderBox = Utils.getFirstDescendantByName(parentFolder, 'HexIslands')
    local hexIslandFolders = hexIslandFolderBox:getChildren()
    Utils.sortListByObjectKey(hexIslandFolders, 'Name')
    print('hexIslandFolders' .. ' - start')
    print(hexIslandFolders)

    for hexIndex, hexIslandFolder in ipairs(hexIslandFolders) do
        print('hexIndex' .. ' - start')
        print(hexIndex)
        local hexConfig = hexConfigs[hexIndex]
        print('hexConfig' .. ' - start')
        print(hexConfig)
        if hexConfig then
            local statueConfigs = hexConfig.statueConfigs
            if statueConfigs then
                print('statueConfigs' .. ' - start')
                print(statueConfigs)
                local statueGates = Utils.getDescendantsByName(hexIslandFolder, 'StatueGate')

                -- print('statueConfigs' .. ' - start')
                -- print(statueConfigs)
                -- print('hexConfigs' .. ' - start')
                -- print(hexConfigs)
                print('statueGates' .. ' - start')
                print(statueGates)
            end
        end
    end
end

return module
