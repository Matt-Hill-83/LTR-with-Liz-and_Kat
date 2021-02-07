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

local sectorConfig1 = {
    sector1Config, --
    sector2Config, --
    sector3Config, --
    sector4Config, --
    sector5Config, --
    sector6Config --
}

module.sectorConfigs = sectorConfig1
module.targetWords = {
    "RAT", --
    "CAT", --
    "BAT", --
    "HAT" --
}

return module
