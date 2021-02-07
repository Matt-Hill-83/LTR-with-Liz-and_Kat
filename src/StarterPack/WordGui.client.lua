local RS = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService('Players').LocalPlayer:WaitForChild(
                      'PlayerGui')
local Const_Client = require(RS.Source.Constants.Constants_Client)

-- local RenderWordGrid = require(RS.Source.WordGui.RenderWordGrid)

local updateWordGuiRE = RS:WaitForChild(Const_Client.RemoteEvents
                                            .UpdateWordGuiRE)
local testCallbackRE = RS:WaitForChild("TestCallback")

local function onUpdateWordGuiRE(props)
    print('props' .. ' - start');
    print(props);
    props.sgui = PlayerGui
    local mainGui = props.sgui:WaitForChild("MainGui")
    local displayHeight = mainGui.AbsoluteSize.Y
    print('displayHeight' .. ' - start');
    print(displayHeight);
    -- RenderWordGrid.renderGrid(props)
    testCallbackRE:FireServer(mainGui, displayHeight)
end

updateWordGuiRE.OnClientEvent:Connect(onUpdateWordGuiRE)
