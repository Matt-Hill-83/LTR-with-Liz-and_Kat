local Sss = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
-- local freezeCameraRE = RS:WaitForChild("BlockDashFreezeCameraRE")

local module = {}

function module.initEntrance(parent)

    -- local function onTouchEntrance(otherPart)
    --     local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
    --     if humanoid then
    --         local player = Utils.getPlayerFromHumanoid(humanoid)
    --         local gameState = PlayerStatManager.getGameState(player)

    --         if not gameState.orbitalView then
    --             gameState.orbitalView = true
    --             freezeCameraRE:FireClient(player, true)
    --             humanoid.JumpPower = 70
    --         end
    --     end
    -- end

    -- local entrances = Utils.getDescendantsByName(parent, "Entrance")
    -- for _, item in ipairs(entrances) do item.Touched:Connect(onTouchEntrance) end

    -- local function onTouchExit(otherPart)
    --     local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
    --     if humanoid then
    --         local player = Utils.getPlayerFromHumanoid(humanoid)
    --         local gameState = PlayerStatManager.getGameState(player)

    --         if gameState.orbitalView then
    --             gameState.orbitalView = false
    --             freezeCameraRE:FireClient(player, false)
    --             humanoid.JumpPower = 50
    --         end
    --     end
    -- end

    -- local exits = Utils.getDescendantsByName(parent, "Exit")
    -- for _, item in ipairs(exits) do item.Touched:Connect(onTouchExit) end

    -- 
    -- 
    -- 
    local function onTouchRun30(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed == 30 then return end
            humanoid.WalkSpeed = 30
        end
    end

    local run30s = Utils.getDescendantsByName(parent, "Run30")
    for _, item in ipairs(run30s) do item.Touched:Connect(onTouchRun30) end

    local function onTouchRun50(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed == 50 then return end
            humanoid.WalkSpeed = 50
        end
    end

    local run50s = Utils.getDescendantsByName(parent, "Run50")
    for _, item in ipairs(run50s) do item.Touched:Connect(onTouchRun50) end

    local function onTouchRun70(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed == 70 then return end
            humanoid.WalkSpeed = 70
        end
    end

    local run70s = Utils.getDescendantsByName(parent, "Run70")
    for _, item in ipairs(run70s) do item.Touched:Connect(onTouchRun70) end

    local function onTouchRun90(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            if humanoid.WalkSpeed == 90 then return end
            humanoid.WalkSpeed = 90
        end
    end

    local run90s = Utils.getDescendantsByName(parent, "Run90")
    for _, item in ipairs(run90s) do item.Touched:Connect(onTouchRun90) end
end

return module

