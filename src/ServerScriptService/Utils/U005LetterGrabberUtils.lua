-- local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
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

        -- if block.IsActive.Value == true then
        --     LetterUtils.applyStyleFromTemplate(
        --         {targetLetterBlock = block, templateName = "Grabber_active"})
        -- end
    end
end

local function wordFound(tool, player)
    local updateWordGuiRE = RS:WaitForChild(
                                Const_Client.RemoteEvents.UpdateWordGuiRE)

    local function destroyParts()
        -- local explosionSound = '515938718'
        -- Utils.playSound(explosionSound, 0.5)
        module.resetBlocks(tool)
        module.setActiveLetterGrabberBlock(tool)
        module.styleLetterGrabberBlocks(tool)

        local wordModel = tool.Word
        local targetWord = wordModel.TargetWord.Value

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
end

local function blockTouchedByHuman(newLetterBlock2, player)
    local tool = Utils.getActiveTool(player, "LetterGrabber")
    if not tool then return end

    local activeBlock = module.getActiveLetterGrabberBlock(tool)
    if activeBlock then
        local strayLetterChar = newLetterBlock2.Character.Value
        local activeLetterChar = activeBlock.Character.Value

        if strayLetterChar == activeLetterChar then
            activeBlock.IsFound.Value = true
            activeBlock.IsActive.Value = false
        end

        module.styleLetterGrabberBlocks(tool)

        local newActiveBlock = module.getActiveLetterGrabberBlock(tool)
        if not newActiveBlock then wordFound(tool, player) end
    end
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
        end

        module.styleLetterGrabberBlocks(tool)

        local newActiveBlock = module.getActiveLetterGrabberBlock(tool)
        if not newActiveBlock then wordFound(tool, player) end
    end
end

module.wordFound = wordFound
module.blockTouchedByHuman = blockTouchedByHuman
module.setActiveLetterGrabberBlock = setActiveLetterGrabberBlock
module.getActiveLetterGrabberBlock = getActiveLetterGrabberBlock
module.styleLetterGrabberBlocks = styleLetterGrabberBlocks
module.partTouched = partTouched
module.resetBlocks = resetBlocks
return module
