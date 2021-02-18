local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local AddModelFromPositioner = require(Sss.Source.AddModelFromPositioner.AddModelFromPositioner)
local Replicator = require(Sss.Source.BlockDash.Replicator)
local module = {}

function module.initKey(props)
    local rewardTemplate = props.rewardTemplate
    local positionerModel = props.positionerModel
    local parentFolder = props.parentFolder

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

    local newReplicatorPart = newReplicator.PrimaryPart

    -- local rewardTemplate = Utils.getFromTemplates('ColorKey')
    -- local rewardTemplate = Utils.getFromTemplates('HexLetterGemTool')
    local rewardFolder = newReplicator.Reward
    local rewards = rewardFolder:getChildren()
    for _, reward in ipairs(rewards) do
        reward:Destroy()
    end
    local newReward = rewardTemplate:Clone()
    newReward.Parent = rewardFolder
    local newRewardPart = newReward.PrimaryPart
    print('newRewardPart' .. ' - start')
    print(newRewardPart)

    -- local freeParts = Utils.freeAnchoredParts({item = newReward})
    -- print('freeParts' .. ' - start')
    -- print(freeParts)

    -- local weld = Instance.new('WeldConstraint')
    -- weld.Name = 'WeldConstraintKey-ppp'
    -- weld.Parent = newRewardPart
    -- weld.Part0 = newRewardPart
    -- weld.Part1 = newReplicatorPart

    newRewardPart.CFrame =
        Utils3.setCFrameFromDesiredEdgeOffset(
        {
            parent = newReplicatorPart,
            child = newRewardPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(1, -1, 1),
                useChildNearEdge = Vector3.new(1, -1, 1)
            }
        }
    )

    -- Utils.anchorFreedParts(freeParts)

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
    local tagName = props.tagName or 'KeyPositioner'
    local keyPositioners = Utils.getByTagInParent({parent = parentFolder, tag = tagName})

    local keys = {}
    for _, positionerModel in ipairs(keyPositioners) do
        local replicatorProps = {
            rewardTemplate = Utils.getFromTemplates('HexLetterGemTool'),
            -- rewardTemplate = Utils.getFromTemplates('ColorKey'),
            positionerModel = positionerModel,
            parentFolder = parentFolder
        }

        local newReplicator = module.initKey(replicatorProps)

        Replicator.initReplicator(newReplicator)
        table.insert(keys, newReplicator)
    end
    return keys
end

return module
