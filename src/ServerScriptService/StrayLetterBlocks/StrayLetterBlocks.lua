local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Const_Client = require(RS.Source.Constants.Constants_Client)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Utils5 = require(Sss.Source.Utils.U005LetterGrabberUtils)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local module = {}

local function wordFound(tool, player)
    local updateWordGuiRE = RS:WaitForChild(
                                Const_Client.RemoteEvents.UpdateWordGuiRE)

    local function destroyParts()
        -- local explosionSound = '515938718'
        -- Utils.playSound(explosionSound, 0.5)
        Utils5.resetBlocks(tool)
        Utils5.setActiveLetterGrabberBlock(tool)
        Utils5.styleLetterGrabberBlocks(tool)

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

    if tool then
        local activeBlock = Utils5.getActiveLetterGrabberBlock(tool)
        if activeBlock then
            local strayLetterChar = newLetterBlock2.Character.Value
            local activeLetterChar = activeBlock.Character.Value

            if strayLetterChar == activeLetterChar then
                activeBlock.IsFound.Value = true
                activeBlock.IsActive.Value = false
            end

            Utils5.styleLetterGrabberBlocks(tool)

            local newActiveBlock = Utils5.getActiveLetterGrabberBlock(tool)
            if not newActiveBlock then wordFound(tool, player) end
        end
    end

end

local function onTouchBlock(newLetterBlock2)
    local db = {value = false}
    local function closure(otherPart)
        if not otherPart.Parent then return end
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end

        if not db.value then
            db.value = true
            local player = Utils.getPlayerFromHumanoid(humanoid)
            blockTouchedByHuman(newLetterBlock2, player)
            db.value = false
        end
    end
    return closure
end

local function createStray(char, parentFolder, blockSize)
    blockSize = blockSize or 6

    local letterBlockTemplate = Utils.getFromTemplates("HexLetterGemTemplate")
    -- local letterBlockTemplate = Utils.getFirstDescendantByName(
    --                                 letterBlockFolder, "LB_4_blank")
    -- local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    -- local letterBlockTemplate = Utils.getFirstDescendantByName(
    --                                 letterBlockFolder, "LB_4_blank")

    local modelClone = letterBlockTemplate:Clone()
    local newLetterBlock = modelClone.PrimaryPart

    -- newLetterBlock.Size = Vector3.new(blockSize, blockSize, blockSize)

    local letterId = "ID--R"

    local name = "strayLetter-ppp" .. char .. "-" .. letterId
    newLetterBlock.Name = name

    LetterUtils.createPropOnLetterBlock({
        letterBlock = newLetterBlock,
        propName = LetterUtils.letterBlockPropNames.IsLifted,
        initialValue = false,
        propType = "BoolValue"
    })

    LetterUtils.createPropOnLetterBlock({
        letterBlock = newLetterBlock,
        propName = LetterUtils.letterBlockPropNames.IsFound,
        initialValue = false,
        propType = "BoolValue"
    })

    modelClone.Parent = parentFolder
    newLetterBlock.Anchored = false

    LetterUtils.initLetterBlock({
        letterBlock = newLetterBlock,
        char = char,
        templateName = "Stray_normal",
        isTextLetter = true,
        letterBlockType = "StrayLetter"
    })

    newLetterBlock.Touched:Connect(onTouchBlock(newLetterBlock))
    return newLetterBlock
end

local function initStrays(props)
    local numBlocks = props.numBlocks
    local region = props.region
    local words = props.words

    -- populate matrix with letters
    local letterMatrix = {}
    local lettersNotInWords = LetterUtils.getLettersNotInWords(words)
    local totalRows = numBlocks

    for _ = 1, totalRows do
        table.insert(letterMatrix,
                     LetterUtils.getRandomLetter(lettersNotInWords))
    end

    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)
            table.insert(letterMatrix, letter)
        end
    end

    local strays = {}
    for _, char in ipairs(letterMatrix) do
        local parentFolder = props.parentFolder
        local newLetterBlock = createStray(char, parentFolder)

        local offsetX = Utils.genRandom(0, region.Size.X) - region.Size.X / 2
        local offsetZ = Utils.genRandom(0, region.Size.Z) - region.Size.Z / 2

        -- local offsetX = Utils.genRandom(0, 20)
        -- local offsetZ = Utils.genRandom(0, 20)
        table.insert(strays, newLetterBlock)
        newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                    {
                parent = region,
                child = newLetterBlock,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, -1, 0),
                    useChildNearEdge = Vector3.new(0, -1, 0),
                    offsetAdder = Vector3.new(offsetX, 0, offsetZ)
                }
            })
    end

    return strays
end

module.initStrays = initStrays
module.createStray = createStray

return module
