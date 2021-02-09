-- local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Const_Client = require(RS.Source.Constants.Constants_Client)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function getSortedBlocks(tool2)
    local letterBlocks = Utils.getByTagInParent(
                             {parent = tool2, tag = "WordGrabberLetter"})
    Utils.sortListByObjectKey(letterBlocks, "Name")
    return letterBlocks
end

local function getActiveLetterGrabberBlock(tool)
    local letterBlocks = getSortedBlocks(tool)
    local activeBlock = nil

    for _, block in ipairs(letterBlocks) do
        block.IsActive.Value = false
        --  
    end

    for _, block in ipairs(letterBlocks) do
        if block.IsFound.Value == false then
            activeBlock = block
            block.IsActive.Value = true
            break
        end
    end
    return activeBlock
end

local function setActiveLetterGrabberBlock(tool)
    local letterBlocks = getSortedBlocks(tool)

    for _, block in ipairs(letterBlocks) do
        block.IsActive.Value = false
        --  
    end

    for _, block in ipairs(letterBlocks) do
        if block.IsFound.Value == false then
            block.IsActive.Value = true
            break
        end
    end
end

local function resetBlocks(tool)
    local letterBlocks = getSortedBlocks(tool)

    for _, block in ipairs(letterBlocks) do
        block.IsActive.Value = false
        block.IsFound.Value = false
    end
end

local function styleLetterGrabberBlocks(tool)
    local letterBlocks = getSortedBlocks(tool)

    for _, block in ipairs(letterBlocks) do
        LetterUtils.applyStyleFromTemplate(
            {targetLetterBlock = block, templateName = "Grabber_normal"})
    end

    for _, block in ipairs(letterBlocks) do
        if block.IsFound.Value == true then
            LetterUtils.applyStyleFromTemplate(
                {targetLetterBlock = block, templateName = "Grabber_found"})
        end

    end
end

local function wordFound(tool, player)
    local updateWordGuiRE = RS:WaitForChild(
                                Const_Client.RemoteEvents.UpdateWordGuiRE)

    local wordModel = tool.Word
    local targetWord = wordModel.TargetWord.Value

    local function destroyParts()
        -- local explosionSound = '515938718'
        -- Utils.playSound(explosionSound, 0.5)
        module.resetBlocks(tool)
        module.setActiveLetterGrabberBlock(tool)
        module.styleLetterGrabberBlocks(tool)

        local gameState = PlayerStatManager.getGameState(player)
        local levelConfig = gameState.levelConfig
        local targetWordObj = Utils.getListItemByPropValue(
                                  levelConfig.targetWords, "word", targetWord)

        local fireSound = '5207654419'
        local currentWord2 = Const4.wordConfigs[targetWord]
        if currentWord2 then
            local soundId = currentWord2.soundId or fireSound
            Utils.playSound(soundId)
        end

        targetWordObj.found = targetWordObj.found + 1
        updateWordGuiRE:FireAllClients({levelConfig = levelConfig})
    end
    delay(1, destroyParts)

    local keyTemplate = Utils.getFromTemplates("HexLetterGemTool")
    local parent = player.Character.PrimaryPart

    local newKey = keyTemplate:Clone()
    -- This is temporary
    newKey.Parent = parent

    local keyPart = newKey.PrimaryPart
    LetterUtils.applyLetterText({letterBlock = newKey, char = targetWord})

    LetterUtils.createPropOnLetterBlock({
        letterBlock = keyPart,
        propName = "KeyName",
        initialValue = targetWord,
        propType = "StringValue"
    })
    print('newKey' .. ' - start');
    print(newKey);
    newKey.Name = "ttt"

    newKey:SetPrimaryPartCFrame(CFrame.new(
                                    player.Character.PrimaryPart.CFrame.Position +
                                        (20 *
                                            player.Character.PrimaryPart.CFrame
                                                .LookVector),
                                    player.Character.PrimaryPart.Position))

    newKey.Parent = workspace
    keyPart.Anchored = false
end

local function partTouched(touchedBlock, player)
    local tool = Utils.getActiveTool(player, "LetterGrabber")
    if not tool then return end

    local activeBlock = module.getActiveLetterGrabberBlock(tool)
    if activeBlock then
        local strayLetterChar = touchedBlock.Character.Value
        local activeLetterChar = activeBlock.Character.Value

        if strayLetterChar == activeLetterChar then
            activeBlock.IsFound.Value = true
            activeBlock.IsActive.Value = false

            module.styleLetterGrabberBlocks(tool)

            local newActiveBlock = module.getActiveLetterGrabberBlock(tool)
            if not newActiveBlock then wordFound(tool, player) end

            touchedBlock.Parent:Destroy()
        end
    end
end

module.getActiveLetterGrabberBlock = getActiveLetterGrabberBlock
module.partTouched = partTouched
module.resetBlocks = resetBlocks
module.setActiveLetterGrabberBlock = setActiveLetterGrabberBlock
module.styleLetterGrabberBlocks = styleLetterGrabberBlocks
module.wordFound = wordFound
return module
