local Sss = game:GetService("ServerScriptService")

local Utils = require(Sss.Source.Utils.U001GeneralUtils)
local Utils3 = require(Sss.Source.Utils.U003PartsUtils)
-- local Constants = require(Sss.Source.Constants.Constants)

local LetterUtils = require(Sss.Source.Utils.U004LetterUtils)

local module = {}

local function initLetterRack(miniGameState)
    local rackLetterBlockObjs = miniGameState.rackLetterBlockObjs
    local sectorFolder = miniGameState.sectorFolder
    local numRow = miniGameState.numRow
    local numCol = miniGameState.numCol
    local words = miniGameState.words
    local letterSpacingFactor = miniGameState.letterSpacingFactor
    local rackLetterSize = miniGameState.rackLetterSize
    local numBelts = miniGameState.numBelts

    local runTimeLetterFolder =
        LetterUtils.getRunTimeLetterFolder(miniGameState)
    miniGameState.runTimeLetterFolder = runTimeLetterFolder

    local letterBlockFolder = Utils.getFromTemplates("LetterBlockTemplates")
    local letterBlockTemplate = Utils.getFirstDescendantByName(
                                    letterBlockFolder, "BD_8_blank")

    local conveyor = Utils.getFirstDescendantByName(sectorFolder, "Conveyor")
    local beltPlates = Utils.getDescendantsByName(conveyor, "NewBeltPlate")

    -- populate matrix with letters
    local totalLetterMatrix = {}

    -- combine all plates into a single matrix and populate matrix with random letters
    local lettersNotInWords = LetterUtils.getLettersNotInWords(words)

    local totalRows = numRow * numBelts

    for _ = 1, totalRows do
        local row = {}
        for _ = 1, numCol do
            table.insert(row, LetterUtils.getRandomLetter(lettersNotInWords))
        end
        table.insert(totalLetterMatrix, row)
    end

    local usedLocations = {}
    for _, word in ipairs(words) do
        for letterIndex = 1, #word do
            local letter = string.sub(word, letterIndex, letterIndex)

            local isDirtyLocation = true
            local randomRowIndex = nil
            local randomColIndex = nil
            local locationCode = nil

            -- make sure you do not put 2 letters in the same location
            while isDirtyLocation == true do
                randomRowIndex = Utils.genRandom(1, totalRows)
                randomColIndex = Utils.genRandom(1, numCol)
                locationCode = randomRowIndex .. "-" .. randomColIndex
                isDirtyLocation = usedLocations[locationCode]
            end

            usedLocations[locationCode] = true
            totalLetterMatrix[randomRowIndex][randomColIndex] = letter
        end
    end

    for beltPlateIndex, beltPlate in ipairs(beltPlates) do
        -- if i == 2 then return end
        local beltTemplate = Utils.getFirstDescendantByName(beltPlate, "Belt")
        local letterPositioner = Utils.getFirstDescendantByName(beltPlate,
                                                                "LetterPositioner")

        local spacingFactorX = letterSpacingFactor
        local spacingFactorZ = letterSpacingFactor

        local startIndex = ((beltPlateIndex - 1) * numRow) + 1
        local endIndex = startIndex + numRow - 1
        local letterMatrix = {
            table.unpack(totalLetterMatrix, startIndex, endIndex)
        }

        for colIndex = 1, numCol do
            for rowIndex = 1, numRow do
                local newLetterBlock = letterBlockTemplate:Clone()
                newLetterBlock.Size = Vector3.new(rackLetterSize,
                                                  rackLetterSize, rackLetterSize)

                local letterId = "ID--R" .. rowIndex .. "C" .. colIndex
                local char = letterMatrix[rowIndex][colIndex]

                local name = "rackLetter-" .. char .. "-" .. letterId .. "sss"
                newLetterBlock.Name = name

                LetterUtils.createPropOnLetterBlock(
                    {
                        letterBlock = newLetterBlock,
                        propName = LetterUtils.letterBlockPropNames.IsLifted,
                        initialValue = false,
                        propType = "BoolValue"
                    })

                LetterUtils.createPropOnLetterBlock(
                    {
                        letterBlock = newLetterBlock,
                        propName = LetterUtils.letterBlockPropNames.IsFound,
                        initialValue = false,
                        propType = "BoolValue"
                    })

                local letterPosX = -newLetterBlock.Size.X * (colIndex - 1) *
                                       spacingFactorX
                local letterPosZ = -newLetterBlock.Size.Z * (rowIndex - 1) *
                                       spacingFactorZ

                newLetterBlock.CFrame = Utils3.setCFrameFromDesiredEdgeOffset(
                                            {
                        parent = letterPositioner,
                        child = newLetterBlock,
                        offsetConfig = {
                            useParentNearEdge = Vector3.new(1, -1, 1),
                            useChildNearEdge = Vector3.new(1, -1, 1),
                            offsetAdder = Vector3.new(letterPosX, 0, letterPosZ)
                        }
                    })

                newLetterBlock.Parent = beltTemplate
                newLetterBlock.Anchored = false

                local weld = Instance.new("WeldConstraint")
                weld.Name = "WeldConstraintRackBlock"
                weld.Parent = newLetterBlock
                weld.Part0 = beltTemplate
                weld.Part1 = newLetterBlock

                LetterUtils.initLetterBlock(
                    {
                        letterBlock = newLetterBlock,
                        char = char,
                        templateName = miniGameState.activeStyle,
                        letterBlockType = "RackLetter",
                        isTextLetter = true
                    })

                local function onTouchBlock(newLetterBlock, miniGameState)
                    local db = {value = false}
                    local function closure(otherPart)
                        if not otherPart.Parent then
                            return
                        end
                        local humanoid =
                            otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
                        if not humanoid then return end

                        if not db.value then
                            db.value = true
                            local player = Utils.getPlayerFromHumanoid(humanoid)
                            miniGameState.onSelectRackBlock(newLetterBlock,
                                                            miniGameState,
                                                            player)
                            db.value = false
                        end
                    end
                    return closure
                end

                newLetterBlock.Touched:Connect(
                    onTouchBlock(newLetterBlock, miniGameState))

                table.insert(rackLetterBlockObjs, {
                    part = newLetterBlock,
                    char = char,
                    coords = {row = rowIndex, col = colIndex}
                })
            end
        end

        LetterUtils.styleLetterBlocksBD({miniGameState = miniGameState})

        letterPositioner:Destroy()
    end
end

module.initLetterRack = initLetterRack
module.createLetterPlate = createLetterPlate

return module
