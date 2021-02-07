local Sss = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
local StrayLetterBlocks =
    require(Sss.Source.StrayLetterBlocks.StrayLetterBlocks)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
local Const4 = require(Sss.Source.Constants.Const_04_Characters)

local module = {}

function module.initSlopes(props)
    local parentFolder = props.parentFolder

    local skiSlopesFolder = Utils.getFirstDescendantByName(parentFolder,
                                                           "SkiSlopes")
    local slopes = Utils.getByTagInParent(
                       {parent = skiSlopesFolder, tag = "SkiSlopeFolder"})
    for _, slope in ipairs(slopes) do

        local strayLetterBlockObjs = {}

        local strayProps = {
            parentFolder = slope,
            numBlocks = 100,
            words = {
                "CAT", "CAT", "CAT", "CAT", "CAT", "CAT", "CAT", "CAT", "CAT",
                "CAT"
            },
            blocks = {},
            region = slope.StrayRegion,
            onTouchBlock = function()
                -- 
            end,
            strayLetterBlockObjs = strayLetterBlockObjs

        }
        local strays = StrayLetterBlocks.initStrays(strayProps)

        local positioners = Utils.getDescendantsByName(slope,
                                                       "LetterGrabberPositioner")

        for _, positioner in ipairs(positioners) do
            local grabbersConfig = {
                word = "CAT",
                parentFolder = slope,
                positioner = positioner
            }

            LetterGrabber.initLetterGrabber(grabbersConfig)
        end
    end
end

return module

