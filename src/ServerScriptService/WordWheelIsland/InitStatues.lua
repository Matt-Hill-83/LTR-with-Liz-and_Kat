local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local InitWord = require(Sss.Source.WordWheelIsland.InitWord)

local module = {}

local function initStatues(props)
    local statusDefs = props.statusDefs
    local statuePositioners = CS:GetTagged("StatuePositioner")

    local statueTemplate = Utils.getFromTemplates("StatueTemplate")

    for statueIndex, positionerModel in ipairs(statuePositioners) do
        local statusDef = statusDefs[(statueIndex % #statusDefs) + 1]

        local sentence = statusDef.sentence
        local character = statusDef.character
        local songId = statusDef.songId

        local newStatueScene = statueTemplate:Clone()

        local positioner = positionerModel.Positioner

        local dummy = Utils.getFirstDescendantByName(positionerModel, "Dummy")
        if dummy then dummy:Destroy() end

        newStatueScene.Parent = positioner.Parent
        newStatueScene.PrimaryPart.CFrame = positioner.CFrame
        newStatueScene.PrimaryPart.Anchored = true

        local sentencePositioner = Utils.getFirstDescendantByName(
                                       newStatueScene, "SentencePositioner")

        local wordGirl = Utils.getFirstDescendantByName(newStatueScene,
                                                        "WordGirl")
        local characterImage = Utils.getFirstDescendantByName(wordGirl,
                                                              "CharacterImage")

        Utils.applyDecalsToCharacterFromConfigName(
            {part = characterImage, configName = character})

        local wordLetters = {}

        if songId then
            local soundEmitter = Utils.getFirstDescendantByName(newStatueScene,
                                                                "StatueSong")
            soundEmitter.Sound.SoundId = "rbxassetid://" .. songId
            soundEmitter.Sound.Playing = true
            soundEmitter.Sound.Looped = true
        end

        local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
        local letterBlockTemplate = Utils.getFirstDescendantByName(
                                        letterBlockFolder, "LBPurpleLight")

        local letterWidth = letterBlockTemplate.Size.X
        local wordSpacer = letterWidth
        local totalLetterWidth = letterWidth * 1.1
        local sentenceLength = wordSpacer * #sentence - 1

        for _, word in ipairs(sentence) do
            sentenceLength = sentenceLength + #word * totalLetterWidth
        end

        local base = Utils.getFirstDescendantByName(newStatueScene, "Base")
        base.Size = Vector3.new(sentenceLength, base.Size.Y, base.Size.Z)

        local offsetX = sentenceLength / 2
        local currentWordPosition = {value = -letterWidth / 2}

        for wordIndex, word in ipairs(sentence) do
            local wordProps = {
                letterBlockTemplate = letterBlockTemplate,
                offsetX = offsetX,
                sentencePositioner = sentencePositioner,
                totalLetterWidth = totalLetterWidth,
                word = word,
                wordIndex = wordIndex,
                newStatueScene = newStatueScene,
                wordLetters = wordLetters,
                wordSpacer = wordSpacer,
                currentWordPosition = currentWordPosition
            }
            InitWord.initWord(wordProps)
        end
        -- sentencePositioner:Destroy()
        -- positionerModel:Destroy()
    end
    statueTemplate:Destroy()
end

module.initStatues = initStatues

return module

