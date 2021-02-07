local RS = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService('Players').LocalPlayer:WaitForChild(
                      'PlayerGui')
local Const_Client = require(RS.Source.Constants.Constants_Client)

local RenderWordGrid = require(RS.Source.WordGui.RenderWordGrid)
local Utils = require(RS.Source.Utils.RSU001GeneralUtils)

local updateWordGuiRE = RS:WaitForChild(Const_Client.RemoteEvents
                                            .UpdateWordGuiRE)
print('initWordGui' .. ' - start');

local function onUpdateWordGuiRE(props)
    print('PlayerGui' .. ' - start');
    print(PlayerGui);
    props.sgui = PlayerGui
    RenderWordGrid.renderGrid(props)
end

updateWordGuiRE.OnClientEvent:Connect(onUpdateWordGuiRE)
