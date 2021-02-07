local module = {}

local sector1Config = {
    freezeConveyor = true,
    words = {
        "NAP", --
        "TAP", --
        "RAP", --
        "ZAP" --
    }
}

local sector2Config = {
    words = {
        "CAP", --
        "GAP", --
        "LAP", --
        "MAP" --
    }
}

local sector3Config = {
    words = {
        "VAN", --
        "RAN", --
        "CAN", --
        "AN" --
    }
}

local sector4Config = {
    words = {
        "PAN", --
        "DAN", --
        "FAN", --
        "TAN", --
        "JAN" --
    }
}
local sector5Config = {
    words = {
        "SAT", --
        "RAT", --
        "VAT", --
        "AT" --

    }
}

local sector6Config = {
    words = {
        "CAT", --
        "HAT", --
        "MAT", --
        "PAT" --
    }
}

local sectorConfigs = {
    sector1Config, --
    sector2Config, --
    sector3Config, --
    sector4Config, --
    sector5Config, --
    sector6Config --
}

module.sectorConfigs = sectorConfigs

module.targetWords = {
    {word = "RAT", target = 4, found = 0}, --
    {word = "CAT", target = 4, found = 0}, --
    {word = "BAT", target = 4, found = 0}, --
    {word = "HAT", target = 4, found = 0} --
}

return module
