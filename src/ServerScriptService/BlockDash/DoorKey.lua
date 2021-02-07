local Sss = game:GetService("ServerScriptService")
local PlayerStatManager = require(Sss.Source.AddRemoteObjects.PlayerStatManager)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local Replicator = require(Sss.Source.BlockDash.Replicator)

local module = {}

local function initKey(miniGameState)
    local sectorFolder = miniGameState.sectorFolder

    local positioner = Utils.getFirstDescendantByName(sectorFolder,
                                                      "KeyReplicatorPositioner")
    local template = Utils.getFromTemplates("KeyReplicatorTemplate")

    local newReplicator = template:Clone()
    local key = Utils.getFirstDescendantByName(newReplicator, "Key")
    local keyName = "key--" .. sectorFolder.Name
    key.Name = keyName
    local handle = key.Handle

    local propChar = Instance.new("StringValue", handle)
    propChar.Name = "DoorMatch"
    propChar.Value = sectorFolder.Name

    newReplicator.Parent = sectorFolder
    local newReplicatorPart = newReplicator.PrimaryPart

    newReplicatorPart.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                   {
            parent = positioner,
            child = newReplicatorPart,
            offsetConfig = {
                useParentNearEdge = Vector3.new(-1, -1, -1),
                useChildNearEdge = Vector3.new(-1, -1, -1),
                offsetAdder = Vector3.new(0, 0, 0)
            }
        })

    newReplicatorPart.Anchored = true

    local function callBack(miniGameState2)
        local function closure()
            miniGameState2.onWordLettersGone(miniGameState2)
        end

        local function wrapperForDelay()
            delay(3, closure)
            -- 
        end
        return wrapperForDelay
    end

    -- Reset keybox when door is touched
    Replicator.init(newReplicator, callBack(miniGameState))

    local door = Utils.getFirstDescendantByName(sectorFolder, "LockedDoor2")
                     .PrimaryPart

    local function onTouchDoor(otherPart)
        local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local player = Utils.getPlayerFromHumanoid(humanoid)
            local gameState = PlayerStatManager.getGameState(player)
            print('gameState' .. ' - start');
            print(gameState);
            if not gameState then return end
            if not gameState.touchingDoor then
                gameState.touchingDoor = true
                local key2 = Utils.getFirstDescendantByName(player.Character,
                                                            keyName)
                if key2 then
                    door.Transparency = 0.8
                    door.CanCollide = false
                    wait(3)
                    door.Transparency = 0
                    door.CanCollide = true
                end
                gameState.touchingDoor = false
            end
        end
    end

    door.Touched:Connect(onTouchDoor)
    positioner:Destroy()
end

function module.init(miniGameState) initKey(miniGameState) end
return module

