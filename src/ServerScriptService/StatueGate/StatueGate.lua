local Sss = game:GetService('ServerScriptService')
local Statue = require(Sss.Source.Statue.Statue)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initStatueGates(props)
    local hexConfigs = props.configs
    local parentFolder = props.parentFolder

    local hexIslandFolderBox = Utils.getFirstDescendantByName(parentFolder, 'HexIslands')
    local hexIslandFolders = hexIslandFolderBox:getChildren()
    Utils.sortListByObjectKey(hexIslandFolders, 'Name')

    for hexIndex, hexIslandFolder in ipairs(hexIslandFolders) do
        local hexConfig = hexConfigs[hexIndex]
        if hexConfig then
            local statueConfigs = hexConfig.statueConfigs
            if statueConfigs then
                print('hexIndex' .. ' - start')
                print(hexIndex)

                print('statueConfigs' .. ' - start')
                print(statueConfigs)

                local statueGates = Utils.getByTagInParent({parent = hexIslandFolder, tag = 'StatueGate'})
                print('statueGates' .. ' - start')
                print(statueGates)

                for _, gate in ipairs(statueGates) do
                    local statuePositioners = Utils.getByTagInParent({parent = gate, tag = 'StatuePositioner'})
                    print('statuePositioners' .. ' - start')
                    print(statuePositioners)
                    for _, statuePositioner in ipairs(statuePositioners) do
                        print('statuePositioner.Name' .. ' - start')
                        print(statuePositioner.Name)

                        local statueName = statuePositioner.Name

                        local config = statueConfigs[statueName]
                        print('config' .. ' - start')
                        print(config)
                        Statue.initStatue(statuePositioner, config)
                    end
                end
            end
        end
    end
end

return module
