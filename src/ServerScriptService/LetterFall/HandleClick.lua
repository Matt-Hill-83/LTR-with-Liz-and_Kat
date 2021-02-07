local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local Leaderboard = require(Sss.Source.AddRemoteObjects.Leaderboard)

local clickBlockEvent = RS:WaitForChild("ClickBlockRE")

local module = {}

function isDesiredLetter(availLetters, clickedLetter)
    local textLabel = Utils.getFirstDescendantByName(clickedLetter, "BlockChar")
                          .Text
    local char = LetterFallUtils.getCharFromLetterBlock(clickedLetter)
    return availLetters[char]
end

function isDeadLetter(clickedLetter)
    local tag = LetterFallUtils.tagNames.DeadLetter
    return CS:HasTag(clickedLetter, tag)
end

-- TODO: I'm probably doing this closure wrong
-- TODO: I'm probably doing this closure wrong
-- TODO: I'm probably doing this closure wrong
function initClickHandler(miniGameState)
    -- Gets arguments from EventHandler in StarterPack
    function brickClickHandler(player, clickedLetter)
        handleBrick(clickedLetter, miniGameState, player)
    end

    clickBlockEvent.OnServerEvent:Connect(brickClickHandler)
end

function findFirstMatchingLetterBlock(foundChar, miniGameState)
    local matchingLetter = nil

    for wordIndex, word in ipairs(miniGameState.renderedWords) do
        if matchingLetter then break end
        for letterIndex, letter in ipairs(word.letters) do
            if matchingLetter then break end
            if foundChar == letter.char then
                miniGameState.activeWord = word
                matchingLetter = letter.instance
            end
        end
    end
    return matchingLetter
end

function getAvailWords(miniGameState)
    local availWords = {}
    local activeWord = miniGameState.activeWord

    if activeWord then
        availWords = {activeWord.wordChars}
    else
        availWords = miniGameState.words
    end
    return availWords
end

function handleBrick(clickedLetter, miniGameState, player)
    local letterFallFolder = miniGameState.letterFallFolder
    local runTimeLetterFolder = miniGameState.runTimeLetterFolder

    local isChild = clickedLetter:IsDescendantOf(letterFallFolder)

    if not isChild then
        -- Anchor letters if letter is clicked is a different game instance
        LetterFallUtils.anchorLetters({
            parentFolder = runTimeLetterFolder,
            anchor = true
        })
        return {}
    end
    if isDeadLetter(clickedLetter) then return end

    local activeWord = miniGameState.activeWord
    print('activeWord' .. ' - start');
    print(activeWord);
    local currentLetterIndex = miniGameState.currentLetterIndex
    local words = miniGameState.words

    local rackLetters = Utils.getByTagInParent(
                            {
            parent = runTimeLetterFolder,
            tag = LetterFallUtils.tagNames.RackLetter
        })

    local notDeadLetters = LetterFallUtils.filterItemsByTag(
                               {
            items = rackLetters,
            tag = LetterFallUtils.tagNames.DeadLetter,
            include = false
        })

    LetterFallUtils.anchorLetters({
        parentFolder = runTimeLetterFolder,
        anchor = true
    })

    local activeCol =
        LetterFallUtils.getCoordsFromLetterName(clickedLetter.Name).col
    LetterFallUtils.anchorColumn({
        col = activeCol,
        letters = notDeadLetters,
        anchor = false
    })
    clickedLetter.Anchored = true

    if not miniGameState.gemsStarted then
        -- miniGameState.gemsStarted = true
    end

    local foundChar = LetterFallUtils.getCharFromLetterBlock(clickedLetter)
    local targetLetterBlock = nill
    local availWords = {}

    if activeWord then
        availWords = {activeWord.wordChars}
        local nextLetterInWord = activeWord.letters[currentLetterIndex].char
        local found = foundChar == nextLetterInWord
        if found then
            targetLetterBlock = activeWord.letters[currentLetterIndex].instance
        end
    else
        availWords = words
        local availLetters = LetterFallUtils.getAvailLettersDict(
                                 {
                words = words,
                currentLetterIndex = currentLetterIndex
            })

        if isDesiredLetter(availLetters, clickedLetter) then
            targetLetterBlock = findFirstMatchingLetterBlock(foundChar,
                                                             miniGameState)
        end
    end

    if targetLetterBlock then
        miniGameState.currentLetterIndex = miniGameState.currentLetterIndex + 1
        CS:AddTag(clickedLetter, LetterFallUtils.tagNames.Found)
        CS:RemoveTag(clickedLetter, LetterFallUtils.tagNames.RackLetter)

        local tween = Utils3.tween({
            part = clickedLetter,
            endPosition = targetLetterBlock.Position,
            time = 0.4,
            anchor = true
        })

        Utils.hideItemAndChildren({item = targetLetterBlock, hide = true})

        table.insert(miniGameState.foundLetters,
                     LetterFallUtils.getCharFromLetterBlock(clickedLetter))

        local currentWord = table.concat(miniGameState.foundLetters, "")
        local wordComplete = table.find(words, currentWord)

        if (wordComplete) then
            local wordConfig = Constants.wordConfigs[currentWord]
            if wordConfig then
                local soundId = Constants.wordConfigs[currentWord]['soundId']
                if (soundId) then
                    local sound = Instance.new("Sound", workspace)
                    sound.SoundId = "rbxassetid://" .. soundId
                    sound.EmitterSize = 5
                    sound.Looped = false
                    if not sound.IsPlaying then sound:Play() end
                end
            end

            table.insert(miniGameState.foundWords, currentWord)
            miniGameState.foundLetters = {}
            miniGameState.currentLetterIndex = 1
            miniGameState.activeWord = nil

            local wins = player.leaderstats.Wins
            wins.Value = wins.Value + 1
            Leaderboard.updateLB()
        end

        LetterFallUtils.styleLetterBlocks(
            {
                miniGameState = miniGameState,
                availWords = getAvailWords(miniGameState)
            })

        clickedLetter.CFrame = targetLetterBlock.CFrame
    end
end

module.initClickHandler = initClickHandler
module.handleBrick = handleBrick
return module
