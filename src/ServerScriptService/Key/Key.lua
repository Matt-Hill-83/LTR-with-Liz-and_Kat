local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local Replicator = require(Sss.Source.BlockDash.Replicator)

local module = {}

function module.initKeys(props)
    local parentFolder = props.parentFolder
    local keyPositioners = Utils.getByTagInParent({parent = parentFolder, tag = 'KeyPositioner'})

    local replicator = Utils.getFromTemplates('LetterKeyReplicatorTemplate')
    local keys = {}
    for _, model in ipairs(keyPositioners) do
        local keyName = model.name
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, 'Dummy')
        if dummy then
            dummy:Destroy()
        end

        local newReplicator = replicator:Clone()
        newReplicator.Name = 'ddd'
        newReplicator.Parent = parentFolder.Parent

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

        local hitBox = newReplicator.PrimaryPart
        hitBox.CFrame =
            Utils3.setCFrameFromDesiredEdgeOffset(
            {
                parent = positioner,
                child = hitBox,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, -1, 0),
                    useChildNearEdge = Vector3.new(0, -1, 0),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            }
        )
        -- hitBox.Anchored = true
        Replicator.initReplicator(newReplicator)
        -- Replicator.initReplicator(newReplicator, afterReplication)
        table.insert(keys, newReplicator)
    end
    return keys
end

return module
