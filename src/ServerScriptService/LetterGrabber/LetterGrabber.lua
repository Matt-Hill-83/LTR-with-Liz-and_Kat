local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local Utils5 = require(Sss.Source.Utils.U005LetterGrabberUtils)

local Const4 = require(Sss.Source.Constants.Const_04_Characters)

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

    local spacingFactorX = 0.05
    local letterGapX = letterBlockTemplate.Size.X * spacingFactorX
    local spacingIncrementX = letterGapX + letterBlockTemplate.Size.X

    local lettersInWord = {}
    for letterIndex = 1, #word do
        local letterNameStub = wordNameStub .. "-L" .. letterIndex
        local char = string.sub(word, letterIndex, letterIndex)
        local newLetter = letterBlockTemplate:Clone()

        LetterUtils.applyStyleFromTemplate(
            {targetLetterBlock = newLetter, templateName = "Grabber_normal"})

        newLetter.Name = "wordLetter-" .. letterNameStub .. "-qqq-" ..
                             letterIndex .. "-ch-" .. char
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

        local letterPositionX = (letterIndex - 1) * spacingIncrementX - 2 *
                                    letterGapX

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

    local wordBenchSizeX = (#word * letterBlockTemplate.Size.X) + (#word - 1) *
                               letterGapX

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

local function onTouch(tool)
    local db = {value = false}

    local function closure(otherPart)
        local humanoid = tool.Parent:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
        if not otherPart:FindFirstChild("Type") then return end
        if otherPart.Type.Value ~= "StrayLetter" then return end
        if db.value == true then return end

        db.value = true
        local player = Utils.getPlayerFromHumanoid(humanoid)
        Utils5.partTouched(otherPart, player)
        db.value = false
    end
    return closure
end

local function afterReplication(replicatedPart)
    local touchRegion = Utils.getFirstDescendantByName(replicatedPart,
                                                       "TouchRegion")
    touchRegion.Touched:Connect(onTouch(replicatedPart))
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

    local wordModel = lettterGrabber.Word

    LetterUtils.createPropOnLetterBlock({
        letterBlock = wordModel,
        propName = "TargetWord",
        initialValue = word,
        propType = "StringValue"
    })

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

    Replicator.init(newReplicator, afterReplication)
    return newReplicator
end

function module.initLetterGrabber(props)
    -- 
    initSingle(props)
end

return module

