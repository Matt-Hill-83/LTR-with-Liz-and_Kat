local Sss = game:GetService("ServerScriptService")
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
local StrayLetterBlocks =
    require(Sss.Source.StrayLetterBlocks.StrayLetterBlocks)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)

local module = {}

function module.initSlopes(props)
    local parentFolder = props.parentFolder

    local skiSlopesFolder = Utils.getFirstDescendantByName(parentFolder,
                                                           "SkiSlopes")
    local slopes = Utils.getByTagInParent(
                       {parent = skiSlopesFolder, tag = "SkiSlopeFolder"})
    for _, slope in ipairs(slopes) do

        local strayProps = {
            parentFolder = slope,
            numBlocks = 6,
            words = {"CAT"},
            region = slope.StrayRegion,
            onTouchBlock = function() end
        }

        local strayPositioners = nil

        -- local strayPositioners = Utils.getByTagInParent(
        --                              {parent = slope, tag = "StrayPositioner"})

        if strayPositioners then
            for _, positioner in ipairs(strayPositioners) do
                local char = positioner.Name
                local newLetterBlock = StrayLetterBlocks.createStray(char,
                                                                     parentFolder)
                newLetterBlock.CFrame = positioner.CFrame
                newLetterBlock.Anchored = true
                newLetterBlock.CanCollide = false
            end
        else
            StrayLetterBlocks.initStrays(strayProps)
        end

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

