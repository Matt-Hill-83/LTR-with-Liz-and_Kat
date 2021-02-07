local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
-- local Constants = require(Sss.Source.Constants.Constants)
local Const3 = require(Sss.Source.Constants.Const_03_Letters)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local module = {
    tagNames = {
        WordLetter = "WordLetter",
        LetterBlock = "LetterBlock",
        RackLetter = "RackLetter",
        DeadLetter = "DeadLetter",
        AvailLetter = "AvailLetter",
        Found = "Found",
        NotDeadLetter = "NotDeadLetter"
    }
}

module.letterBlockStyleNames = {
    -- LBPinkPurple = "LBPinkPurple",
    LBPurpleOrange = "LBPurpleOrange",
    LBPurpleLight = "LBPurpleLight",
    LBPurpleLight2 = "LBPurpleLight2",
    LBDarkPurple = "LBDarkPurple",
    LBDeadLetter = "LBDeadLetter"
}

module.letterBlockPropNames = {
    Character = "Character",
    CurrentStyle = "CurrentStyle",
    IsHidden = "IsHidden",
    IsLifted = "IsLifted",
    IsFound = "IsFound",
    Type = "Type",
    Uuid = "Uuid"

}

module.letterBlockStyleDefs = {
    rack = {
        Available = module.letterBlockStyleNames.LBPurpleLight2,
        NotAvailable = module.letterBlockStyleNames.LBPurpleLight,
        Found = module.letterBlockStyleNames.LBPurpleOrange,
        DeadLetter = module.letterBlockStyleNames.LBDeadLetter
    },
    word = {
        Placeholder = module.letterBlockStyleNames.LBPurpleLight,
        Found = module.letterBlockStyleNames.LBPurpleOrange
    }
}

local function playWordSound(word)
    local closure = function()
        if Const4.wordConfigs[word] then
            local soundId = Const4.wordConfigs[word]['soundId']

            if (soundId) then
                local sound = Instance.new("Sound", workspace)
                sound.SoundId = "rbxassetid://" .. soundId
                sound.EmitterSize = 5
                sound.Looped = false
                if not sound.IsPlaying then sound:Play() end
            end
        end
    end
    return closure
end

local function getLettersNotInWords(words)
    local allLetters = Const3.allLetters

    local uniqueLettersFromWords = {}

    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)
            uniqueLettersFromWords[letter] = true
        end
    end

    local filteredLetters = {}
    for _, letter in ipairs(allLetters) do

        if not uniqueLettersFromWords[letter] then
            table.insert(filteredLetters, letter)
        end
    end

    return filteredLetters
end

local function getRandomLetter(letters)
    local defaultLetters = Const3.allLetters

    if not letters then letters = defaultLetters end
    local rand = Utils.genRandom(1, #letters)
    return letters[rand]
end

local function getAvailWords(miniGameState)
    local availWords = {}
    local activeWord = miniGameState.activeWord

    if activeWord then
        availWords = {activeWord.wordChars}
    else
        for _, wordObj in ipairs(miniGameState.renderedWords) do
            if wordObj.completed == false then
                table.insert(availWords, wordObj)
            end
        end
    end
    return availWords
end

local function createPropOnLetterBlock(props)
    local letterBlock = props.letterBlock
    local propName = props.propName
    local initialValue = props.initialValue
    local propType = props.propType

    local propChar = Instance.new(propType, letterBlock)
    propChar.Name = propName
    propChar.Value = initialValue

end

local function initLetterBlock(props)
    local letterBlock = props.letterBlock
    local char = props.char
    local templateName = props.templateName
    local letterBlockType = props.letterBlockType
    local isTextLetter = props.isTextLetter

    CS:AddTag(letterBlock, "BlockDash")

    if isTextLetter then
        module.applyLetterText({letterBlock = letterBlock, char = char})
    else
        module.applyLetterImage(letterBlock, char)
    end

    createPropOnLetterBlock({
        letterBlock = letterBlock,
        propName = module.letterBlockPropNames.Character,
        initialValue = char,
        propType = "StringValue"
    })

    createPropOnLetterBlock({
        letterBlock = letterBlock,
        propName = module.letterBlockPropNames.CurrentStyle,
        initialValue = "zzz",
        propType = "StringValue"
    })

    createPropOnLetterBlock({
        letterBlock = letterBlock,
        propName = module.letterBlockPropNames.Uuid,
        initialValue = Utils.getUuid(),
        propType = "StringValue"
    })

    createPropOnLetterBlock({
        letterBlock = letterBlock,
        propName = module.letterBlockPropNames.Type,
        initialValue = letterBlockType,
        propType = "StringValue"
    })

    createPropOnLetterBlock({
        letterBlock = letterBlock,
        propName = module.letterBlockPropNames.IsHidden,
        initialValue = false,
        propType = "BoolValue"
    })

    -- This seems redundant.
    -- I assume we do this after everything is created.
    if templateName then
        if isTextLetter then
            module.applyStyleFromTemplate(
                {targetLetterBlock = letterBlock, templateName = templateName})
        else
            module.applyStyleFromTemplateBD(
                {targetLetterBlock = letterBlock, templateName = templateName})
        end
    end
end

local function applyLetterImage(letterBlock, char)
    local imageId = Const3.alphabet[char]['decalId']
    local imageUri = 'rbxassetid://' .. imageId

    local labels = Utils.getDescendantsByName(letterBlock, "ImageLabel")
    for _, label in ipairs(labels) do label.Image = imageUri end
end

local function applyStyleFromTemplateBD(props)
    local targetLetterBlock = props.targetLetterBlock
    local templateName = props.templateName

    local letterBlockTemplateFolder = Utils.getFromTemplates(
                                          "LetterBlockTemplates")

    local template = Utils.getFirstDescendantByName(letterBlockTemplateFolder,
                                                    templateName)
    targetLetterBlock.Color = template.Color
end

local function liftLetter(letterBlock, liftUp)
    letterBlock.WeldConstraintRackBlock.Enabled = false

    local liftDistance = 1.25
    if liftUp == true then
        if letterBlock.IsLifted.Value == false then
            letterBlock.CFrame = letterBlock.CFrame *
                                     CFrame.new(0, letterBlock.Size.Y *
                                                    liftDistance, 0)
            letterBlock.IsLifted.Value = true
            letterBlock.CanCollide = false
            -- letterBlock.Sparkles.Enabled = true

        end
    else
        if letterBlock.IsLifted.Value == true then
            letterBlock.CFrame = letterBlock.CFrame *
                                     CFrame.new(0, -letterBlock.Size.Y *
                                                    liftDistance, 0)
            letterBlock.IsLifted.Value = false
            letterBlock.CanCollide = true
            -- letterBlock.Sparkles.Enabled = false
        end
    end
    letterBlock.WeldConstraintRackBlock.Enabled = true
end

local function revertRackLetterBlocksToInit(miniGameState)
    local allLetters = module.getAllLettersInRack2(miniGameState)

    -- revert Letter Rack styles
    for _, letterBlock in ipairs(allLetters) do
        liftLetter(letterBlock, false)
        letterBlock.CurrentStyle.Value = "none"
        letterBlock.IsHidden.Value = false
        letterBlock.IsFound.Value = false
        Utils.hideItemAndChildren({item = letterBlock, hide = false})
    end

    -- revert word styles
    for _, wordObj in ipairs(miniGameState.renderedWords) do
        wordObj.completed = false
        for _, letterObj in ipairs(wordObj.letters) do
            local letterBlock = letterObj.instance
            module.applyStyleFromTemplateBD(
                {
                    targetLetterBlock = letterBlock,
                    templateName = "BD_word_normal"
                })
            local firePositioners = Utils.getDescendantsByName(letterBlock,
                                                               "FirePositioner")
            for _, firePositioner in ipairs(firePositioners) do
                local fire = firePositioner:FindFirstChild("Fire")
                if fire then fire:Destroy() end
            end

            Utils.hideItemAndChildren({item = letterBlock, hide = false})
        end
    end

end

local function applyStyleFromTemplate(props)
    local targetLetterBlock = props.targetLetterBlock
    local templateName = props.templateName
    local blockProps = props.blockProps or {}
    local labelProps = props.labelProps or {}

    local currentStyleProp = Utils.getFirstDescendantByName(targetLetterBlock,
                                                            "CurrentStyle")
    if not currentStyleProp then
        createPropOnLetterBlock({
            letterBlock = targetLetterBlock,
            propName = module.letterBlockPropNames.CurrentStyle,
            initialValue = "none",
            propType = "StringValue"
        })
    end

    local currentStyle = targetLetterBlock.CurrentStyle.Value

    if currentStyle then
        if currentStyle == templateName then
            -- Do not apply a style that already exists
            return
        else
            targetLetterBlock.CurrentStyle.Value = templateName
        end
    end

    local letterBlockTemplateFolder = Utils.getFromTemplates(
                                          "LetterBlockTemplates")
    local template = Utils.getFirstDescendantByName(letterBlockTemplateFolder,
                                                    templateName)

    Utils.mergeTables(targetLetterBlock, blockProps)

    local label = Utils.getFirstDescendantByName(template, "BlockChar")

    local baseLabelProps = {
        TextColor3 = label.TextColor3,
        TextStrokeColor3 = label.TextStrokeColor3,
        BorderColor3 = label.BorderColor3,
        BackgroundColor3 = label.BackgroundColor3,
        TextStrokeTransparency = label.TextStrokeTransparency
    }

    Utils.mergeTables(baseLabelProps, labelProps)
    -- local mergedLabelProps = Utils.mergeTables(baseLabelProps, labelProps)
    module.styleLetterBlock(targetLetterBlock, baseLabelProps)
end

local function applyLetterText(props)
    local char = props.char
    local letterBlock = props.letterBlock

    -- if not char then return end
    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    if textLabels then
        for i, label in ipairs(textLabels) do label.Text = char end
    end

end

local function filterItemsByTag(props)
    local items = props.items
    local tag = props.tag
    local include = props.include

    local output = {}
    for i, item in ipairs(items) do

        if include then
            if CS:hasTag(item, tag) then table.insert(output, item) end
        end

        if not include then
            if not CS:hasTag(item, tag) then
                table.insert(output, item)
            end
        end
    end
    return output
end

local function getCoordsFromLetterName(name)
    local pattern = "ID%-%-R(%d+)C(%d+)"
    local row, col = string.match(name, pattern)
    return {row = tonumber(row), col = tonumber(col)}
end

local function getRunTimeLetterFolder(miniGameState)
    local sectorFolder = miniGameState.sectorFolder
    local runtimeFolder = Utils.getOrCreateFolder(
                              {name = "RunTimeFolder", parent = sectorFolder})

    return Utils.getOrCreateFolder({
        name = "RunTimeLetterRackFolder",
        parent = runtimeFolder
    })
end

local function styleLetterBlock(letterBlock, labelProps)
    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for _, label in ipairs(textLabels) do
        Utils.mergeTables(label, labelProps)
    end
end

local function styleImageLabelsInBlock(letterBlock, labelProps)
    local labels = Utils.getDescendantsByName(letterBlock, "ImageLabel")
    for i, label in ipairs(labels) do Utils.mergeTables(label, labelProps) end
end

local function styleLetterBlocksBD(props)
    local miniGameState = props.miniGameState
    local currentLetterIndex = miniGameState.currentLetterIndex

    local activeWord = miniGameState.activeWord
    local availWords = {}

    if activeWord then
        availWords = {activeWord.wordChars}
    else
        for _, wordObj in ipairs(miniGameState.renderedWords) do
            if wordObj.completed == false then
                table.insert(availWords, wordObj.wordChars)
            end
        end
    end

    local availLetters = module.getAvailLettersDict(
                             {
            words = availWords,
            currentLetterIndex = currentLetterIndex
        })

    local allLetters = module.getAllLettersInRack2(miniGameState)

    for _, letterBlock in ipairs(allLetters) do
        local char = module.getCharFromLetterBlock2(letterBlock)
        local templateName = nil

        if availLetters[char] then
            module.liftLetter(letterBlock, true)
            templateName = miniGameState.activeStyle
        else
            module.liftLetter(letterBlock, false)
            templateName = miniGameState.inActiveStyle
        end

        module.applyStyleFromTemplate({
            targetLetterBlock = letterBlock,
            templateName = templateName
        })

        -- module.applyStyleFromTemplateBD({
        --     targetLetterBlock = letterBlock,
        --     templateName = templateName
        -- })
    end

end

local function colorLetterText(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do label.TextColor3 = color end
end

local function colorLetterBorder(props)
    local color = props.color
    local letterBlock = props.letterBlock

    local textLabels = Utils.getDescendantsByName(letterBlock, "BlockChar")
    for i, label in ipairs(textLabels) do
        label.BorderColor3 = color or Color3.new(255, 0, 191)
    end
end

local function getCharFromLetterBlock2(letterBlock)
    if not letterBlock then return end
    local char = letterBlock.Character.Value
    return char
end

local function isDesiredLetter(letter, clickedLetter)
    local textLabel = Utils.getFirstDescendantByName(clickedLetter, "BlockChar")
                          .Text
    return letter.found ~= true and letter.char == textLabel
end

local function isWordComplete(wordLetters)
    for i, word in ipairs(wordLetters) do
        if not word.found then return false end
    end
    return true
end

local function getAvailLettersDict2(miniGameState)
    local availableWords = {}
    for _, wordObj in ipairs(miniGameState.renderedWords) do
        if wordObj.completed == false then
            table.insert(availableWords, wordObj)
        end
    end

    local availLettersDict = {}
    for i, word in ipairs(availableWords) do
        local letter = string.sub(word.wordChars, 1, 1)
        availLettersDict[letter] = true
    end
    return availLettersDict
end

local function getAvailLettersDict(props)
    local words = props.words
    local currentLetterIndex = props.currentLetterIndex

    local availLettersDict = {}
    for i, word in ipairs(words) do
        local letter = string.sub(word, currentLetterIndex, currentLetterIndex)
        availLettersDict[letter] = true
    end
    return availLettersDict
end

local function getAllLettersInRack2(miniGameState)
    local letterBlocks = {}
    for _, obj in ipairs(miniGameState.rackLetterBlockObjs) do
        table.insert(letterBlocks, obj.part)
    end
    return letterBlocks

end

local function getAllLettersInWords(props)
    local runTimeWordFolder = props.runTimeWordFolder
    local letters = Utils.getByTagInParent(
                        {
            parent = runTimeWordFolder,
            tag = module.tagNames.WordLetter
        })
    return letters
end

module.applyLetterText = applyLetterText
module.styleLetterBlock = styleLetterBlock
module.colorLetterText = colorLetterText
module.isDesiredLetter = isDesiredLetter
module.isWordComplete = isWordComplete
module.getAvailLettersDict = getAvailLettersDict
module.colorLetterBorder = colorLetterBorder
module.applyStyleFromTemplate = applyStyleFromTemplate
module.getCoordsFromLetterName = getCoordsFromLetterName
module.filterItemsByTag = filterItemsByTag
module.getRunTimeLetterFolder = getRunTimeLetterFolder
module.applyStyleFromTemplateBD = applyStyleFromTemplateBD
module.applyLetterImage = applyLetterImage
module.getAvailLettersDict2 = getAvailLettersDict2
module.initLetterBlock = initLetterBlock
module.styleLetterBlocksBD = styleLetterBlocksBD
module.getAvailWords = getAvailWords
module.getRandomLetter = getRandomLetter
module.getCharFromLetterBlock2 = getCharFromLetterBlock2
module.getLettersNotInWords = getLettersNotInWords
module.styleImageLabelsInBlock = styleImageLabelsInBlock
module.getAllLettersInWords = getAllLettersInWords
module.playWordSound = playWordSound
module.liftLetter = liftLetter
module.revertRackLetterBlocksToInit = revertRackLetterBlocksToInit
module.getAllLettersInRack2 = getAllLettersInRack2
module.createPropOnLetterBlock = createPropOnLetterBlock
return module
