-- Set up table to return to any script that requires this module script
local PlayerStatManager = {}

local DataStoreService = game:GetService("DataStoreService")
local playerData = DataStoreService:GetDataStore("PlayerData2")

-- Table to hold player information for the current session
local sessionData = {}
local gameState = {}
local nameStub = "Player_"
local AUTOSAVE_INTERVAL = 60

-- Function that other scripts can call to change a player's stats
function PlayerStatManager:ChangeStat(player, statName, value)
    local playerUserId = nameStub .. player.UserId
    if not sessionData[playerUserId] then return end

    assert(typeof(sessionData[playerUserId][statName]) == typeof(value),
           "ChangeStat error: types do not match")
    if typeof(sessionData[playerUserId][statName]) == "number" then
        sessionData[playerUserId][statName] =
            sessionData[playerUserId][statName] + value
    else
        sessionData[playerUserId][statName] = value
    end
end

-- Function that other scripts can call to change a player's stats
function PlayerStatManager:ChangeGameState(player, statName, value)
    local playerUserId = nameStub .. player.UserId
    assert(typeof(sessionData[playerUserId][statName]) == typeof(value),
           "ChangeStat error: types do not match")
    if typeof(sessionData[playerUserId][statName]) == "number" then
        sessionData[playerUserId][statName] =
            sessionData[playerUserId][statName] + value
    else
        sessionData[playerUserId][statName] = value
    end
end

-- Function to add player to the "sessionData" table
local function setupPlayerData(player)
    local playerUserId = nameStub .. player.UserId
    gameState[playerUserId] = {runFast = false, orbitalView = false}

    local success, data = pcall(function()
        return playerData:GetAsync(playerUserId)
    end)
    if success then
        if data then
            -- Data exists for this player
            sessionData[playerUserId] = data
        else
            -- Data store is working, but no current data for this player
            sessionData[playerUserId] = {Money = 0, Experience = 0, Gems = 0}
        end
    else
        warn("Cannot access data store for player!")
    end
end

-- Function to save player's data
local function savePlayerData(playerUserId)
    print('savePlayerData');
    if sessionData[playerUserId] then
        local tries = 0
        local success
        repeat
            tries = tries + 1
            success = pcall(function()
                playerData:SetAsync(playerUserId, sessionData[playerUserId])
            end)
            if not success then wait(1) end
        until tries == 3 or success
        if not success then warn("Cannot save data for player!") end
    end
end

-- Function to save player data on exit
local function saveOnExit(player)
    local playerUserId = nameStub .. player.UserId
    savePlayerData(playerUserId)
end

-- Function to periodically save player data
local function autoSave()
    while wait(AUTOSAVE_INTERVAL) do
        for playerUserId, data in pairs(sessionData) do
            savePlayerData(playerUserId)
        end
    end
end

local function getSessionData(player)
    return sessionData[nameStub .. player.UserId]
end

local function getGameState(player) return gameState[nameStub .. player.UserId] end

local function init(player)
    -- Start running "autoSave()" function in the background
    spawn(autoSave)

    -- Connect "setupPlayerData()" function to "PlayerAdded" event
    game.Players.PlayerAdded:Connect(setupPlayerData)

    -- Connect "saveOnExit()" function to "PlayerRemoving" event
    game.Players.PlayerRemoving:Connect(saveOnExit)

end

PlayerStatManager.init = init
PlayerStatManager.getSessionData = getSessionData
PlayerStatManager.getGameState = getGameState

return PlayerStatManager
