local module = {}
local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Const_Client = require(RS.Source.Constants.Constants_Client)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LevelConfigs = require(Sss.Source.LevelConfigs.LevelConfigs)
local initStatues = require(Sss.Source.WordWheelIsland.InitStatues)

local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)
local ConfigGame = require(Sss.Source.AddRemoteObjects.ConfigGame)
local BlockDash = require(Sss.Source.BlockDash.BlockDash)
local Entrance = require(Sss.Source.BlockDash.Entrance)
local SkiSlope = require(Sss.Source.SkiSlope.SkiSlope)

local RenderWordGrid = require(RS.Source.WordGui.RenderWordGrid)

-- Create a RemoteEvent for when a player is added
local updateWordGuiRE = Instance.new("RemoteEvent")
updateWordGuiRE.Parent = RS
updateWordGuiRE.Name = Const_Client.RemoteEvents.UpdateWordGuiRE

local function addRemoteObjects()
    local myStuff = workspace:FindFirstChild("MyStuff")

    local statueProps = {
        statusDefs = {
            {sentence = {"OK", "MOM"}, character = "raven"}, {
                sentence = {"NOT", "A", "CAT"},
                character = "katScared",
                songId = "6342102168"
            }, --
            {
                sentence = {"TROLL", "NEED", "GOLD"},
                character = "babyTroll04",
                songId = "6338745550"
            }, --
            {
                sentence = {"I", "SEE", "A", "BEE"},
                character = "lizHappy"
                -- songId = "6338745550"
            }
        }
    }

    initStatues.initStatues(statueProps)

    local blockDash = Utils.getFirstDescendantByName(myStuff, "BlockDash")
    local levelsFolder = Utils.getFirstDescendantByName(blockDash, "Levels")
    local levels = levelsFolder:GetChildren()
    Utils.sortListByObjectKey(levels, "Name")

    SkiSlope.initSlopes({parentFolder = myStuff})

    local islandTemplate = Utils.getFromTemplates("IslandTemplate")

    for levelIndex, level in ipairs(levels) do
        -- if levelIndex == 2 then break end

        local islandPositioners = Utils.getByTagInParent(
                                      {parent = level, tag = "IslandPositioner"})

        local levelConfig = LevelConfigs.levelConfigs[levelIndex]
        local sectorConfigs = levelConfig.sectorConfigs
        Utils.sortListByObjectKey(islandPositioners, "Name")

        local myPositioners = Constants.gameConfig.singleIsland and
                                  {islandPositioners[1]} or islandPositioners

        Entrance.initEntrance(level)

        if true then
            for islandIndex, islandPositioner in ipairs(myPositioners) do
                -- if islandIndex == 3 then break end
                local newIsland = islandTemplate:Clone()

                local anchoredParts = {}
                for _, child in pairs(newIsland:GetDescendants()) do
                    if child:IsA("BasePart") then
                        if child.Anchored then
                            child.Anchored = false
                            table.insert(anchoredParts, child)
                        end
                    end
                end

                newIsland.Parent = myStuff
                newIsland.Name = "Sector-" .. islandPositioner.Name
                if sectorConfigs then
                    local sectorConfig =
                        sectorConfigs[(islandIndex % #sectorConfigs) + 1]
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
    -- Do this last after everything has been created/deleted
    ConfigGame.configGame()
    PlayerStatManager.init()

    islandTemplate:Destroy()
    local updateWordGuiRE = RS:WaitForChild(
                                Const_Client.RemoteEvents.UpdateWordGuiRE)

end

module.addRemoteObjects = addRemoteObjects
return module

