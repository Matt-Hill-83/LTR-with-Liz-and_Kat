local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local Const_Client = require(RS.Source.Constants.Constants_Client)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local module = {}

local function styleGems(items)

    for _, block in ipairs(items) do
        LetterUtils.applyStyleFromTemplate(
            {targetLetterBlock = block, templateName = "Grabber_normal"})
    end

    for _, block in ipairs(items) do
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
        if targetWordObj then
            targetWordObj.found = targetWordObj.found + 1
            updateWordGuiRE:FireAllClients({levelConfig = levelConfig})
        end
    end
    delay(2, destroyParts)

    local keyTemplate = Utils.getFromTemplates("HexLetterGemTool")
    local parent = player.Character.PrimaryPart

    local newKey = keyTemplate:Clone()
    -- This is temporary
    newKey.Parent = parent

    local keyPart = newKey.PrimaryPart
    LetterUtils.applyLetterText({letterBlock = newKey, char = targetWord})

    LetterUtils.LetterUtils.createPropOnLetterBlock(
        {
            letterBlock = keyPart,
            propName = "KeyName",
            initialValue = targetWord,
            propType = "StringValue"
        })
    print('newKey' .. ' - start');
    print(newKey);
    local keyOffset = 30

    newKey:SetPrimaryPartCFrame(CFrame.new(
                                    player.Character.PrimaryPart.CFrame.Position +
                                        (keyOffset *
                                            player.Character.PrimaryPart.CFrame
                                                .LookVector),
                                    player.Character.PrimaryPart.Position))

    newKey.Parent = workspace
    keyPart.Anchored = false
end

local function partTouched(touchedBlock, player)
    print('partTouched' .. ' - start');
    print('partTouched' .. ' - start');
    print('partTouched' .. ' - start');
    print('partTouched' .. ' - start');

    -- local tool = Utils.getActiveTool(player, "LetterGrabber")
    local tool = Utils.getActiveToolByToolType(player, "LetterGemTool")
    if not tool then return end
    print('tool.Name' .. ' - start');
    print('tool.Name' .. ' - start');
    print('tool.Name' .. ' - start');
    print('tool.Name' .. ' - start');
    print('tool.Name' .. ' - start');
    print(tool.Name);

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

            print('destroy');
            print('destroy');
            print('destroy');
            print('destroy');
            print('destroy');
            print('destroy');
            touchedBlock.Parent:Destroy()
        end
    end
end

module.partTouched = partTouched
module.wordFound = wordFound
module.styleGems = styleGems
module.initLetterGem = initLetterGem
return module
