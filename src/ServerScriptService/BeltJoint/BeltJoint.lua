local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local AddModelFromPositioner = require(Sss.Source.AddModelFromPositioner.AddModelFromPositioner)
local module = {}

function module.initBeltJoint(props)
    local positioner = props.positioner
    local parentFolder = props.parentFolder
    local templateName = props.templateName

    local cloneProps = {
        parentTo = parentFolder,
        positionToPart = positioner,
        templateName = templateName,
        fromTemplate = true,
        modelToClone = nil,
        offsetConfig = {
            useParentNearEdge = Vector3.new(0, 0, 0),
            useChildNearEdge = Vector3.new(0, 0, 0),
            offsetAdder = Vector3.new(0, 0, 0)
        }
    }
    return Utils.cloneModel(cloneProps)
end

function module.initBeltJoints(props)
    local offsetConfig = {
        useParentNearEdge = Vector3.new(0, 0, 0),
        useChildNearEdge = Vector3.new(0, 0, 0),
        offsetAdder = Vector3.new(0, 0, 0)
    }

    AddModelFromPositioner.addModels(
        {
            parentFolder = props.parentFolder,
            templateName = 'BeltJoint-001',
            positionerTag = 'BeltJointPositioner'
            -- offsetConfig = offsetConfig
        }
    )

    -- local parentFolder = props.parentFolder or workspace
    -- local templateName = props.templateName or 'BeltJoint-001'
    -- local positioners = Utils.getByTagInParent({parent = parentFolder, tag = 'BeltJointPositioner'})
    -- local newParts = {}
    -- for _, model in ipairs(positioners) do
    --     local positioner = model.Positioner
    --     local dummy = Utils.getFirstDescendantByName(model, 'Dummy')
    --     if dummy then
    --         dummy:Destroy()
    --     end
    --     local itemProps = {
    --         positioner = positioner,
    --         parentFolder = parentFolder,
    --         templateName = templateName
    --     }
    --     local newItem = module.initBeltJoint(itemProps)
    --     table.insert(newParts, newItem)
    -- end
    -- return newParts
end

return module
