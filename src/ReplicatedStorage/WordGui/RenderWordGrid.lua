local RS = game:GetService("ReplicatedStorage")

local Utils = require(RS.Source.Utils.RSU001GeneralUtils)

local module = {}

local renderGrid = function(props)
    local levelConfig = props.levelConfig
    local sgui = props.sgui
    local words = levelConfig.targetWords

    local mainGui = sgui:WaitForChild("MainGui")
    mainGui.Enabled = true
    local mainFrame = Utils.getFirstDescendantByName(mainGui, "MainFrame")

    -- Size up the mainFrame temporarily to get the viewport size
    local displayHeight = mainGui.AbsoluteSize.Y

    local paddingInPx = 10
    local doublePad = paddingInPx * 2

    local lettersInWord = 3
    local scrollBarThickness = 30
    local maxWordsInFrame = 4

    if (#words <= maxWordsInFrame) then scrollBarThickness = 0 end

    local numWordsInFrame = math.min(maxWordsInFrame, #words)

    -- letter stuff
    local letterHeight = displayHeight / 20
    local letterWidth = letterHeight
    local letterGapX = letterWidth / 20
    local totalLetterWidth = letterWidth + letterGapX
    local letterBorderSizePixel = letterWidth / 10

    -- row stuff
    local rowGapY = paddingInPx / 2
    local rowHeight = letterHeight
    local totalRowHeight = letterHeight + rowGapY
    local rowWidth = (lettersInWord * letterWidth) + (lettersInWord - 1) *
                         letterGapX

    --  scroller stuff
    local scrollingFrame = Utils.getFirstDescendantByName(sgui, "WordScroller")
    local scrollerWidth = rowWidth + scrollBarThickness + doublePad + 0
    local scrollerHeight = numWordsInFrame * totalRowHeight + paddingInPx
    local guiWidth = scrollerWidth + 0
    local guiHeight = scrollerHeight

    scrollingFrame.ScrollBarThickness = scrollBarThickness

    local fixRoundingError = 10
    scrollingFrame.Size = UDim2.new(0, scrollerWidth + fixRoundingError, 0,
                                    scrollerHeight)
    scrollingFrame.Position = UDim2.new(0, 0, 0, 0)

    local scrollerCanvasHeight = #words * totalRowHeight + doublePad - rowGapY
    scrollingFrame.CanvasSize = UDim2.new(0, scrollerWidth - scrollBarThickness,
                                          0, scrollerCanvasHeight)

    mainFrame.Size = UDim2.new(0, guiWidth, 0, guiHeight)

    Utils.addPadding({
        parent = scrollingFrame,
        padding = paddingInPx,
        inPx = true
    })

    -- local children = scrollingFrame:GetChildren()
    -- for i, item in pairs(children) do
    --     if item:IsA('TextLabel') then item:Destroy() end
    -- end

    local rowTemplate = Utils.getFirstDescendantByName(sgui, "RowTemplate")

    for wordIndex, item in ipairs(words) do
        local word = item.word
        local newRow = rowTemplate:Clone()
        newRow.Parent = rowTemplate.Parent
        newRow.Name = rowTemplate.Name .. "--row--ooo--" .. wordIndex
        newRow.Size = UDim2.new(0, rowWidth, 0, rowHeight)

        local rowOffsetY = (wordIndex - 1) * totalRowHeight
        newRow.Position = UDim2.new(0, 0, 0, rowOffsetY)

        local imageLabelTemplate = Utils.getFirstDescendantByName(newRow,
                                                                  "BlockChar")

        for letterIndex = 1, #word do
            local letterNameStub = word .. "-L" .. letterIndex
            local char = string.sub(word, letterIndex, letterIndex)

            local newTextLabel = imageLabelTemplate:Clone()

            newTextLabel.Name = "wordLetter-" .. letterNameStub
            newTextLabel.Size = UDim2.new(0, letterHeight, 0, letterHeight)
            newTextLabel.Position = UDim2.new(0, (letterIndex - 1) *
                                                  totalLetterWidth, 0, 0)
            newTextLabel.Text = char
            newTextLabel.BorderSizePixel = letterBorderSizePixel

            -- Do this last to avoid tweening
            newTextLabel.Parent = newRow

        end
        imageLabelTemplate:Destroy()
    end
    -- rowTemplate:Destroy()
end

module.renderGrid = renderGrid
return module
