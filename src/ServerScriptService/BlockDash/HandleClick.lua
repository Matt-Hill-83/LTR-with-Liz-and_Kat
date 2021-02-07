local Sss = game:GetService("ServerScriptService")

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local Constants2 = require(Sss.Source.Constants.Const_02_Colors)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local Leaderboard = require(Sss.Source.AddRemoteObjects.Leaderboard)

local module = {processing = false, initComplete = false}

local function isDesiredLetter(availLetters, clickedLetter)
    local char = LetterUtils.getCharFromLetterBlock2(clickedLetter)
    return availLetters[char]
end

local function findFirstMatchingLetterBlock(foundChar, miniGameState)
    local matchingLetter = nil
    local availWords = LetterUtils.getAvailWords(miniGameState)

    for _, word in ipairs(availWords) do
        local letter = word.letters[miniGameState.currentLetterIndex]
        if foundChar == letter.char then
            miniGameState.activeWord = word
            matchingLetter = letter.instance
            break
        end
    end
    return matchingLetter
end

local function onSelectRackBlock(clickedLetter, miniGameState, player)
    if module.processing == true then return end
    module.processing = true

    local sectorFolder = miniGameState.sectorFolder

    if not module.initComplete then
        module.initComplete = true
        -- 
    end

    local isChild = clickedLetter:IsDescendantOf(sectorFolder)

    if not isChild then
        module.processing = false
        return
    end

    if clickedLetter.IsFound.Value == true then
        module.processing = false
        return
    end

    local activeWord = miniGameState.activeWord
    local currentLetterIndex = miniGameState.currentLetterIndex
    local words = miniGameState.words

    local foundChar = LetterUtils.getCharFromLetterBlock2(clickedLetter)

    local targetLetterBlock = nil

    if activeWord then
        local nextLetterInWord = activeWord.letters[currentLetterIndex]

        -- I'm not sure why I get this condition
        if not nextLetterInWord then
            module.processing = false
            return
        end
        local nextCharInWord = nextLetterInWord.char
        local found = foundChar == nextCharInWord
        if found then
            targetLetterBlock = activeWord.letters[currentLetterIndex].instance
        end
    else
        local availLetters = LetterUtils.getAvailLettersDict2(miniGameState)
        if isDesiredLetter(availLetters, clickedLetter) then
            targetLetterBlock = findFirstMatchingLetterBlock(foundChar,
                                                             miniGameState)
        end
    end

    if targetLetterBlock then
        local letterBlockCFrame = clickedLetter.CFrame
        local clickedBlockClone = clickedLetter:Clone()
        clickedBlockClone.Parent = clickedLetter.Parent
        clickedBlockClone.CanCollide = false
        local fire = Instance.new("Fire", clickedBlockClone)
        fire.Size = 20

        Utils.enableChildWelds({part = clickedBlockClone, enabled = false})

        Utils.hideItemAndChildren({item = clickedLetter, hide = true})
        clickedLetter.IsHidden.Value = true
        clickedLetter.IsFound.Value = true
        Utils3.tween({
            part = clickedBlockClone,
            endPosition = targetLetterBlock.Position,
            time = 0.6,
            anchor = true
        })

        clickedBlockClone.CFrame = targetLetterBlock.CFrame
        LetterUtils.applyStyleFromTemplateBD(
            {
                targetLetterBlock = targetLetterBlock,
                templateName = "LBPurpleLight"
            })

        local clickedChar = LetterUtils.getCharFromLetterBlock2(clickedLetter)

        if clickedChar then
            table.insert(miniGameState.foundLetters,
                         LetterUtils.getCharFromLetterBlock2(clickedLetter))
        end

        clickedBlockClone:Destroy()

        local currentWord = table.concat(miniGameState.foundLetters, "")
        local wordComplete = table.find(words, currentWord)
        local fireSound = '5207654419'

        miniGameState.currentLetterIndex = miniGameState.currentLetterIndex + 1
        if (wordComplete) then
            local currentWord2 = Const4.wordConfigs[currentWord]
            if currentWord2 then
                local soundId = currentWord2.soundId or fireSound
                Utils.playSound(soundId)
            else
                -- Utils.playSound(fireSound)
            end

            local gemTemplate = Utils.getFromTemplates("GemTemplate")
            local newGem = gemTemplate:Clone()
            newGem.Parent = sectorFolder

            newGem.Handle.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                       {
                    parent = clickedLetter,
                    child = newGem.Handle,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(1, -1, 0),
                        useChildNearEdge = Vector3.new(-1, 1, 0),
                        offsetAdder = Vector3.new(-10, 15, 0)
                    }
                })

            newGem.Handle.Anchored = false

            local rand = Utils.genRandom(1, #Constants2.gemColors)
            newGem.Handle.Color = Constants2.gemColors[rand]

            miniGameState.activeWord = nil
            miniGameState.foundLetters = {}
            miniGameState.currentLetterIndex = 1

            if player:FindFirstChild("leaderstats") then
                local wins = player.leaderstats.Wins
                wins.Value = wins.Value + 1
            end

            PlayerStatManager:ChangeStat(player, "Gems", 1)
            Leaderboard.updateLB()

            activeWord.completed = true
            local wordLetters = Utils.getInstancesByNameStub(
                                    {
                    nameStub = "wordLetter",
                    parent = activeWord.word
                })
            for _, wordLetter in ipairs(wordLetters) do
                local firePositioners = Utils.getDescendantsByName(wordLetter,
                                                                   "FirePositioner")
                for _, firePositioner in ipairs(firePositioners) do
                    local fire = Instance.new("Fire", firePositioner)
                    fire.Size = 20
                end
            end
        end

        LetterUtils.styleLetterBlocksBD({miniGameState = miniGameState})

        local numAvailableWords = #LetterUtils.getAvailWords(miniGameState)

        local function callBack(miniGameState2)
            local function closure()
                miniGameState2.onWordLettersGone(miniGameState2)
            end

            local function wrapperForDelay()
                delay(10, closure)
                -- 
            end
            return wrapperForDelay()
        end

        if numAvailableWords == 0 then
            for _, wordObj in ipairs(miniGameState.renderedWords) do
                local wordLetters = Utils.getInstancesByNameStub(
                                        {
                        nameStub = "wordLetter",
                        parent = wordObj.word
                    })

                local function destroyParts()
                    local explosionSound = '262562442'
                    -- Utils.playSound(explosionSound, 0.5)
                    for _, wordLetter in ipairs(wordLetters) do
                        Utils.hideItemAndChildren(
                            {item = wordLetter, hide = true})
                    end
                end

                delay(1, destroyParts)
                callBack(miniGameState)
            end

            local keyWalls = Utils.getDescendantsByName(sectorFolder, "KeyWall")
            for _, keyWall in ipairs(keyWalls) do
                if keyWall then
                    LetterUtils.styleImageLabelsInBlock(keyWall,
                                                        {Visible = false})
                    keyWall.CanCollide = false
                    keyWall.Transparency = 1
                end
            end
        end
    end
    module.processing = false
end

module.onSelectRackBlock = onSelectRackBlock
return module
