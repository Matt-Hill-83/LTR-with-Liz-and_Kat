local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Const4 = require(Sss.Source.Constants.Const_04_Characters)
local module = {}

local getInstancesByNameStub = function(props)
    local nameStub = props.nameStub
    local parent = props.parent
    local children = parent:GetDescendants()

    local output = {}
    for _, item in pairs(children) do
        local match = string.match(item.Name, nameStub)

        if match then
            table.insert(output, item)
            --
        end
    end
    return output
end

function getUuid() return HttpService:GenerateGUID(false) end

local function destroyTools(player, toolNameStub)
    local children2 = player.Character:GetChildren()
    for _, child in ipairs(children2) do
        local pattern = toolNameStub
        local found = string.match(child.Name, pattern)
        if found and child:IsA("Tool") then child:Destroy() end
    end

    local children = player.Backpack:GetChildren()
    for _, child in ipairs(children) do
        local pattern = toolNameStub
        local found = string.match(child.Name, pattern)
        if found and child:IsA("Tool") then child:Destroy() end
    end
end

local function getActiveTool(player, toolNameStub)
    local children2 = player.Character:GetChildren()
    for _, child in ipairs(children2) do
        local pattern = toolNameStub
        local found = string.match(child.Name, pattern)
        if found and child:IsA("Tool") then return child end
    end
    return false
end

local function listIncludes(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
            -- 
        end
    end

    return false
end

local function playSound(soundId, emitterSize)
    if (soundId) then
        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://" .. soundId
        sound.EmitterSize = emitterSize or 5
        sound.Looped = false
        if not sound.IsPlaying then sound:Play() end
    end
end

local function getItemByUuid(items, uuid)
    for _, item in ipairs(items) do
        if item.Uuid == uuid then
            return item
            -- 
        end
    end
    return nil
end

local function removeListItemByUuid(items, uuid)
    for index, item in ipairs(items) do
        if item.uuid == uuid then

            print('removing');
            table.remove(items, index)
            -- 
        end
        -- if item.Uuid ~= uuid then table.insert(newList, item) end
    end
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function sortListByObjectKey(list, keyName)
    table.sort(list, function(left, right)
        return left[keyName] < right[keyName]
        -- 
    end)
end

function applyDecalsToCharacterFromWord(props)
    local part = props.part
    local word = props.word

    local found = false

    if Const4.wordConfigs[word] then
        local imageId = Const4.wordConfigs[word]['imageId']
        if imageId then
            local decalUri = 'rbxassetid://' .. imageId
            local decalFront = getFirstDescendantByName(part,
                                                        "CharacterDecalFront")
            local decalBack = getFirstDescendantByName(part,
                                                       "CharacterDecalBack")
            decalFront.Image = decalUri
            decalBack.Image = decalUri
            found = true
        end
    end
    return found
end

function applyLabelsToCharacter(props)
    local part = props.part
    local text = props.text or "no label"

    local charLabelFront = module.getFirstDescendantByName(part,
                                                           "CharLabelFront")
    local charLabelBack = module.getFirstDescendantByName(part, "CharLabelBack")
    charLabelFront.Text = text
    charLabelBack.Text = text
end

function applyDecalsToCharacterFromConfigName(props)
    local part = props.part
    local configName = props.configName

    local imageId = module.getDecalIdFromName({name = configName})

    if imageId then
        local decalUri = 'rbxassetid://' .. imageId
        local decalFront = getFirstDescendantByName(part, "CharacterDecalFront")
        local decalBack = getFirstDescendantByName(part, "CharacterDecalBack")
        decalFront.Image = decalUri
        decalBack.Image = decalUri
    end

    local displayName = module.getDisplayNameFromName({name = configName})
    applyLabelsToCharacter({part = part, text = displayName})

end

local function getPlayerFromHumanoid(humanoid)
    local character = humanoid.Parent
    local player = Players:GetPlayerFromCharacter(character)
    return player
end

local function getKeysFromDict(dict)
    local keyset = {}
    for k, v in pairs(dict) do
        keyset[#keyset + 1] = k
        -- 
    end
    return keyset
end

local function removeFirstMatchFromArray(array, value)
    for i = #array, 1, -1 do
        if array[i] == value then
            table.remove(array, i)
            break
        end
    end
end

function enableChildWelds(props)
    local part = props.part
    local enabled = props.enabled

    local allWelds = module.getDescendantsByType(part, "Weld")
    for i, weld in ipairs(allWelds) do
        weld.Enabled = enabled
        -- 
    end
    local allWelds2 = module.getDescendantsByType(part, "WeldConstraint")
    for i, weld in ipairs(allWelds2) do
        weld.Enabled = enabled
        -- 
    end
end

local function disableEnabledWelds(part)
    local welds = {}

    local allWelds = module.getDescendantsByType(part, "Weld")
    for _, weld in ipairs(allWelds) do
        if weld.Enabled then
            weld.Enabled = false
            table.insert(welds, weld)
        end
    end
    local allWelds2 = module.getDescendantsByType(part, "WeldConstraint")
    for _, weld in ipairs(allWelds2) do
        if weld.Enabled then
            weld.Enabled = false
            table.insert(welds, weld)
        end
    end
    return welds
end

function genRandom(min, max)
    local rand = min + math.random() * (max - min + 1)
    return math.floor(rand)
end

function module.clearTable(tbl) for key in pairs(tbl) do tbl[key] = nil end end

function module.setPropsByTag(props)
    local tag = props.tag
    local theProps = props.props

    local items = CS:GetTagged(tag)
    for i, item in ipairs(items) do
        mergeTables(item, theProps)
        -- 
    end
end

function module.getByTagInParent(props)
    local tag = props.tag
    local parent = props.parent
    local items = CS:GetTagged(tag)

    local output = {}
    for i, item in ipairs(items) do
        if item:IsDescendantOf(parent) then
            table.insert(output, item)
            -- 
        end
    end
    return output
end

function getFirstDescendantByName(parent, name)
    local model = parent:GetDescendants()
    for i = 1, #model do
        if model[i].Name == name then
            return model[i]
            -- 
        end
    end
end

function getDescendantsByName(parent, name)
    local items = parent:GetDescendants()

    local output = {}
    for i, item in ipairs(items) do
        if item.Name == name then
            table.insert(output, item)
            -- 
        end
    end
    return output
end

function module.getDescendantsByType(parent, type)
    local items = parent:GetDescendants()
    local output = {}

    for i, item in pairs(items) do
        if item:IsA(type) then
            table.insert(output, item)
            -- 
        end
    end
    return output
end

function hideItem(part, hide)
    local transparency = hide and 1 or 0
    local visible = not hide
    local enabled = not hide

    if part:IsA("BasePart") then part.Transparency = transparency end
    if part:IsA("Decal") then part.Transparency = transparency end

    if part:IsA("ScrollingFrame") then part.Visible = visible end
    if part:IsA("TextLabel") then part.Visible = visible end
    if part:IsA("TextButton") then part.Visible = visible end

    if part:IsA("SurfaceGui") then part.Enabled = enabled end
end

function setChildrenProps(parent, props)
    if parent:IsA("BasePart") then mergeTables(parent, props) end

    local children = parent:GetDescendants()
    for i, item in ipairs(children) do
        if item:IsA("BasePart") then mergeTables(item, props) end
    end
end

function hideItemAndChildren(props)
    local parent = props.item
    local hide = props.hide

    hideItem(parent, hide)
    local children = parent:GetDescendants()
    for i, item in ipairs(children) do hideItem(item, hide) end
end

function sizeWalls(props)
    local parent = props.item
    local height = props.height

    local children = parent:GetDescendants()
    for i, item in ipairs(children) do
        if item:isA("Part") then item.CanCollide = false end
    end
    for i, item in ipairs(children) do
        if item:isA("Part") then
            local posY = item.Position.Y - item.Size.Y / 2
            local newPosY = posY + (height / 2)
            item.Size = Vector3.new(item.Size.X, height, item.Size.Z)
            item.Position = Vector3.new(item.Position.X, newPosY,
                                        item.Position.Z)

        end
    end
    for i, item in ipairs(children) do
        if item:isA("Part") then
            item.CanCollide = true
            item.Anchored = true
        end
    end
end

function setItemHeight(props)
    local item = props.item
    local height = props.height

    if item:isA("Part") then
        local posY = item.Position.Y - item.Size.Y / 2
        local newPosY = posY + (height / 2)
        item.Size = Vector3.new(item.Size.X, height, item.Size.Z)
        item.Position = Vector3.new(item.Position.X, newPosY, item.Position.Z)
    end
end

function sizeWalls2(props)
    local items = props.items
    local height = props.height

    for i, item in ipairs(items) do
        if item:isA("Part") then item.CanCollide = false end
    end

    for i, item in ipairs(items) do
        if item:isA("Part") then
            local posY = item.Position.Y - item.Size.Y / 2
            local newPosY = posY + (height / 2)
            item.Size = Vector3.new(item.Size.X, height, item.Size.Z)
            item.Position = Vector3.new(item.Position.X, newPosY,
                                        item.Position.Z)

        end
    end

    for i, item in ipairs(items) do
        if item:isA("Part") then
            item.CanCollide = true
            item.Anchored = true
        end
    end
end

function module.hideItemAndChildrenByName(props)
    local name = props.name
    local hide = props.hide

    local myStuff = workspace:FindFirstChild("MyStuff")
    local item = getFirstDescendantByName(myStuff, name)
    hideItemAndChildren({item = item, hide = hide})
end

function module.setWallHeightByList(props)
    local items = props.items
    local height = props.height

    sizeWalls2({items = items, height = height})

end

function module.setWallHeightbyParentModelName(props)
    local name = props.name
    local height = props.height

    local myStuff = workspace:FindFirstChild("MyStuff")
    local items = getDescendantsByName(myStuff, name)

    for i, item in ipairs(items) do
        sizeWalls({item = item, height = height})
        -- 
    end
end

function module.setItemAndChildrenPropsByName(myProps)
    local name = myProps.name
    local props = myProps.props

    local myStuff = workspace:FindFirstChild("MyStuff")
    local item = getFirstDescendantByName(myStuff, name)
    setChildrenProps(item, props)
end

function module.setItemAndChildrenPropsByInst(myProps)
    local item = myProps.item
    local props = myProps.props

    setChildrenProps(item, props)
end

function module.setItemPropsByInst(myProps)
    local item = myProps.item
    local props = myProps.props
end

function module.getOrCreateFolder(props)
    local name = props.name
    local parent = props.parent

    local runtimeQuestsFolder = getFirstDescendantByName(parent, name)

    if not runtimeQuestsFolder then
        runtimeQuestsFolder = Instance.new("Folder", parent)
        runtimeQuestsFolder.Name = name
        runtimeQuestsFolder = getFirstDescendantByName(parent, name)
    end

    return runtimeQuestsFolder
end

function module.reportPlayerLocation()
    -- local Players = game:GetService("Players")
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            while humanoidRootPart do
                local test2 = workspace.CurrentCamera.CFrame.Position
                print(test2);
                print(player.Name, "is at", tostring(humanoidRootPart.Position))
                wait(4)
            end
        end)
    end)
end

function module.getDecalIdFromName(props)
    local name = props.name
    if (Const4.characters[name] and Const4.characters[name]["decalId"]) then
        return Const4.characters[name]["decalId"]
    else

        if (name ~= "blank" and name ~= "empty" and name ~= "") then
            -- print("----------------- decalId not found: ------------" .. name)
        end
        return '5999465084'
    end
end

function module.getDisplayNameFromName(props)
    local name = props.name
    if (Const4.characters[name] and Const4.characters[name]["displayName"]) then
        return Const4.characters[name]["displayName"]
    else
        -- print("---------------------- name not found: ------------" .. name)
        -- print('Const4.characters[name]' .. ' - start');
        -- print(Const4.characters[name]);
        return name
    end
end

function module.deleteChildrenByName(props)
    local parent = props.parent
    local childName = props.childName
    local children = parent:GetDescendants()
    for i, item in pairs(children) do
        if item.Name == childName then
            item:Destroy()
            --
        end
    end
end

function getFromMyStuff(name)
    local myStuff = workspace:FindFirstChild("MyStuff")
    return getFirstDescendantByName(myStuff, name)
end

function module.getFromTemplates(name)
    local myStuff = workspace:FindFirstChild("MyStuff")
    local myTemplates = myStuff:FindFirstChild("MyTemplates")
    return getFirstDescendantByName(myTemplates, name)
end

function module.unAttachAllChildParts(parent)
    local items = parent:GetDescendants()
    local output = {}
    for i = 1, #items do
        if items[i]:IsA('Part') then
            local item = items[i]
            if item.Anchored == true then table.insert(output, item) end
            --
        end

    end
    return output
end

function module.getDescendantsByNameMatch(parent, name)
    local descendants = parent:GetDescendants()
    local output = {}
    for i = 1, #descendants do
        local child = descendants[i]
        local match = string.match(child.Name, name)
        if match then table.insert(output, child) end
    end
    return output
end

function addcfv3(a, b)
    local x, y, z, m11, m12, m13, m21, m22, m23, m31, m32, m33 = a:components()
    return CFrame.new(x + b.x, y + b.y, z + b.z, m11, m12, m13, m21, m22, m23,
                      m31, m32, m33);
end

function cloneModel(props)
    local model = props.model
    local position = props.position
    local suffix = props.suffix

    local modelClone = model:Clone()
    modelClone.Parent = model.Parent
    modelClone.Name = model.Name .. (suffix or "-Clone")
    if (position) then
        modelClone:SetPrimaryPartCFrame(position)
        -- 
    end
    return modelClone
end

local function getNames(tab, name, res, lev)
    res = res or {[tab] = "ROOT"}
    local pls = {}
    lev = lev or 0
    for k, v in pairs(tab) do
        if type(v) == "table" and not res[v] then
            local n = name .. "." .. tostring(k)
            res[v] = n
            pls[v] = n
        end
    end
    for k, v in pairs(pls) do
        getNames(k, v, res)
        pls[k] = lev
    end
    return res, pls
end

function tableToString(tab, a, b, c, d)
    a, b = a or 0, b or {[tab] = true}
    local name = b[tab]
    local white = ("\t"):rep(a + 1)
    if not c then c, d = getNames(tab, "ROOT") end
    local res = {"{"}
    for k, v in pairs(tab) do
        local value
        if type(v) == "table" then
            if d[v] == a and not b[v] then
                b[v] = true
                value = tableToString(v, a + 1, b, c, d)
            else
                value = c[v]
            end
        elseif type(v) == "string" then
            value = '"' .. v:gsub("\n", "\\n"):gsub("\t", "\\t") .. '"'
        else
            value = tostring(v)
        end
        table.insert(res, white .. tostring(k) .. " = " .. value)
    end
    white = white:sub(2)
    table.insert(res, white .. "}")
    return table.concat(res, "\n")
end

function mergeTables(t1, t2) for k, v in pairs(t2) do t1[k] = v end end

local function addPadding(props)
    local parent = props.parent
    local padding = props.padding
    local inPx = props.inPx

    local uIPadding = Instance.new("UIPadding", parent)

    if inPx then
        uIPadding.PaddingBottom = UDim.new(0, padding)
        uIPadding.PaddingTop = UDim.new(0, padding)
        uIPadding.PaddingLeft = UDim.new(0, padding)
        uIPadding.PaddingRight = UDim.new(0, padding)
    else
        uIPadding.PaddingBottom = UDim.new(padding, 0)
        uIPadding.PaddingTop = UDim.new(padding, 0)
        uIPadding.PaddingLeft = UDim.new(padding, 0)
        uIPadding.PaddingRight = UDim.new(padding, 0)
    end
end

module.addcfv3 = addcfv3
module.addPadding = addPadding
module.cloneModel = cloneModel
module.enableChildWelds = enableChildWelds
module.genRandom = genRandom
module.getDescendantsByName = getDescendantsByName
module.getFirstDescendantByName = getFirstDescendantByName
module.getFromMyStuff = getFromMyStuff
module.getInstancesByNameStub = getInstancesByNameStub
module.getItemByUuid = getItemByUuid
module.getKeysFromDict = getKeysFromDict
module.getPlayerFromHumanoid = getPlayerFromHumanoid
module.getUuid = getUuid
module.hideItem = hideItem
module.disableEnabledWelds = disableEnabledWelds
module.hideItemAndChildren = hideItemAndChildren
module.listIncludes = listIncludes
module.mergeTables = mergeTables
module.playSound = playSound
module.removeFirstMatchFromArray = removeFirstMatchFromArray
module.removeListItemByUuid = removeListItemByUuid
module.setItemHeight = setItemHeight
module.destroyTools = destroyTools
module.sortListByObjectKey = sortListByObjectKey
module.tablelength = tablelength
module.tableToString = tableToString
module.getActiveTool = getActiveTool
module.applyDecalsToCharacterFromWord = applyDecalsToCharacterFromWord
module.applyDecalsToCharacterFromConfigName =
    applyDecalsToCharacterFromConfigName

return module
