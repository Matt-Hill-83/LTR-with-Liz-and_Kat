local Sss = game:GetService('ServerScriptService')

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LevelConfigs = require(Sss.Source.LevelConfigs.LevelConfigs)
local ConfigRemoteEvents = require(Sss.Source.AddRemoteObjects.ConfigRemoteEvents)

local BlockDash = require(Sss.Source.BlockDash.BlockDash)
local Bridge = require(Sss.Source.Bridge.Bridge)
local BeltJoint = require(Sss.Source.BeltJoint.BeltJoint)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local Door = require(Sss.Source.Door.Door)
local StatueGate = require(Sss.Source.StatueGate.StatueGate)
local Key = require(Sss.Source.Key.Key)
local Statue = require(Sss.Source.Statue.Statue)

local Entrance = require(Sss.Source.BlockDash.Entrance)
local HexJunction = require(Sss.Source.HexJunction.HexJunction)
local HexWall = require(Sss.Source.HexWall.HexWall)
local Junction = require(Sss.Source.Junction.Junction)
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local SkiSlope = require(Sss.Source.SkiSlope.SkiSlope)
local Rink = require(Sss.Source.Rink.Rink)
local Terrain = require(Sss.Source.Terrain.Terrain)
local StrayLetterBlocks = require(Sss.Source.StrayLetterBlocks.StrayLetterBlocks)

local module = {}

local function addRemoteObjects()
    ConfigRemoteEvents.configRemoteEvents()

    local myStuff = workspace:FindFirstChild('MyStuff')

    local statueProps = {
        statusDefs = {
            {sentence = {'OK', 'MOM'}, character = 'raven'},
            {
                sentence = {'NOT', 'A', 'BEE'},
                character = 'katScared',
                songId = '6342102168'
            }, --
            -- {
            --     sentence = {"TROLL", "NEED", "GOLD"},
            --     character = "babyTroll04",
            --     songId = "6338745550"
            -- }, --
            {
                sentence = {'I', 'SEE', 'A', 'BEE'},
                character = 'lizHappy'
                -- songId = "6338745550"
            }
        }
    }

    -- Statue.initStatues(statueProps)

    local blockDash = Utils.getFirstDescendantByName(myStuff, 'BlockDash')
    local levelsFolder = Utils.getFirstDescendantByName(blockDash, 'Levels')
    local levels = levelsFolder:GetChildren()
    Utils.sortListByObjectKey(levels, 'Name')

    local islandTemplate = Utils.getFromTemplates('IslandTemplate')

    Bridge.initBridges({parentFolder = myStuff})
    BeltJoint.initBeltJoints({parentFolder = myStuff})
    HexWall.initHexWalls({parentFolder = myStuff})
    Junction.initJunctions({parentFolder = myStuff})
    HexJunction.initHexJunctions({})
    SkiSlope.initSlopes({parentFolder = myStuff})
    StrayLetterBlocks.initStraysInRegions({parentFolder = workspace})
    Terrain.initTerrain({parentFolder = workspace})

    for levelIndex, level in ipairs(levels) do
        print('levelIndex' .. ' - start')
        print(levelIndex)
        -- if levelIndex == 2 then break end
        local islandPositioners = Utils.getByTagInParent({parent = level, tag = 'IslandPositioner'})

        local levelConfig = LevelConfigs.levelConfigs[levelIndex]
        local sectorConfigs = levelConfig.sectorConfigs
        local hexIslandConfigs = levelConfig.hexIslandConfigs
        Utils.sortListByObjectKey(islandPositioners, 'Name')

        local myPositioners = Constants.gameConfig.singleIsland and {islandPositioners[1]} or islandPositioners

        StatueGate.initStatueGates({parentFolder = level, configs = hexIslandConfigs})

        Entrance.initEntrance(level)

        Door.initDoors({parentFolder = myStuff})
        Key.initKeys({parentFolder = level})

        -- if false then
        if true then
            for islandIndex, islandPositioner in ipairs(myPositioners) do
                -- if islandIndex == 3 then break end
                local newIsland = islandTemplate:Clone()

                local anchoredParts = {}
                for _, child in pairs(newIsland:GetDescendants()) do
                    if child:IsA('BasePart') then
                        if child.Anchored then
                            child.Anchored = false
                            table.insert(anchoredParts, child)
                        end
                    end
                end

                newIsland.Parent = myStuff
                newIsland.Name = 'Sector-' .. islandPositioner.Name
                if sectorConfigs then
                    local sectorConfig = sectorConfigs[(islandIndex % #sectorConfigs) + 1]
                    sectorConfig.sectorFolder = newIsland
                    sectorConfig.islandPositioner = islandPositioner

                    for _, child in pairs(anchoredParts) do
                        child.Anchored = true
                    end
                    BlockDash.addBlockDash(sectorConfig)
                end
            end
        end
    end
    islandTemplate:Destroy()

    Rink.initRinks({parentFolder = workspace})
    PlayerStatManager.init()
    ConfigRemoteEvents.initRemoteEvents()
    -- Junction.initJunctions({parentFolder = myStuff})
    -- HexJunction.initHexJunctions({})
    -- Do this last after everything has been created/deleted

    ConfigGame.configGame()
end

module.addRemoteObjects = addRemoteObjects
return module
