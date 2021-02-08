local Sss = game:GetService("ServerScriptService")
local LetterGrabber = require(Sss.Source.LetterGrabber.LetterGrabber)
local StrayLetterBlocks =
    require(Sss.Source.StrayLetterBlocks.StrayLetterBlocks)

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)

local module = {}

function module.initSlopes(props)
    local parentFolder = props.parentFolder

    local skiSlopesFolder = Utils.getFirstDescendantByName(parentFolder,
                                                           "SkiSlopes")
    local slopes = Utils.getByTagInParent(
                       {parent = skiSlopesFolder, tag = "SkiSlopeFolder"})
    for _, slope in ipairs(slopes) do

        -- populate specific letter gems
        local strayPositioners = Utils.getByTagInParent(
                                     {parent = slope, tag = "StrayPositioner"})
        for _, positioner in ipairs(strayPositioners) do
            local char = positioner.Name
            local newLetterBlock = StrayLetterBlocks.createStray(char,
                                                                 parentFolder)

            newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                        {
                    parent = positioner,
                    child = newLetterBlock,
                    offsetConfig = {
                        useParentNearEdge = Vector3.new(0, -1, 0),
                        useChildNearEdge = Vector3.new(0, -1, 0),
                        offsetAdder = nil
                    }
                })

            newLetterBlock.Anchored = true
            newLetterBlock.CanCollide = false
        end

        -- Populate random letter gems
        local strays = StrayLetterBlocks.initStraysInRegion(
                           {
                parentFolder = slope,
                numBlocks = 6,
                words = {"CAT"},
                region = slope.StrayRegion,
                onTouchBlock = function() end
            })

        for _, stray in ipairs(strays) do stray.CanCollide = true end

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

