local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Utils5 = require(Sss.Source.Utils.U005LetterGrabberUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function createStray(char, parentFolder)
    local letterBlockTemplate = Utils.getFromTemplates("HexLetterGemTemplate")

    local modelClone = letterBlockTemplate:Clone()
    local newLetterBlock = modelClone.PrimaryPart

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
    local callback = Utils5.blockTouchedByHuman
    newLetterBlock.Touched:Connect(Utils.onTouchBlock(newLetterBlock, callback))
    return newLetterBlock
end

local function initStraysInRegion(props)
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

module.initStraysInRegion = initStraysInRegion
module.createStray = createStray

return module
