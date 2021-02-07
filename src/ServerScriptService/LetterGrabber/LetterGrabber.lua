local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)
local Utils5 = require(Sss.Source.Utils.U005LetterGrabberUtils)

local Replicator = require(Sss.Source.BlockDash.Replicator)

local module = {}

local function configWordLetters(props)
    local newWord = props.part
    local word = props.word
    local wordNameStub = props.wordNameStub

    local letterPositioner = Utils.getFirstDescendantByName(newWord,
                                                            "LetterPositioner")
    letterPositioner.Name = letterPositioner.Name .. 'aaaa'

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "LB_2_blank")

    local wordBench = Utils.getFirstDescendantByName(newWord, "WordBench")
    wordBench.Name = wordBench.Name .. "yyyy"

    local spacingFactorX = 1.05

    local lettersInWord = {}
    for letterIndex = 1, #word do
        local letterNameStub = wordNameStub .. "-L" .. letterIndex
        local char = string.sub(word, letterIndex, letterIndex)
        local newLetter = letterBlockTemplate:Clone()

        LetterUtils.applyStyleFromTemplate(
            {targetLetterBlock = newLetter, templateName = "Grabber_normal"})

        newLetter.Name = "wordLetter-" .. letterNameStub .. "xxxx"
        newLetter.Anchored = false
        newLetter.CanCollide = false

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetter,
                propName = "IsActive",
                initialValue = false,
                propType = "BoolValue"
            })

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetter,
                propName = "IsFound",
                initialValue = false,
                propType = "BoolValue"
            })

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetter,
                propName = LetterUtils.letterBlockPropNames.CurrentStyle,
                initialValue = "zzz",
                propType = "StringValue"
            })

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetter,
                propName = LetterUtils.letterBlockPropNames.Character,
                initialValue = "zzz",
                propType = "StringValue"
            })

        LetterUtils.createPropOnLetterBlock(
            {
                letterBlock = newLetter,
                propName = "LetterIndex",
                initialValue = letterIndex,
                propType = "IntValue"
            })

        local letterPositionX = newLetter.Size.X * (letterIndex - 1) *
                                    spacingFactorX

        CS:AddTag(newLetter, "WordGrabberLetter")
        LetterUtils.applyLetterText({letterBlock = newLetter, char = char})
        newLetter.Character.Value = char
        newLetter.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                               {
                parent = letterPositioner,
                child = newLetter,
                offsetConfig = {
                    useParentNearEdge = Vector3.new(-1, -1, -1),
                    useChildNearEdge = Vector3.new(-1, -1, -1),
                    offsetAdder = Vector3.new(0, 0, letterPositionX)
                }
            })

        local weld = Instance.new("WeldConstraint")
        weld.Name = "WeldConstraint" .. letterNameStub
        weld.Parent = wordBench
        weld.Part0 = wordBench
        weld.Part1 = newLetter

        -- Do this last to avoid tweening
        newLetter.Parent = newWord

        table.insert(lettersInWord,
                     {char = char, found = false, instance = newLetter})
    end

    local wordBenchSizeX = #word * letterBlockTemplate.Size.X * spacingFactorX

    wordBench.Size = Vector3.new(wordBenchSizeX, wordBench.Size.Y,
                                 wordBench.Size.Z)

    local newWordObj = {
        word = newWord,
        letters = lettersInWord,
        wordChars = word
    }

    letterPositioner:Destroy()
    letterPositioner.Transparency = 1
    return newWordObj
end

local function applyDecalsToCharacterFromWord(props)
    local part = props.part
    local word = props.word

    if Const4.wordConfigs[word] then
        local imageId = Const4.wordConfigs[word]['imageId']
        if imageId then
            local decalUri = 'rbxassetid://' .. imageId
            local decals = Utils.getDescendantsByName(part, "ImageLabel")

            for _, decal in ipairs(decals) do decal.Image = decalUri end
        end
    end
end

local function initWord(props, wordIndex, config)
    local parentFolder = props.parentFolder

    local positioner = Utils.getFirstDescendantByName(parentFolder,
                                                      "LetterGrabberPositioner")
    local template = Utils.getFromTemplates("GrabberReplicatorTemplate")

    local newReplicator = template:Clone()
    local lettterGrabber = Utils.getFirstDescendantByName(newReplicator,
                                                          "LetterGrabber")

    newReplicator.Parent = parentFolder
    local newReplicatorPart = newReplicator.PrimaryPart
    local wordNameStub = "-W" .. wordIndex

    configWordLetters({
        part = lettterGrabber,
        word = config,
        wordNameStub = wordNameStub
    })

    local offsetX = wordIndex * 10
    newReplicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
            parent = positioner,
            child = newReplicatorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(offsetX, 0, 0)
            }
        })

    newReplicatorPart.Anchored = true
    Replicator.init(newReplicator)
    Utils5.styleLetterGrabberBlocks(lettterGrabber)
end

local function initSingle(props)
    local parentFolder = props.parentFolder
    local positioner = props.positioner
    local word = props.word

    local template = Utils.getFromTemplates("GrabberReplicatorTemplate")

    local newReplicator = template:Clone()
    local lettterGrabber = Utils.getFirstDescendantByName(newReplicator,
                                                          "LetterGrabber")

    newReplicator.Parent = parentFolder
    local newReplicatorPart = newReplicator.PrimaryPart

    applyDecalsToCharacterFromWord({part = lettterGrabber, word = word})
    configWordLetters({part = lettterGrabber, word = word, wordNameStub = ""})

    -- local breaker = Utils.getFirstDescendantByName(lettterGrabber, "Breaker")
    newReplicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
            parent = positioner,
            child = newReplicatorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        })

    newReplicatorPart.Anchored = true

    Replicator.init(newReplicator)
    return newReplicator
end

function module.initLetterGrabbers(props)
    local words = props.words

    for wordIndex, config in ipairs(words) do
        initWord(props, wordIndex, config)
    end
end

function module.initLetterGrabber(props)
    -- 
    initSingle(props)
end

return module

