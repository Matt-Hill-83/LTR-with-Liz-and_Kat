local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function openDoor(door, key, player)
    key:Destroy()
    door.Transparency = 0.8
    door.CanCollide = false
    wait(3)
    door.Transparency = 0
    door.CanCollide = true
end

local function onTouch(door)
    local db = {value = false}

    local function closure(key)
        print('key' .. ' - start');
        print(key);
        print('key.Parent' .. ' - start');
        print(key.Parent);
        local humanoid = key.Parent:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
        if not key:FindFirstChild("KeyName") then return end
        if key.KeyName.Value ~= door.KeyName.Value then return end
        if db.value == true then return end

        db.value = true
        local player = Utils.getPlayerFromHumanoid(humanoid)
        openDoor(door, key, player)
        db.value = false
    end
    return closure
end

function module.initDoors(props)
    local parentFolder = props.parentFolder

    local doorPositioners = Utils.getByTagInParent(
                                {parent = parentFolder, tag = "DoorPositioner"})

    print('doorPositioners' .. ' - start');
    print(doorPositioners);
    local doorTemplate = Utils.getFromTemplates("GemLetterDoor")

    local doors = {}
    for _, model in ipairs(doorPositioners) do
        local keyName = model.name
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, "Dummy")
        if dummy then dummy:Destroy() end

        local newDoor = doorTemplate:Clone()
        newDoor.Parent = parentFolder.Parent
        local doorPart = newDoor.PrimaryPart
        doorPart.Anchored = true

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newDoor,
                propName = "KeyName",
                initialValue = keyName,
                propType = "StringValue"
            })

        doorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                              {
                parent = positioner,
                child = doorPart,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, -1, 0),
                    useChildNearEdge = Vector3.new(0, -1, 0),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            })

        doorPart.Touched:Connect(onTouch(newDoor))

        table.insert(doors, newDoor)
    end
    return doors
end

return module

