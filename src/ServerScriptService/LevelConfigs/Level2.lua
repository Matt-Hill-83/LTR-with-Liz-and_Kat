local module = {}
local sectorConfigs = {
    {
        words = {
            "MOM", --
            "MOM", --
            "MOM" --
        }
    }, {
        freezeConveyor = true,
        words = {
            "DAD", --
            "DAD", --
            "DAD" --
        }
    }, {
        words = {
            "POP", --
            "POP", --
            "POP" --
        }
    }, {
        words = {
            "TOT", --
            "TOT", --
            "TOT" --
        }
    }, {
        words = {
            "BOB", --
            "BOB", --
            "BOB" --
        }
    }, {
        words = {
            "MOM", --
            "MOM", --
            "MOM" --
        }
    }, {
        words = {
            "PUP", --
            "PUP", --
            "PUP" --
        }
    }

}

local sector2Config = {
    {
        words = {
            -- "NAP", --
            -- "TAP", --
            -- "RAP", --
            -- "ZAP", --
            -- "CAP", --
            -- "GAP", --
            -- "LAP", --
            -- "MAP", --
            -- "VAN", --
            -- "RAN", --
            -- "CAN", --
            "SAT", --
            "RAT", --
            "CAT", --
            "HAT", --
            "MAT", --
            "PAT", --
            "VAT" --
        }
    }
}

module.sectorConfigs = sector2Config
-- module.sectorConfig = sectorConfigs

return module
