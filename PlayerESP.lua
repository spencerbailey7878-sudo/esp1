
-- MOBILE PLAYER ESP
-- For your own Roblox Studio game
-- Location: StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ESPEnabled = true
local NamesEnabled = true
local DistanceEnabled = true
local PlayerData = {}

-- Remove a player's visual elements
local function removeESP(player)
    local data = PlayerData[player]
    if not data then return end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    PlayerData[player] = nil
end

-- Update the label and highlight states
local function refresh()
    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter
        and myCharacter:FindFirstChild("HumanoidRootPart")

    for player, data in pairs(PlayerData) do
        local character = data.Character

        if character and character.Parent then
            if data.Highlight then
                data.Highlight.Enabled = ESPEnabled
            end

            if data.Billboard then
                data.Billboard.Enabled = ESPEnabled
                    and (NamesEnabled or DistanceEnabled)
            end

            local lines = {}

            if NamesEnabled then
                table.insert(lines, player.DisplayName)
            end

            local theirRoot =
                character:FindFirstChild("HumanoidRootPart")

            if DistanceEnabled and myRoot and theirRoot then
                local studs = math.floor(
                    (myRoot.Position - theirRoot.Position).Magnitude
                )

                table.insert(lines, studs .. " studs")
            end

            if data.Label then
                data.Label.Text = table.concat(lines, "\n")
            end
        end
    end
end

-- Add visuals to a character
local function addESP(player)
    if player == LocalPlayer then return end

    removeESP(player)

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not head or not humanoid then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 65, 65)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.55
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Enabled = ESPEnabled
    highlight.Parent = character

    -- Name and distance label
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerInfo"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(260, 64)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2000
    billboard.Enabled = ESPEnabled
        and (NamesEnabled or DistanceEnabled)
    billboard.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 22
    label.TextWrapped = true
    label.Parent = billboard

    PlayerData[player] = {
        Character = character,
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }

    refresh()
end

-- Create the mobile menu
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerESPMenu"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(210, 155)
main.Position = UDim2.new(0, 15, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(27, 29, 35)
main.BorderSizePixel = 0
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

local minimized = false
local buttons = {}

local function makeButton(name, text, y)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -16, 0, 30)
    button.Position = UDim2.fromOffset(8, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 52, 63)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Text = text
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    table.insert(buttons, button)

    return button
end

local espButton = makeButton("ESPButton", "", 46)
local namesButton = makeButton("NamesButton", "", 81)
local distanceButton = makeButton("DistanceButton", "", 116)

local function updateMenu()
    espButton.Text = "Highlights: " .. (ESPEnabled and "ON" or "OFF")
    namesButton.Text = "Names: " .. (NamesEnabled and "ON" or "OFF")
    distanceButton.Text =
        "Distance: " .. (DistanceEnabled and "ON" or "OFF")

    refresh()
end

espButton.Activated:Connect(function()
    ESPEnabled = not ESPEnabled
    updateMenu()
end)

namesButton.Activated:Connect(function()
    NamesEnabled = not NamesEnabled
    updateMenu()
end)

distanceButton.Activated:Connect(function()
    DistanceEnabled = not DistanceEnabled
    updateMenu()
end)

-- Minimize and restore
header.Activated:Connect(function()
    minimized = not minimized

    for _, button in ipairs(buttons) do
        button.Visible = not minimized
    end

    main.Size = UDim2.fromOffset(210, minimized and 38 or 155)
    header.Text = minimized and "PLAYER ESP    +" or "PLAYER ESP    −"
end)

-- Drag menu by its header using mouse or touch
local dragging = false
local dragStart
local startPosition
local activeTouch

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        if input.UserInputType == Enum.UserInputType.Touch then
            activeTouch = input
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    local isMouse =
        input.UserInputType == Enum.UserInputType.MouseMovement

    local isTouch = input == activeTouch

    if isMouse or isTouch then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input == activeTouch then
        dragging = false
        activeTouch = nil
    end
end)

-- Set up players and respawns
local function setupPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        addESP(player)
    end)

    if player.Character then
        addESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Keep distances updated
task.spawn(function()
    while gui.Parent do
        refresh()
        task.wait(0.25)
    end
end)

updateMenu()
