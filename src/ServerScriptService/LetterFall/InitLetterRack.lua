local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("ClickBlockRE")
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)

local module = {}

function isDeadLetter(props)
    local rowIndex = props.rowIndex
    local colIndex = props.colIndex
    local deadLetters = props.deadLetters

    local isDead = false
    for i, deadLetter in ipairs(deadLetters) do
        if deadLetter.row == rowIndex and deadLetter.col == colIndex then
            isDead = true
            break
        end
    end
    return isDead
end

function generateDeadLetters(props)
    local numCol = props.numCol
    local numRow = props.numRow
    local lettersPerCol = props.lettersPerCol

    local output = {}
    for colIndex = 2, numCol do
        for letterIndex = 1, lettersPerCol do
            local rowIndex = Utils.genRandom(1, numRow)
            table.insert(output, {row = rowIndex, col = colIndex})
        end
    end
    return output
end

function initLetterRack(miniGameState)
    local runTimeLetterFolder = LetterFallUtils.getRunTimeLetterFolder(
                                    miniGameState)
    miniGameState.runTimeLetterFolder = runTimeLetterFolder

    local letterFallFolder = miniGameState.letterFallFolder
    local letterRackFolder = Utils.getFirstDescendantByName(letterFallFolder,
                                                            "LetterRackFolder")
    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "LBRack")
    local letterPositioner = Utils.getFirstDescendantByName(letterRackFolder,
                                                            "RackLetterBlockPositioner")

    local numRow = 10
    local numCol = 16
    local spacingFactorX = 1.01
    local spacingFactorY = 1.0

    local lettersFromWords = {}
    for wordIndex, word in ipairs(miniGameState.words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex + 0)
            table.insert(lettersFromWords, letter)
            table.insert(lettersFromWords, letter)
            table.insert(lettersFromWords, letter)
            table.insert(lettersFromWords, letter)
            table.insert(lettersFromWords, letter)
            table.insert(lettersFromWords, letter)
            table.insert(lettersFromWords, letter)
        end
    end

    local deadLetters = generateDeadLetters(
                            {
            numCol = numCol,
            numRow = numRow,
            lettersPerCol = 2
        })

    for colIndex = 1, numCol do
        for rowIndex = 1, numRow do
            local rand = Utils.genRandom(1, #lettersFromWords)

            local char = lettersFromWords[rand]
            local newLetter = letterBlockTemplate:Clone()

            LetterFallUtils.applyStyleFromTemplate(
                {
                    targetLetterBlock = newLetter,
                    templateName = "LBPurpleLight",
                    miniGameState = miniGameState
                })
            local letterId = "ID--R" .. rowIndex .. "C" .. colIndex
            local name = "rackLetter-" .. char .. "-" .. letterId
            newLetter.Name = name

            local isDeadLetter = isDeadLetter(
                                     {
                    rowIndex = rowIndex,
                    colIndex = colIndex,
                    deadLetters = deadLetters

                })

            CS:AddTag(newLetter, LetterFallUtils.tagNames.RackLetter)
            if isDeadLetter then
                CS:AddTag(newLetter, LetterFallUtils.tagNames.DeadLetter)
            else
                CS:AddTag(newLetter, LetterFallUtils.tagNames.NotDeadLetter)
            end

            LetterFallUtils.applyLetterText(
                {letterBlock = newLetter, char = char})

            local offsetY = (newLetter.Size.Y - letterPositioner.Size.Y) / 2

            local letterPosX = -newLetter.Size.X * (colIndex - 1) *
                                   spacingFactorX
            local letterPosY = newLetter.Size.Y * (rowIndex - 1) *
                                   spacingFactorY + offsetY
            newLetter.CFrame = letterPositioner.CFrame *
                                   CFrame.new(
                                       Vector3.new(letterPosX, letterPosY, 0))

            newLetter.Parent = runTimeLetterFolder
            newLetter.Anchored = true
        end
    end

    LetterFallUtils.configDeadLetters({
        parentFolder = runTimeLetterFolder,
        miniGameState = miniGameState
    })
end

-- function getRunTimeLetterFolder(miniGameState)
--     local letterFallFolder = miniGameState.letterFallFolder
--     local runtimeFolder = Utils.getOrCreateFolder(
--                               {
--             name = "RunTimeFolder",
--             parent = letterFallFolder
--         })

--     return Utils.getOrCreateFolder({
--         name = "RunTimeLetterRackFolder",
--         parent = runtimeFolder
--     })
-- end

module.initLetterRack = initLetterRack

return module
