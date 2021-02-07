local CS = game:GetService("CollectionService")
local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function getSortedBlocks(tool2)
    local letterBlocks = Utils.getByTagInParent(
                             {parent = tool2, tag = "WordGrabberLetter"})
    Utils.sortListByObjectKey(letterBlocks, "Name")
    return letterBlocks
end

local function getActiveLetterGrabberBlock(tool)
    local letterBlocks = getSortedBlocks(tool)
    local activeBlock = nil

    for _, block in ipairs(letterBlocks) do
        block.IsActive.Value = false
        --  
    end

    for _, block in ipairs(letterBlocks) do
        if block.IsFound.Value == false then
            activeBlock = block
            block.IsActive.Value = true
            break
        end
    end
    return activeBlock
end

local function styleLetterGrabberBlocks(tool)
    local letterBlocks = getSortedBlocks(tool)

    for _, block in ipairs(letterBlocks) do
        if block.IsFound.Value == true then
            LetterUtils.applyStyleFromTemplate(
                {targetLetterBlock = block, templateName = "Grabber_found"})
        end

        if block.IsActive.Value == true then
            LetterUtils.applyStyleFromTemplate(
                {targetLetterBlock = block, templateName = "Grabber_active"})
        end
    end
end

module.getActiveLetterGrabberBlock = getActiveLetterGrabberBlock
module.styleLetterGrabberBlocks = styleLetterGrabberBlocks
return module
