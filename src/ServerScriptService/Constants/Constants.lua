-- local isDev = true
local isDev = false
-- 
local activeSpawn
activeSpawn = "Spawn_Slope"

local devGameConfig = {
    singleIsland = false,
    -- singleIsland = true,
    transparency = false,
    -- transparency = true,
    fastWalkSpeed = 50,
    -- walkSpeed = 30,
    walkSpeed = 80
}

local prodGameConfig = {
    singleIsland = false,
    -- singleIsland = true,
    transparency = true,
    -- walkSpeed = 30,
    walkSpeed = 80,
    fastWalkSpeed = 50
}

local gameConfig = isDev and devGameConfig or prodGameConfig

gameConfig.activeSpawn = activeSpawn
gameConfig.isDev = isDev

local module = {
    gameConfig = gameConfig, --
    walkSpeed = gameConfig.walkSpeed, --
    gameData = {letterGrabbers = {}}
}

return module
