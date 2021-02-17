local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.addModel(props)
    local positioner = props.positioner
    local parentFolder = props.parentFolder
    local templateName = props.templateName
    local offsetConfig = props.offsetConfig

    local cloneProps = {
        parentTo = parentFolder,
        positionToPart = positioner,
        templateName = templateName,
        fromTemplate = true,
        modelToClone = nil,
        offsetConfig = offsetConfig
    }
    return Utils.cloneModel(cloneProps)
end

function module.addModels(props)
    local defaultOffsetConfig = {
        useParentNearEdge = Vector3.new(0, 0, 0),
        useChildNearEdge = Vector3.new(0, 0, 0),
        offsetAdder = Vector3.new(0, 0, 0)
    }

    local parentFolder = props.parentFolder or workspace
    local templateName = props.templateName
    local positionerTag = props.positionerTag
    local offsetConfig = props.offsetConfig or defaultOffsetConfig

    local positioners = Utils.getByTagInParent({parent = parentFolder, tag = positionerTag})

    local newParts = {}
    for _, model in ipairs(positioners) do
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, 'Dummy')
        if dummy then
            dummy:Destroy()
        end

        local itemProps = {
            positioner = positioner,
            parentFolder = parentFolder,
            templateName = templateName,
            offsetConfig = offsetConfig
        }

        local newItem = module.addModel(itemProps)

        table.insert(newParts, newItem)
    end
    return newParts
end

return module
