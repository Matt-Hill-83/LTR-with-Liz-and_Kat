local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local AddModelFromPositioner = require(Sss.Source.AddModelFromPositioner.AddModelFromPositioner)
local Replicator = require(Sss.Source.BlockDash.Replicator)
local module = {}

function module.initKey(positionerModel, parentFolder)
    local newReplicator =
        AddModelFromPositioner.addModel(
        {
            parentFolder = parentFolder,
            templateName = 'LetterKeyReplicatorTemplate',
            positionerModel = positionerModel,
            offsetConfig = {
                useParentNearEdge = Vector3.new(0, -1, 0),
                useChildNearEdge = Vector3.new(0, -1, 0),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        }
    )

    local keyPart = Utils.getFirstDescendantByName(newReplicator, 'Handle')
    local keyName = positionerModel.name

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

    local tool = Utils.getFirstDescendantByType(newReplicator, 'Tool')

    if tool then
        tool.Name = keyName
    end
    return newReplicator
end

function module.initKeys(props)
    local parentFolder = props.parentFolder
    local tagName = props.tagName
    local keyPositioners = Utils.getByTagInParent({parent = parentFolder, tag = 'KeyPositioner'})

    local keys = {}
    for _, positionerModel in ipairs(keyPositioners) do
        local newReplicator = module.initKey(positionerModel, parentFolder)

        Replicator.initReplicator(newReplicator)
        table.insert(keys, newReplicator)
    end
    return keys
end

return module
