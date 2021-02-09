local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function openDoor(door, key, player)
    print('openDoor' .. ' - start');
    print('openDoor' .. ' - start');
    print('openDoor' .. ' - start');
    print('openDoor' .. ' - start');
    print('openDoor' .. ' - start');
    print(openDoor);
    key:Destroy()

    local doorPart = door.PrimaryPart
    local hiddenParts = Utils.hideItemAndChildren2({item = door, hide = true})

    -- doorPart.Transparency = 0.8
    doorPart.CanCollide = false
    wait(5)
    Utils.unhideHideItems({items = hiddenParts})
    -- doorPart.Transparency = 0
    doorPart.CanCollide = true
end

local function onTouch(door)

    print('door' .. ' - start');
    print(door);
    print(door.KeyName);
    local db = {value = false}

    local function closure(key)
        print('key' .. ' - start');
        print(key);
        print('key.Parent' .. ' - start');
        print(key.Parent);
        local humanoid = key.Parent.Parent:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
        print('humanoid' .. ' - start');
        print('humanoid' .. ' - start');
        print('humanoid' .. ' - start');
        print('humanoid' .. ' - start');
        print(humanoid);
        if not key:FindFirstChild("KeyName") then return end
        if key.KeyName.Value ~= door.KeyName.Value then return end
        -- if key.Name ~= "Tool" then return end
        -- if key.Name ~= door.KeyName.Value then return end
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
    print('doorTemplate' .. ' - start');
    print(doorTemplate);

    local doors = {}
    for _, model in ipairs(doorPositioners) do
        local keyName = model.name
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, "Dummy")
        if dummy then dummy:Destroy() end

        local newDoor = doorTemplate:Clone()
        newDoor.Parent = parentFolder.Parent
        local doorPart = newDoor.PrimaryPart
        doorPart.Name = "ggg"

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
        doorPart.Anchored = true

        table.insert(doors, newDoor)
    end
    return doors
end

function module.initKeys(props)
    local parentFolder = props.parentFolder

    local keyPositioners = Utils.getByTagInParent(
                               {parent = parentFolder, tag = "KeyPositioner"})

    print('keyPositioners' .. ' - start');
    print(keyPositioners);
    local keyTemplate = Utils.getFromTemplates("HexLetterGemTool")
    print('keyTemplate' .. ' - start');
    print(keyTemplate);

    local doors = {}
    for _, model in ipairs(keyPositioners) do
        local keyName = model.name
        local positioner = model.Positioner

        local dummy = Utils.getFirstDescendantByName(model, "Dummy")
        if dummy then dummy:Destroy() end

        local newKey = keyTemplate:Clone()
        newKey.Parent = parentFolder.Parent
        local keyPart = newKey.PrimaryPart
        -- keyPart.Name = "jjj"

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = keyPart,
                propName = "KeyName",
                initialValue = keyName,
                propType = "StringValue"
            })

        keyPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                             {
                parent = positioner,
                child = keyPart,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, -1, 0),
                    useChildNearEdge = Vector3.new(0, -1, 0),
                    offsetAdder = Vector3.new(0, 0, 0)
                }
            })

        -- doorPart.Touched:Connect(onTouch(newKey))
        -- doorPart.Anchored = true

        table.insert(doors, newKey)
    end
    return doors
end

return module

