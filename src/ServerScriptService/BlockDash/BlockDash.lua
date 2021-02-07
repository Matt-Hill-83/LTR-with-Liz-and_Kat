local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
-- local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local InitLetterRack = require(Sss.Source.BlockDash.InitLetterRackBD)
local InitWord = require(Sss.Source.BlockDash.InitWordBD)
local Entrance = require(Sss.Source.BlockDash.Entrance)
local HandleClick = require(Sss.Source.BlockDash.HandleClick)
-- local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
-- local DoorKey = require(Sss.Source.BlockDash.DoorKey)
local Conveyor = require(Sss.Source.Conveyor.Conveyor)

local module = {}

local function initPowerUps(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    local function onTouchAddBlocks(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if not miniGameState.canResetBlocks then
                miniGameState.canResetBlocks = true
                InitLetterRack.initLetterRack(miniGameState)
            end
        end
    end

    local addBlocks = Utils.getDescendantsByName(sectorFolder, "AddBlocks")
    for _, reset in ipairs(addBlocks) do
        reset.Touched:Connect(onTouchAddBlocks)
    end
end

local function addBlockDash(sectorConfig)
    -- local words = {sectorConfig.words[1]}
    local words = sectorConfig.words

    local sectorFolder = sectorConfig.sectorFolder
    local rackLetterSize = 8
    local islandPositioner = sectorConfig.islandPositioner

    local numRow = math.floor(islandPositioner.Size.Z / rackLetterSize)
    local totalCol = math.floor(islandPositioner.Size.X / rackLetterSize)

    -- TODO: throw this as an error
    -- conveyor length must be a multiple of num_blocks_per_belt_plate and blockSize
    local numBlocksPerBeltPlate = 4
    local numBelts = totalCol / numBlocksPerBeltPlate

    local miniGameState = {
        activeStyle = "BD_available",
        activeWord = nil,
        activeWordIndex = 1,
        availLetters = {},
        availWords = {},
        beltPlateCFrames = {},
        beltPlates = {},
        beltPlateSpacing = 2,
        canResetBlocks = true,
        conveyorPadding = 1,
        currentLetterIndex = 1,
        foundLetters = {},
        -- inActiveStyle = "BD_Pink", -- Rack starts with this one:
        inActiveStyle = "BD_not_available", -- Rack starts with this one:
        initCompleted = false,
        islandPositioner = islandPositioner,
        sectorConfig = sectorConfig,
        letterSpacingFactor = 1.05,
        numBelts = numBelts,
        numCol = numBlocksPerBeltPlate,
        numRow = numRow,
        rackLetterBlockObjs = {},
        rackLetterSize = rackLetterSize,
        renderedWords = {},
        sectorFolder = sectorFolder,
        wordLetterSize = 16,
        wordsPerCol = 2
    }
    miniGameState.words = words

    local myStuff = workspace:FindFirstChild("MyStuff")
    miniGameState.onSelectRackBlock = HandleClick.onSelectRackBlock
    local letterFallFolder =
        Utils.getFirstDescendantByName(myStuff, "BlockDash")
    miniGameState.letterFallFolder = letterFallFolder

    local function onWordLettersGone(miniGameState2)
        LetterUtils.revertRackLetterBlocksToInit(miniGameState2)
        LetterUtils.styleLetterBlocksBD({miniGameState = miniGameState2})

        -- TODO: put this in DoorKey
        -- TODO: put this in DoorKey
        -- TODO: put this in DoorKey
        -- TODO: put this in DoorKey

        local keyWalls = Utils.getDescendantsByName(sectorFolder, "KeyWall")

        for _, keyWall in ipairs(keyWalls) do
            if keyWall then
                LetterUtils.styleImageLabelsInBlock(keyWall, {Visible = true})
                keyWall.CanCollide = true
                keyWall.Transparency = 0.7
            end
        end
    end

    miniGameState.onWordLettersGone = onWordLettersGone
    -- Do some acrobatics here because InitLetterRack needs to attach
    -- itself as an event to the blocks it creates.

    Entrance.initEntrance(sectorFolder)
    Conveyor.initConveyors(miniGameState)
    InitLetterRack.initLetterRack(miniGameState)
    InitWord.initWords(miniGameState)

    LetterUtils.styleLetterBlocksBD({miniGameState = miniGameState})
    initPowerUps(miniGameState)
    -- DoorKey.init(miniGameState)
    -- LetterGrabber.initLetterGrabbers(miniGameState)
end

module.addBlockDash = addBlockDash
return module
