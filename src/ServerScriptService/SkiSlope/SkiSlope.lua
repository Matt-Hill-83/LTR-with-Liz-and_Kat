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

        -- local useStrayPositioners = false
        local useStrayPositioners = true

        if useStrayPositioners then
            local strayPositioners = Utils.getByTagInParent(
                                         {
                    parent = slope,
                    tag = "StrayPositioner"
                })
            for _, positioner in ipairs(strayPositioners) do
                local char = positioner.Name
                local newLetterBlock = StrayLetterBlocks.createStray(char,
                                                                     parentFolder)
                newLetterBlock.CFrame = positioner.CFrame
                newLetterBlock.Anchored = true
                newLetterBlock.CanCollide = false
                newLetterBlock.Size = Vector3.new(8, 8, 8)
            end
        else
            StrayLetterBlocks.initStrays(
                {
                    parentFolder = slope,
                    numBlocks = 6,
                    words = {"CAT"},
                    region = slope.StrayRegion,
                    onTouchBlock = function() end
                })
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

