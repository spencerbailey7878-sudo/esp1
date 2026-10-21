
-- Mobile Player ESP UI
-- For your own Roblox Studio game
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerESPMenu"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(210, 155)
main.Position = UDim2.new(0, 15, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(27, 29, 35)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("TextButton")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
header.Text = "PLAYER ESP    −"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 13
header.Parent = main

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local function createButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 30)
    button.Position = UDim2.fromOffset(8, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 52, 63)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Text = text
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    return button
end

local espOn = false
local namesOn = true
local distanceOn = true
local minimized = false

local espButton = createButton("Highlights: OFF", 46)
local namesButton = createButton("Names: ON", 81)
local distanceButton = createButton("Distance: ON", 116)

local highlights = {}

local function removeHighlight(target)
    if highlights[target] then
        highlights[target]:Destroy()
        highlights[target] = nil
    end
end

local function addHighlight(target)
    if target == player or not target.Character then
        return
    end

    removeHighlight(target)

    local highlight = Instance.new("Highlight")
    highlight.Adornee = target.Character
    highlight.FillColor = Color3.fromRGB(255, 65, 65)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.55
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Enabled = espOn
    highlight.Parent = target.Character

    highlights[target] = highlight
end

local function refresh()
    for target, highlight in pairs(highlights) do
        if highlight.Parent and target.Character then
            highlight.Enabled = espOn
        end
    end

    espButton.Text = "Highlights: " .. (espOn and "ON" or "OFF")
    namesButton.Text = "Names: " .. (namesOn and "ON" or "OFF")
    distanceButton.Text = "Distance: " .. (distanceOn and "ON" or "OFF")
end

espButton.Activated:Connect(function()
    espOn = not espOn
    refresh()
end)

namesButton.Activated:Connect(function()
    namesOn = not namesOn
    refresh()
end)

distanceButton.Activated:Connect(function()
    distanceOn = not distanceOn
    refresh()
end)

header.Activated:Connect(function()
    minimized = not minimized
    espButton.Visible = not minimized
    namesButton.Visible = not minimized
    distanceButton.Visible = not minimized
    main.Size = UDim2.fromOffset(210, minimized and 38 or 155)
    header.Text = minimized and "PLAYER ESP    +" or "PLAYER ESP    −"
end)

-- Drag the menu using its header on mouse or touch.
local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local function setupTarget(target)
    if target == player then return end

    target.CharacterAdded:Connect(function()
        task.wait(0.5)
        addHighlight(target)
        refresh()
    end)

    if target.Character then
        addHighlight(target)
    end
end

for _, target in ipairs(Players:GetPlayers()) do
    setupTarget(target)
end

Players.PlayerAdded:Connect(setupTarget)
Players.PlayerRemoving:Connect(removeHighlight)

refresh()
