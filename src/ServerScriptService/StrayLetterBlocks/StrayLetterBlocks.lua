local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Const_Client = require(RS.Source.Constants.Constants_Client)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Utils5 = require(Sss.Source.Utils.U005LetterGrabberUtils)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local module = {}

local function blockFound(tool, player)
    local updateWordGuiRE = RS:WaitForChild(
                                Const_Client.RemoteEvents.UpdateWordGuiRE)

    local function destroyParts()
        local explosionSound = '515938718'
        Utils.playSound(explosionSound, 0.5)
        Utils5.resetBlocks(tool)
        Utils5.setActiveLetterGrabberBlock(tool)
        Utils5.styleLetterGrabberBlocks(tool)

        local wordModel = tool.Word
        local targetWord = wordModel.TargetWord.Value

        local gameState = PlayerStatManager.getGameState(player)
        local levelConfig = gameState.levelConfig
        local targetWordObj = Utils.getListItemByPropValue(
                                  levelConfig.targetWords, "word", targetWord)

        targetWordObj.found = targetWordObj.found + 1

        updateWordGuiRE:FireAllClients({levelConfig = levelConfig})
    end
    delay(1, destroyParts)
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

                    local newActiveBlock =
                        Utils5.getActiveLetterGrabberBlock(tool)
                    if not newActiveBlock then
                        blockFound(tool, player)
                    end
                end
            end
            db.value = false
        end
    end
    return closure
end

local function initStrays(props)
    -- local strayLetterBlockObjs = props.strayLetterBlockObjs
    local parentFolder = props.parentFolder
    local numBlocks = props.numBlocks
    local region = props.region
    local words = props.words
    local rackLetterSize = props.rackLetterSize or 6

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "LB_4_blank")

    -- populate matrix with letters
    local letterMatrix = {}

    -- combine all plates into a single matrix and populate matrix with random letters
    local lettersNotInWords = LetterUtils.getLettersNotInWords(words)

    -- This is a 2d array bc I recycled some other code, but it it just a 1d array
    local totalRows = numBlocks
    local numCol = 1
    local numRow = totalRows

    for _ = 1, totalRows do
        table.insert(letterMatrix,
                     LetterUtils.getRandomLetter(lettersNotInWords))
    end
    -- for _ = 1, totalRows do
    --     local row = {}
    --     for _ = 1, numCol do
    --         table.insert(row, LetterUtils.getRandomLetter(lettersNotInWords))
    --     end
    --     table.insert(letterMatrix, row)
    -- end

    local usedLocations = {}
    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)

            local isDirtyLocation = true
            local randomRowIndex = nil
            -- local randomColIndex = nil
            local locationCode = nil

            -- make sure you do not put 2 letters in the same location
            while isDirtyLocation == true do
                randomRowIndex = Utils.genRandom(1, totalRows)
                -- randomColIndex = Utils.genRandom(1, numCol)
                locationCode = randomRowIndex
                isDirtyLocation = usedLocations[locationCode]
            end

            usedLocations[locationCode] = true
            letterMatrix[randomRowIndex] = letter
        end
    end

    -- local colIndex = 1
    for rowIndex = 1, numRow do
        print('rowIndex' .. ' - start');
        print(rowIndex);
        local newLetterBlock = letterBlockTemplate:Clone()

        newLetterBlock.Size = Vector3.new(rackLetterSize, rackLetterSize,
                                          rackLetterSize)

        local letterId = "ID--R" .. rowIndex
        local char = letterMatrix[rowIndex]

        local name = "strayLetter-ppp" .. char .. "-" .. letterId
        newLetterBlock.Name = name

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetterBlock,
                propName = LetterUtils.letterBlockPropNames.IsLifted,
                initialValue = false,
                propType = "BoolValue"
            })

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetterBlock,
                propName = LetterUtils.letterBlockPropNames.IsFound,
                initialValue = false,
                propType = "BoolValue"
            })

        local offsetX = Utils.genRandom(0, region.Size.X) - region.Size.X / 2
        local offsetZ = Utils.genRandom(0, region.Size.Z) - region.Size.Z / 2

        -- local offsetX = Utils.genRandom(0, 20)
        -- local offsetZ = Utils.genRandom(0, 20)

        newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                    {
                parent = region,
                child = newLetterBlock,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(0, 0, 0),
                    useChildNearEdge = Vector3.new(0, 0, 0),
                    offsetAdder = Vector3.new(offsetX, 0, offsetZ)
                }
            })

        newLetterBlock.Parent = parentFolder
        newLetterBlock.Anchored = false

        LetterUtils.initLetterBlock({
            letterBlock = newLetterBlock,
            char = char,
            templateName = "Stray_normal",
            isTextLetter = true,
            letterBlockType = "StrayLetter"
        })

        newLetterBlock.Touched:Connect(onTouchBlock(newLetterBlock, props))

        -- table.insert(strayLetterBlockObjs, {
        --     part = newLetterBlock,
        --     char = char,
        --     coords = {row = rowIndex}
        -- })
    end
    -- end

end

module.initStrays = initStrays

return module
