local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Constants = require(Sss.Source.Constants.Constants)
local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

function getActiveLetter(miniGameState)
    local alp = miniGameState.activeLetterPosition
    local letterObjs = miniGameState.rackLetterBlockObjs

    local foundLetter = nil
    for _, obj in ipairs(letterObjs) do
        if obj.coords.row == alp.row and obj.coords.col == alp.col then
            foundLetter = obj
            break
        end
    end

    return foundLetter
end

function module.initArrowTool(miniGameState)
    local letterFallFolder = miniGameState.letterFallFolder

    function styleActiveLetter(props)
        local active = props.active
        local activeLetter = getActiveLetter(miniGameState)
        local letterPart = activeLetter.part

        local direction = active and -1 or 1
        local incrementY = 0.95 * letterPart.Size.Y * direction

        letterPart.CFrame = letterPart.CFrame + Vector3.new(0, incrementY, 0)
        LetterUtils.applyStyleFromTemplateBD(
            {
                targetLetterBlock = letterPart,
                templateName = active and miniGameState.activeStyle or
                    miniGameState.inActiveStyle
            })
    end

    function updateBlock(props)
        local position = props.position
        local alp = miniGameState.activeLetterPosition

        function funcNorth()
            if alp.col < miniGameState.numCol then
                alp.col = alp.col + 1
            end
        end

        function funcSouth()
            if alp.col > 1 then alp.col = alp.col - 1 end
        end

        function funcEast()
            if alp.row < miniGameState.numRow then
                alp.row = alp.row + 1
            end
        end

        function funcWest() if alp.row > 1 then alp.row = alp.row - 1 end end

        local dict = {
            north = funcNorth,
            south = funcSouth,
            east = funcEast,
            west = funcWest
        }

        styleActiveLetter({active = true})
        local func = dict[position]()
        styleActiveLetter({active = false})
    end

    function moveLetterEastArrow() updateBlock({position = "east"}) end

    function moveLetterWestArrow() updateBlock({position = "west"}) end

    function moveLetterNorthArrow() updateBlock({position = "north"}) end

    function moveLetterSouthArrow() updateBlock({position = "south"}) end

    local cdRight = Utils.getFirstDescendantByName(letterFallFolder,
                                                   "ArrowRightClickDetector")
    cdRight.MouseClick:Connect(moveLetterEastArrow)
    -- cdRight.MouseClick:Connect(function() updateBlock({position = "east"}) end)

    local cdUp = Utils.getFirstDescendantByName(letterFallFolder,
                                                "ArrowUpClickDetector")
    cdUp.MouseClick:Connect(moveLetterNorthArrow)

    local cdLeft = Utils.getFirstDescendantByName(letterFallFolder,
                                                  "ArrowLeftClickDetector")
    cdLeft.MouseClick:Connect(moveLetterWestArrow)

    local cdDown = Utils.getFirstDescendantByName(letterFallFolder,
                                                  "ArrowDownClickDetector")
    cdDown.MouseClick:Connect(moveLetterSouthArrow)

end

return module

