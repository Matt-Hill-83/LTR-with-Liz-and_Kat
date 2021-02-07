local Sss = game:GetService("ServerScriptService")
local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local DataStoreService = game:GetService("DataStoreService")
local WinsLeaderboard = DataStoreService:GetOrderedDataStore("WinsLeaderboard")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local module = {}

local function updateLeaderboard(player)
    local success, errorMessage = pcall(function()
        local globalLeaderboards = Utils.getDescendantsByName(workspace,
                                                              "GlobalLeaderboard")

        for _, globalLeaderboard in ipairs(globalLeaderboards) do
            for _, frame in pairs(
                                globalLeaderboard.LeaderboardGUI.Holder:GetChildren()) do
                frame:Destroy()
            end
        end

        local Data = WinsLeaderboard:GetSortedAsync(false, 5)
        local WinsPage = Data:GetCurrentPage()
        for Rank, data in ipairs(WinsPage) do
            local userName = game.Players:GetNameFromUserIdAsync(
                                 tonumber(data.key))
            local Name = userName
            local Wins = data.value
            local isOnLeaderboard = false

            for _, globalLeaderboard in ipairs(globalLeaderboards) do

                for i, v in pairs(
                                globalLeaderboard.LeaderboardGUI.Holder:GetChildren()) do
                    if v.Player.Text == Name then
                        isOnLeaderboard = true
                        break
                    end
                end
                local gems2 = PlayerStatManager.getSessionData(player).Gems
                -- print('gems2' .. ' - start');
                -- print(gems2);
                if Wins and isOnLeaderboard == false then
                    local newLbFrame = game.ReplicatedStorage:WaitForChild(
                                           "LeaderboardFrame"):Clone()
                    newLbFrame.Player.Text = Name
                    -- newLbFrame.Wins.Text = gems2
                    newLbFrame.Wins.Text = Wins
                    newLbFrame.Rank.Text = "#" .. Rank
                    newLbFrame.Position =
                        UDim2.new(0, 0, newLbFrame.Position.Y.Scale +
                                      (.08 *
                                          #globalLeaderboard.LeaderboardGUI
                                              .Holder:GetChildren()), 0)
                    newLbFrame.Parent = globalLeaderboard.LeaderboardGUI.Holder
                end
            end
        end
    end)
    if not success then print(errorMessage) end
end

function updateLB()
    for _, player in pairs(game.Players:GetPlayers()) do
        WinsLeaderboard:SetAsync(player.UserId, player.leaderstats.Wins.Value)
    end
    updateLeaderboard(player)
end

module.updateLB = updateLB
return module
