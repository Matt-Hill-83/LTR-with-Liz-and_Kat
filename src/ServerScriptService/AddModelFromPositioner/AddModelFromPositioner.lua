local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

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

        local cloneProps = {
            parentTo = parentFolder,
            positionToPart = positioner,
            templateName = templateName,
            fromTemplate = true,
            modelToClone = nil,
            offsetConfig = offsetConfig
        }

        local newItem = Utils.cloneModel(cloneProps)

        table.insert(newParts, newItem)
    end
    return newParts
end

function module.addModel(props)
    local defaultOffsetConfig = {
        useParentNearEdge = Vector3.new(0, 0, 0),
        useChildNearEdge = Vector3.new(0, 0, 0),
        offsetAdder = Vector3.new(0, 0, 0)
    }

    local parentFolder = props.parentFolder or workspace
    local positionerModel = props.positionerModel
    local templateName = props.templateName
    local offsetConfig = props.offsetConfig or defaultOffsetConfig

    local dummy = Utils.getFirstDescendantByName(positionerModel, 'Dummy')
    if dummy then
        dummy:Destroy()
    end

    local positioner = positionerModel.Positioner

    local cloneProps = {
        parentTo = parentFolder,
        positionToPart = positioner,
        templateName = templateName,
        fromTemplate = true,
        modelToClone = nil,
        offsetConfig = offsetConfig
    }

    local newItem = Utils.cloneModel(cloneProps)
    return newItem
end

return module
