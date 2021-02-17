local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

function module.initBeltJoint(props)
    local positioner = props.positioner
    local parentFolder = props.parentFolder

    local cloneProps = {
        parentTo = parentFolder,
        positionToPart = positioner,
        templateName = 'BeltJoint-001',
        fromTemplate = true,
        modelToClone = nil,
        offsetConfig = {
            useParentNearEdge = Vector3.new(0, 0, 0),
            useChildNearEdge = Vector3.new(0, 0, 0),
            offsetAdder = Vector3.new(0, 0, 0)
        }
    }

    local newItem = Utils.cloneModel(cloneProps)
    -- local template = Utils.getFromTemplates('BeltJoint-001')

    -- local newItem = template:Clone()
    -- newItem.Parent = parentFolder.Parent
    -- local itemPart = newItem.PrimaryPart

    -- itemPart.CFrame =
    --     Utils3.setCFrameFromDesiredEdgeOffset(
    --     {
    --         parent = positioner,
    --         child = itemPart,
    --         offsetConfig = {
    --             useParentNearEdge = Vector3.new(0, -1, 0),
    --             useChildNearEdge = Vector3.new(0, -1, 0),
    --             offsetAdder = Vector3.new(0, 0, 0)
    --         }
    --     }
    -- )

    -- itemPart.Anchored = true
    return newItem
end

function module.initBeltJoints(props)
    local parentFolder = props.parentFolder or workspace

    local positioners = Utils.getByTagInParent({parent = parentFolder, tag = 'BeltJointPositioner'})

    local beltJoints = {}
    for _, model in ipairs(positioners) do
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, 'Dummy')
        if dummy then
            dummy:Destroy()
        end

        local keyName = model.name

        local itemProps = {
            positioner = positioner,
            parentFolder = parentFolder,
            keyName = keyName
        }

        local newItem = module.initBeltJoint(itemProps)

        table.insert(beltJoints, newItem)
    end
    return beltJoints
end

return module
