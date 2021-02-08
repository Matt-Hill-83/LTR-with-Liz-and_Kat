local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Const_Client = require(RS.Source.Constants.Constants_Client)
local RenderWordGrid = require(Sss.Source.Utils.RenderWordGrid_S)
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local module = {}

function module.configRemoteEvents()
    -- Create a RemoteEvent for when a player is added
    local newPlayerEvent = Instance.new("RemoteEvent")
    newPlayerEvent.Parent = RS
    newPlayerEvent.Name = Const_Client.RemoteEvents.NewPlayerEvent

    -- Create a RemoteEvent for when a player is added
    local updateWordGuiRE = Instance.new("RemoteEvent")
    updateWordGuiRE.Parent = RS
    updateWordGuiRE.Name = Const_Client.RemoteEvents.UpdateWordGuiRE

    -- Create a RemoteEvent for when a player is added
    local updateGuiFromServerRE = Instance.new("RemoteEvent")
    updateGuiFromServerRE.Parent = RS
    updateGuiFromServerRE.Name = "updateGuiFromServer"
end

function module.initRemoteEvents()
    local function onCreatePartFired(player, sgui, displayHeight)
        local gameState = PlayerStatManager.getGameState(player)
        local levelConfig = gameState.levelConfig
        RenderWordGrid.renderGrid({
            sgui = sgui,
            levelConfig = levelConfig,
            displayHeight = displayHeight
        })
    end

    local updateGuiFromServerRE = RS:WaitForChild("updateGuiFromServer")
    updateGuiFromServerRE.OnServerEvent:Connect(onCreatePartFired)
end

return module
