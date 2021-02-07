local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local Const_Client = require(RS.Source.Constants.Constants_Client)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LevelConfigs = require(Sss.Source.LevelConfigs.LevelConfigs)

local module = {}

local function configPlayers()
    Players.RespawnTime = 0

    -- Create a RemoteEvent for when a player is added
    local newPlayerEvent = Instance.new("RemoteEvent")
    newPlayerEvent.Parent = RS
    newPlayerEvent.Name = Const_Client.RemoteEvents.NewPlayerEvent

    -- Create a RemoteEvent for when a player is added
    local updateWordGuiRE = Instance.new("RemoteEvent")
    updateWordGuiRE.Parent = RS
    updateWordGuiRE.Name = Const_Client.RemoteEvents.UpdateWordGuiRE
    print('set RE');
    print('set RE');
    print('set RE');
    print('set RE');

    local function onCharacterAdded(character)
        print('onCharacterAdded--------------------');
        character:WaitForChild("Humanoid").WalkSpeed =
            Constants.gameConfig.walkSpeed

        print('Constants.gameConfig.walkSpeed' .. ' - start');
        print(Constants.gameConfig.walkSpeed);
        print(character.Humanoid);
        local player = Players:GetPlayerFromCharacter(character)
        print(player);

        local updateWordGuiRE = RS:WaitForChild(
                                    Const_Client.RemoteEvents.UpdateWordGuiRE)

        print('FireAllClients');
        print('FireAllClients');
        print('FireAllClients');
        print('FireAllClients');
        local levelConfig = LevelConfigs.levelConfigs[1]

        updateWordGuiRE:FireAllClients({levelConfig = levelConfig})
    end

    local function onPlayerAdded(player)
        print('onPlayerAdded');
        print(player.UserId);
        player.CharacterAdded:Connect(onCharacterAdded)

        -- newPlayerEvent:FireAllClients()
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(player) end);
end

local function configGamePass()
    local gamePassID = 14078170
    local function onPlayerAdded(player)
        local hasPass = false

        -- Check if the player already owns the game pass
        local success, message = pcall(function()
            hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId,
                                                               gamePassID)
        end)

        -- If there's an error, issue a warning and exit the function
        if not success then
            warn("Error while checking if player has pass: " ..
                     tostring(message))
            return
        end

        if hasPass == true then
            print(player.Name .. " owns the game pass with ID " .. gamePassID)

            -- Assign this player the ability or bonus related to the game pass
            local function onCharacterAdded(character)
                character:WaitForChild("Humanoid").WalkSpeed = 80
                local function transport()

                    -- player.RespawnLocation = game.Workspace.Start
                    -- character.HumanoidRootPart.CFrame =
                    --     CFrame.new(Vector3.new(-245, 211, 1340))
                end

                delay(1, transport)

            end
            player.CharacterAdded:Connect(onCharacterAdded)
        end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

function configBadges()
    game:GetService('Players').PlayerAdded:Connect(
        function(player)
            player.CharacterAdded:Connect(
                function(character)
                    character:WaitForChild("Humanoid").Died:Connect(
                        function()
                            print(player.Name .. " has died!")
                        end)
                end)
        end)
end

local function setVisibility()
    local taggedPartsDestroy = CS:GetTagged("Destroy")
    for _, item in ipairs(taggedPartsDestroy) do item:Destroy() end

    local disabled = CS:GetTagged("Disable")
    for _, item in ipairs(disabled) do item.Enabled = false end

    if Constants.gameConfig.transparency then
        local taggedPartsTransparent = CS:GetTagged("Transparent")
        for _, item in ipairs(taggedPartsTransparent) do
            item.Transparency = 1
        end
    end

    local canCollideOff = CS:GetTagged("CanCollideOff")
    for _, item in ipairs(canCollideOff) do item.CanCollide = false end

    if not Constants.gameConfig.isDev then
        local tagBaseWallTransparent = CS:GetTagged("BaseWallTransparent")
        for _, wall in ipairs(tagBaseWallTransparent) do
            Utils.setItemHeight({item = wall, height = 20})
            local newWallHeight = 1
            -- wall.Transparency = 1
            wall.Transparency = 0.8
            wall.CanCollide = true
            wall.Anchored = true

            local newWall = wall:Clone()

            newWall.Parent = wall.Parent
            newWall.Size = newWall.Size +
                               Vector3.new(0, newWallHeight - newWall.Size.Y, 0)
            newWall.Position = newWall.Position +
                                   Vector3.new(0,
                                               -(wall.Size.Y - newWall.Size.Y) /
                                                   2, 0)
            newWall.Transparency = 0
            CS:RemoveTag(newWall, "BaseWallTransparent")
        end
    end

    if not Constants.gameConfig.isDev then
        local tagBaseWallTransparent = CS:GetTagged("ConveyorWallTransparent")

        local realWallHeight = 24
        local invisiWallHeight = 12

        for _, wall in ipairs(tagBaseWallTransparent) do
            Utils.setItemHeight({item = wall, height = realWallHeight})
            local newWallHeight = invisiWallHeight
            wall.Transparency = 1
            -- wall.Transparency = 0.8
            wall.CanCollide = true
            wall.Anchored = true

            local newWall = wall:Clone()

            newWall.Parent = wall.Parent
            newWall.Size = newWall.Size +
                               Vector3.new(0, newWallHeight - newWall.Size.Y, 0)
            newWall.Position = newWall.Position +
                                   Vector3.new(0,
                                               -(wall.Size.Y - newWall.Size.Y) /
                                                   2, 0)
            -- newWall.Transparency = 0
            CS:RemoveTag(newWall, "ConveyorWallTransparent")
        end
    end

    if not Constants.gameConfig.isDev then
        local tagBaseWallTransparent = CS:GetTagged("LevelWallTransparent")

        local realWallHeight = 75
        local invisiWallHeight = 50

        for _, wall in ipairs(tagBaseWallTransparent) do
            Utils.setItemHeight({item = wall, height = realWallHeight})
            local newWallHeight = invisiWallHeight
            -- wall.Transparency = 1
            wall.Transparency = 0.8
            wall.CanCollide = true
            wall.Anchored = true

            local newWall = wall:Clone()

            newWall.Parent = wall.Parent
            newWall.Size = newWall.Size +
                               Vector3.new(0, newWallHeight - newWall.Size.Y, 0)
            newWall.Position = newWall.Position +
                                   Vector3.new(0,
                                               -(wall.Size.Y - newWall.Size.Y) /
                                                   2, 0)
            -- newWall.Transparency = 0
            CS:RemoveTag(newWall, "ConveyorWallTransparent")
        end
    end

    local function configNodeWalls(walls)
        for _, wall in ipairs(walls) do
            Utils.setItemHeight({item = wall, height = 20})
            local newWallHeight = 1
            wall.Transparency = 1
            -- wall.Transparency = 0.8
            wall.CanCollide = true
            wall.Anchored = true

            local newWall = wall:Clone()

            newWall.Parent = wall.Parent
            newWall.Size = newWall.Size +
                               Vector3.new(0, newWallHeight - newWall.Size.Y, 0)
            newWall.Position = newWall.Position +
                                   Vector3.new(0,
                                               -(wall.Size.Y - newWall.Size.Y) /
                                                   2, 0)
            newWall.Transparency = 0
            -- CS:RemoveTag(newWall, "BaseWallTransparent")
        end
    end
    configNodeWalls(CS:GetTagged("NodeWall-Hex"))
    configNodeWalls(CS:GetTagged("NodeWall-Bridge-Upper"))
    configNodeWalls(CS:GetTagged("NodeWall-Bridge-Lower"))
    configNodeWalls(CS:GetTagged("PodWall"))
end

function module.configGame()
    print('configGame');
    setVisibility()
    configPlayers()
    configGamePass()
    configBadges()

    local allSpawnLocations = Utils.getDescendantsByType(workspace,
                                                         "SpawnLocation")

    for _, item in ipairs(allSpawnLocations) do
        if item.Name == Constants.gameConfig.activeSpawn then
            item.Enabled = true
        else
            item.Enabled = false
        end
    end
end

return module
