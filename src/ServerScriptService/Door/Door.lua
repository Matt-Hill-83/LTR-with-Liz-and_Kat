local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local Replicator = require(Sss.Source.BlockDash.Replicator)

local module = {}

local function openDoor(door, key)
    -- key:Destroy()

    local doorPart = door.PrimaryPart
    local hiddenParts = Utils.hideItemAndChildren2({item = door, hide = true})
    doorPart.CanCollide = false
    wait(5)
    Utils.unhideHideItems({items = hiddenParts})
    doorPart.CanCollide = true
end

local function onTouch(door)
    local db = {value = false}

    local function closure(key)
        local humanoid = key.Parent.Parent:FindFirstChildWhichIsA('Humanoid')
        if not humanoid then
            return
        end
        if not key:FindFirstChild('KeyName') then
            return
        end
        if key.KeyName.Value ~= door.KeyName.Value then
            return
        end
        if db.value == true then
            return
        end

        db.value = true
        local player = Utils.getPlayerFromHumanoid(humanoid)
        openDoor(door, key, player)
        db.value = false
    end
    return closure
end

function module.initDoor(props)
    local positioner = props.positioner
    local parentFolder = props.parentFolder
    local keyName = props.keyName
    local doorWidth = props.doorWidth or 8
    local width = props.width or 32
    local noGem = props.noGem

    local doorTemplate = Utils.getFromTemplates('GemLetterDoor')

    local newDoor = doorTemplate:Clone()
    newDoor.Parent = parentFolder.Parent
    local doorPart = newDoor.PrimaryPart

    local walls = Utils.getDescendantsByName(newDoor, 'Wall')

    local wallWidthX = (width - doorWidth) / 2

    for wallIndex, wall in ipairs(walls) do
        wall.Size = Vector3.new(wallWidthX, wall.Size.Y, wall.Size.Z)

        local adder = (doorPart.Size.X + wall.Size.X) / 2
        local offsetX
        if wallIndex == 1 then
            offsetX = doorPart.Position.X + adder
        else
            offsetX = doorPart.Position.X - adder
        end
        wall.Position = Vector3.new(offsetX, wall.Position.Y, wall.Position.Z)
        wall.CanCollide = true
    end

    if noGem then
        newDoor.HexLetterGemTool:Destroy()
    else
        LetterUtils.applyLetterText({letterBlock = newDoor, char = keyName})

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newDoor,
                propName = 'KeyName',
                initialValue = keyName,
                propType = 'StringValue'
            }
        )

        doorPart.Touched:Connect(onTouch(newDoor))
    end

    doorPart.CFrame =
        Utils3.setCFrameFromDesiredEdgeOffset(
        {
            parent = positioner,
            child = doorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(0, -1, 0),
                useChildNearEdge = Vector3.new(0, -1, 0),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        }
    )

    doorPart.Anchored = true
    return newDoor
end

function module.initDoors(props)
    local parentFolder = props.parentFolder

    local doorPositioners = Utils.getByTagInParent({parent = parentFolder, tag = 'DoorPositioner'})

    local doors = {}
    for _, model in ipairs(doorPositioners) do
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, 'Dummy')
        if dummy then
            dummy:Destroy()
        end

        local keyName = model.name

        local doorProps = {
            positioner = positioner,
            parentFolder = parentFolder,
            keyName = keyName
        }

        local newDoor = module.initDoor(doorProps)

        table.insert(doors, newDoor)
    end
    return doors
end

return module
