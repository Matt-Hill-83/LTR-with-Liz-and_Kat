local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local Replicator = require(Sss.Source.BlockDash.Replicator)
local AddModelFromPositioner = require(Sss.Source.AddModelFromPositioner.AddModelFromPositioner)
local module = {}

function module.initKeys(props)
    local parentFolder = props.parentFolder
    local keyPositioners = Utils.getByTagInParent({parent = parentFolder, tag = 'KeyPositioner'})

    local keys = {}
    for _, model in ipairs(keyPositioners) do
        local keyName = model.name

        local positioner = model.Positioner

        local cloneProps = {
            parentTo = parentFolder,
            positionToPart = positioner,
            templateName = 'LetterKeyReplicatorTemplate',
            fromTemplate = true,
            modelToClone = nil,
            offsetConfig = {
                useParentNearEdge = Vector3.new(0, -1, 0),
                useChildNearEdge = Vector3.new(0, -1, 0),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        }

        local newReplicator = Utils.cloneModel(cloneProps)

        local keyPart = Utils.getFirstDescendantByName(newReplicator, 'Handle')
        LetterUtils.applyLetterText(
            {
                letterBlock = newReplicator,
                char = keyName
            }
        )

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = keyPart,
                propName = 'KeyName',
                initialValue = keyName,
                propType = 'StringValue'
            }
        )
        Replicator.initReplicator(newReplicator)
        table.insert(keys, newReplicator)
    end
    return keys
end

return module
