local Sss = game:GetService('ServerScriptService')
local Colors = require(Sss.Source.Constants.Const_02_Colors)

local module = {}

local sector1Config = {
    freezeConveyor = true,
    words = {
        'NAP', --
        'TAP', --
        'RAP', --
        'ZAP' --
    }
}

local sector2Config = {
    words = {
        'CAP', --
        'GAP', --
        'LAP', --
        'MAP' --
    }
}

local sector3Config = {
    words = {
        'VAN', --
        'RAN', --
        'CAN', --
        'AN' --
    }
}

local sector4Config = {
    words = {
        'PAN', --
        'DAN', --
        'FAN', --
        'TAN', --
        'JAN' --
    }
}
local sector5Config = {
    words = {
        'SAT', --
        'RAT', --
        'VAT', --
        'AT' --
    }
}

local sector6Config = {
    words = {
        'CAT', --
        'HAT', --
        'MAT', --
        'PAT' --
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

local hexIslandConfigs = {
    {
        hexNum = 1
    },
    {
        hexNum = 2,
        statueConfigs = {
            Liz = {
                sentence = {'I', 'SEE', 'A', 'BEE'},
                character = 'lizHappy',
                songId = '6342102168',
                keyColor = Colors.colors.yellow
            }
        }
    }
}

-- Kat = {
--     sentence = {'NOT', 'A', 'BEE'},
--     character = 'katScared',
--     songId = '6342102168'
-- },
-- Troll = {
--     sentence = {'TROLL', 'NEED', 'GOLD'},
--     character = 'babyTroll04'
--     -- songId = '6338745550'
-- },

module.sectorConfigs = sectorConfigs
module.hexIslandConfigs = hexIslandConfigs

module.targetWords = {
    {word = 'RAT', target = 4, found = 0}, --
    {word = 'CAT', target = 4, found = 0}, --
    {word = 'BAT', target = 4, found = 0}, --
    {word = 'HAT', target = 4, found = 0} --
}

return module
