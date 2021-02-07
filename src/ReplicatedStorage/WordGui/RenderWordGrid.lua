local RS = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Utils = require(RS.Source.Utils.RSU001GeneralUtils)

local module = {}

local renderGrid = function(props)
    local levelConfig = props.levelConfig
    local sgui = props.sgui
    local targetWords = levelConfig.targetWords

    local mainGui = sgui:WaitForChild("MainGui")
    local mainFrame = Utils.getFirstDescendantByName(mainGui, "MainFrame")

    -- Size up the mainFrame temporarily to get the viewport size
    local viewPortSize = mainGui.AbsoluteSize
    print('viewPortSize' .. ' - start');
    print(viewPortSize);
    print('workspace.CurrentCamera.ViewportSize' .. ' - start');
    print(workspace.CurrentCamera.ViewportSize);

    local parentWidth = viewPortSize.X
    local parentHeight = viewPortSize.Y
    local rowHeight = parentHeight / 20

    local paddingInPx = 10
    local rowGap = rowHeight * 0.02

    local letterWidth = rowHeight
    local letterHeight = rowHeight
    local letterOffsetX = letterWidth / 20
    local leteterBorderSizePixel = letterWidth / 10

    local lettersInWord = 3
    local scrollBarThickness = 30

    local rowWidth = (lettersInWord + 2) * letterWidth + scrollBarThickness
    local guiWidth = (lettersInWord + 2) * letterWidth
    local guiWidth = (lettersInWord + 2) * letterWidth

    mainFrame.Size = UDim2.new(0.5, 0, 0, guiWidth)

    local scrollingFrame = Utils.getFirstDescendantByName(sgui, "WordScroller")

    scrollingFrame.ScrollBarThickness = scrollBarThickness
    -- scrollingFrame.CanvasSize = UDim2.new(0, 0, 20, 0)
    scrollingFrame.Size = UDim2.new(0, rowWidth, 1, 0)
    scrollingFrame.Position = UDim2.new(0, 0, 0, 0)

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

    for wordIndex, word in ipairs(targetWords) do
        local newRow = rowTemplate:Clone()
        newRow.Parent = rowTemplate.Parent
        newRow.Name = rowTemplate.Name .. "--row--ooo--" .. wordIndex
        newRow.Size = UDim2.new(1, 0, 0, rowHeight)

        local rowOffsetY = (wordIndex - 1) * (rowHeight + paddingInPx)
        newRow.Position = UDim2.new(0, 0, 0, rowOffsetY)

        local imageLabelTemplate = Utils.getFirstDescendantByName(newRow,
                                                                  "BlockChar")

        for letterIndex = 1, #word do
            local letterNameStub = word .. "-L" .. letterIndex
            local char = string.sub(word, letterIndex, letterIndex)

            local newImageLabel = imageLabelTemplate:Clone()

            newImageLabel.Name = "wordLetter-" .. letterNameStub
            newImageLabel.Size = UDim2.new(0, rowHeight, 0, rowHeight)
            newImageLabel.Position = UDim2.new(0, (letterIndex - 1) *
                                                   (letterWidth + letterOffsetX),
                                               0, 0)
            newImageLabel.Text = char
            newImageLabel.BorderSizePixel = leteterBorderSizePixel

            -- Do this last to avoid tweening
            newImageLabel.Parent = newRow

        end
        imageLabelTemplate:Destroy()

    end
    rowTemplate:Destroy()
end

module.renderGrid = renderGrid
return module
