local RS = game:GetService("ReplicatedStorage")
local PlayerGui = game:GetService('Players').LocalPlayer:WaitForChild(
                      'PlayerGui')
local Const_Client = require(RS.Source.Constants.Constants_Client)

local updateWordGuiRE = RS:WaitForChild(Const_Client.RemoteEvents
                                            .UpdateWordGuiRE)
local updateGuiFromServerRE = RS:WaitForChild("updateGuiFromServer")

-- To update the gui, a client event is fired.
-- Then the client fires a server event and passes the display height, so that
-- the server can update the gui, and use all the server utilities

local function onUpdateWordGuiRE(props)
    props.sgui = PlayerGui
    local mainGui = props.sgui:WaitForChild("MainGui")
    local displayHeight = mainGui.AbsoluteSize.Y
    updateGuiFromServerRE:FireServer(mainGui, displayHeight)
end

updateWordGuiRE.OnClientEvent:Connect(onUpdateWordGuiRE)
