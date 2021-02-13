local Sss = game:GetService("ServerScriptService")

local Const4 = require(Sss.Source.Constants.Const_04_Characters)
local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function styleGems(items)

    for _, block in ipairs(items) do
        LetterUtils.applyStyleFromTemplate(
            {targetLetterBlock = block, templateName = "Grabber_normal"})
    end

    for _, block in ipairs(items) do
        if block.IsFound.Value == true then
            LetterUtils.applyStyleFromTemplate(
                {targetLetterBlock = block, templateName = "Grabber_found"})
        end

    end
end

local function wordFound(tool, touchedBlock)
    touchedBlock.IsFound.Value = true

    LetterUtils.applyStyleFromTemplate({
        targetLetterBlock = touchedBlock,
        templateName = "Stray_available"
    })

    local targetWord = touchedBlock.Character.Value

    local function destroyParts()
        local explosionSound = '515938718'
        Utils.playSound(explosionSound, 0.5)

        local fireSound = '5207654419'
        local currentWord2 = Const4.wordConfigs[targetWord]
        if currentWord2 then
            local soundId = currentWord2.soundId or fireSound
            Utils.playSound(soundId)
        end

        tool:Destroy()
    end
    delay(2, destroyParts)
end

local function partTouched(touchedBlock, player)
    local tool = Utils.getActiveToolByToolType(player, "LetterGemTool")
    if not tool then return end
    if touchedBlock.IsFound.Value == true then return end
    local match = touchedBlock.Character.Value == tool.Handle.KeyName.Value

    if match then
        module.wordFound(tool, touchedBlock)
        -- 
    end

    -- module.styleLetterGrabberBlocks(tool)

end

module.partTouched = partTouched
module.wordFound = wordFound
module.styleGems = styleGems
return module
