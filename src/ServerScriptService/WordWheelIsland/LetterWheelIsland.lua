-- local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local HandleClick = require(Sss.Source.LetterFall.HandleClick)
-- -- local InitLetterRack = require(Sss.Source.LetterFall.InitLetterRack)
local LetterFallUtils = require(Sss.Source.LetterFall.LetterFallUtils)
local DropBox = require(Sss.Source.DropBox.DropBox)

-- local remoteEvent = RS:WaitForChild("ClickBlockRE")
local letterFallFreezeCameraRE = RS:WaitForChild("LetterFallFreezeCameraRE")

local module = {}

function configCouchTrigger(miniGameState)
    -- print('configCouchTrigger' .. ' - start');
    local letterFallFolder = miniGameState.letterFallFolder

    local seats = Utils.getDescendantsByName(letterFallFolder, "LFCouchSeat")

    for i, seat in ipairs(seats) do
        local seatTriggerEnabled = false
        local currentPlayer = nil
        function initGame()
            local cameraPath1 = Utils.getFirstDescendantByName(letterFallFolder,
                                                               "ScreenCameraPath1")
            local cameraPath2 = Utils.getFirstDescendantByName(letterFallFolder,
                                                               "ScreenCameraPath2")

            local humanoid = seat.Occupant
            if humanoid then
                local player = Utils.getPlayerFromHumanoid(humanoid)
                if player then
                    if not seatTriggerEnabled then
                        seatTriggerEnabled = true
                    end
                    currentPlayer = player
                    letterFallFreezeCameraRE:FireClient(player, cameraPath1,
                                                        cameraPath2, true)
                    return
                end
            end

            -- player leaves seat
            if currentPlayer then
                letterFallFreezeCameraRE:FireClient(currentPlayer, cameraPath1,
                                                    cameraPath2, false)
                currentPlayer = nil
            end
        end

        function initGameWrapper(miniGameState)
            -- This is a good example of a closure.  Let the :Connect definition
            -- run the wrapper to
            -- capture the current state of the miniGameState.  But don't run
            -- initGame until the :Connect actually fires
            return initGame
        end

        seat:GetPropertyChangedSignal("Occupant"):Connect(
            initGameWrapper(miniGameState))
    end
end

function initGameToggle(miniGameState)
    local letterFallFolder = miniGameState.letterFallFolder
    local startGameTrigger = Utils.getFirstDescendantByName(letterFallFolder,
                                                            "StartGameTrigger")

    function onCorrectItemDropped()
        local manHoleCover = Utils.getFirstDescendantByName(letterFallFolder,
                                                            "ManHoleCover")
        if manHoleCover then manHoleCover:Destroy() end
    end

    local dropBox = Utils.getFirstDescendantByName(letterFallFolder,
                                                   "DropBoxModel")
    local dropBoxItem = {name = "GemTemplate"}
    DropBox.configDropBox({
        scene = letterFallFolder,
        sceneIndex = 0,
        dropBox = dropBox,
        onCorrectItemDropped = onCorrectItemDropped,
        item = dropBoxItem

    })

    function onPartTouched(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not miniGameState.initCompleted then
                miniGameState.initCompleted = true
                HandleClick.initClickHandler(miniGameState)
                LetterFallUtils.createBalls(miniGameState)
                configCouchTrigger(miniGameState)
            end
        end
    end

    -- Do this so that all letterFall in all scenes are not jiggling and looking
    -- for clicks until they are needed
    startGameTrigger.Touched:Connect(onPartTouched)
end

module.initGameToggle = initGameToggle
return module
