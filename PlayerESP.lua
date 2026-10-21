-- Mobile Player ESP
-- For your own Roblox Studio game

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = true
local NamesEnabled = true
local DistanceEnabled = true
local Highlights = {}

local function removeESP(player)
    local data = Highlights[player]
    if data then
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        Highlights[player] = nil
    end
end

local function addESP(player)
    if player == LocalPlayer then return end
    removeESP(player)

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESPHighlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 65, 65)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.55
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = ESPEnabled
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESPLabel"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(180, 42)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = NamesEnabled or DistanceEnabled
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = billboard

    Highlights[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Character = character
    }
end

local function refresh()
    for player, data in pairs(Highlights) do
        if data.Character and data.Character.Parent then
            data.Highlight.Enabled = ESPEnabled
            data.Billboard.Enabled = ESPEnabled
                and (NamesEnabled or DistanceEnabled)

            local text = {}
            if NamesEnabled then
                table.insert(text, player.DisplayName)
            end

            if DistanceEnabled and LocalPlayer.Character then
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local theirRoot = data.Character:FindFirstChild("HumanoidRootPart")
                if myRoot and theirRoot then
                    table.insert(text, math.floor(
                        (myRoot.Position - theirRoot.Position).Magnitude
                    ) .. " studs")
                end
            end

            data.Label.Text = table.concat(text, " | ")
        end
    end
end

-- Simple mobile-friendly menu
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerESPMenu"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(210, 190)
main.Position = UDim2.new(0, 15, 0.35, 0)
main.BackgroundColor3 = Color3.fromRGB(27, 29, 35)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("TextButton")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
header.Text = "PLAYER ESP     —"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 13
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

-- Drag by the header; works with mouse and touch.
local dragging = false
local dragStart, startPos, dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

local minimized = false
local buttons = {}

local function makeToggle(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 34)
    button.Position = UDim2.fromOffset(8, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 52, 63)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Text = text
    button.Parent = main
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    button.Activated:Connect(callback)
    table.insert(buttons, button)
    return button
end

makeToggle("ESP: ON", 46, function()
    ESPEnabled = not ESPEnabled
    refresh()
end).Name = "ESPToggle"

makeToggle("Names: ON", 84, function()
    NamesEnabled = not NamesEnabled
    refresh()
end).Name = "NamesToggle"

makeToggle("Distance: ON", 122, function()
    DistanceEnabled = not DistanceEnabled
    refresh()
end).Name = "DistanceToggle"

-- Update button labels and ESP state
local function updateMenu()
    for _, button in ipairs(buttons) do
        if button.Name == "ESPToggle" then
            button.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
        elseif button.Name == "NamesToggle" then
            button.Text = "Names: " .. (NamesEnabled and "ON" or "OFF")
        elseif button.Name == "DistanceToggle" then
            button.Text = "Distance: " .. (DistanceEnabled and "ON" or "OFF")
        end
    end
    refresh()
end

for _, button in ipairs(buttons) do
    button.Activated:Connect(updateMenu)
end

header.Activated:Connect(function()
    minimized = not minimized
    for _, button in ipairs(buttons) do
        button.Visible = not minimized
    end
    main.Size = UDim2.fromOffset(210, minimized and 38 or 190)
    header.Text = minimized and "PLAYER ESP     +" or "PLAYER ESP     —"
end)

local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        addESP(player)
        refresh()
    end)
    if player.Character then
        addESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

while gui.Parent do
    refresh()
    task.wait(0.25)
end
