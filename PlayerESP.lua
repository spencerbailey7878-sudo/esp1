
-- NEON RED MOBILE PLAYER ESP
-- For your own Roblox Studio game
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ESP SETTINGS
local ESPEnabled = true
local NamesEnabled = true
local DistanceEnabled = true
local MAX_DISTANCE = 2000

local PlayerData = {}

-- COLORS
local RED = Color3.fromRGB(255, 48, 65)
local DARK = Color3.fromRGB(13, 14, 19)
local PANEL = Color3.fromRGB(23, 24, 32)
local MUTED = Color3.fromRGB(145, 148, 162)

-- CLEAN UP OLD GUI
for _, name in ipairs({"PlayerESPMenu"}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- REMOVE PLAYER VISUALS
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

-- UPDATE LABELS AND VISIBILITY
local function refresh()
    local character = LocalPlayer.Character
    local myRoot = character and
        character:FindFirstChild("HumanoidRootPart")

    for player, data in pairs(PlayerData) do
        local target = data.Character

        if target and target.Parent then
            if data.Highlight then
                data.Highlight.Enabled = ESPEnabled
            end

            if data.Billboard then
                data.Billboard.Enabled =
                    ESPEnabled and
                    (NamesEnabled or DistanceEnabled)
            end

            local lines = {}

            if NamesEnabled then
                table.insert(lines, player.DisplayName)
            end

            local theirRoot =
                target:FindFirstChild("HumanoidRootPart")

            if DistanceEnabled and myRoot and theirRoot then
                local distance =
                    (myRoot.Position - theirRoot.Position).Magnitude

                table.insert(
                    lines,
                    math.floor(distance) .. " studs"
                )
            end

            if data.Label then
                data.Label.Text = table.concat(lines, "\n")
            end
        end
    end
end

-- CREATE ESP FOR A CHARACTER
local function addESP(player)
    if player == LocalPlayer then return end

    removeESP(player)

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not head or not humanoid then return end

    -- Character outline
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.Adornee = character
    highlight.FillColor = RED
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.55
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Enabled = ESPEnabled
    highlight.Parent = character

    -- Smaller label positioned higher above the head
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerInfo"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(200, 42)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MAX_DISTANCE
    billboard.Enabled =
        ESPEnabled and (NamesEnabled or DistanceEnabled)
    billboard.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
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

-- BUILD THE NEON MOBILE MENU
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerESPMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(205, 166)
main.Position = UDim2.new(0, 14, 0.3, 0)
main.BackgroundColor3 = DARK
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 30, 40)
stroke.Thickness = 1.2
stroke.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 43)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius =
    UDim.new(0, 12)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, 0, 0, 3)
accent.BackgroundColor3 = RED
accent.BorderSizePixel = 0
accent.Parent = header

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(12, 4)
title.Size = UDim2.new(1, -55, 0, 21)
title.BackgroundTransparency = 1
title.Text = "PLAYER ESP"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(12, 24)
status.Size = UDim2.new(1, -55, 0, 13)
status.BackgroundTransparency = 1
status.Text = "● NEON INTERFACE"
status.TextColor3 = RED
status.TextSize = 9
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(29, 27)
minimize.Position = UDim2.new(1, -35, 0, 9)
minimize.BackgroundColor3 = Color3.fromRGB(58, 24, 31)
minimize.Text = "−"
minimize.TextColor3 = RED
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.Parent = header

Instance.new("UICorner", minimize).CornerRadius =
    UDim.new(0, 7)

local rows = {}
local minimized = false

-- CUSTOM TOGGLE SWITCHES
local function makeToggle(labelText, y, getter, setter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 32)
    row.Position = UDim2.fromOffset(8, y)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = main

    Instance.new("UICorner", row).CornerRadius =
        UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(9, 0)
    label.Size = UDim2.new(1, -65, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(235, 236, 242)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(39, 21)
    toggle.Position = UDim2.new(1, -47, 0.5, -10)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = row

    Instance.new("UICorner", toggle).CornerRadius =
        UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(15, 15)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = toggle

    Instance.new("UICorner", knob).CornerRadius =
        UDim.new(1, 0)

    local function update(animate)
        local enabled = getter()
        local background = enabled and RED
            or Color3.fromRGB(65, 66, 76)
        local position = UDim2.fromOffset(
            enabled and 21 or 3, 3
        )

        if animate then
            TweenService:Create(
                toggle,
                TweenInfo.new(0.12),
                {BackgroundColor3 = background}
            ):Play()

            TweenService:Create(
                knob,
                TweenInfo.new(0.12),
                {Position = position}
            ):Play()
        else
            toggle.BackgroundColor3 = background
            knob.Position = position
        end
    end

    toggle.Activated:Connect(function()
        setter(not getter())
        update(true)
        refresh()
    end)

    update(false)
    table.insert(rows, row)
end

makeToggle("Highlights", 50,
    function() return ESPEnabled end,
    function(v) ESPEnabled = v end)

makeToggle("Player Names", 87,
    function() return NamesEnabled end,
    function(v) NamesEnabled = v end)

makeToggle("Distance", 124,
    function() return DistanceEnabled end,
    function(v) DistanceEnabled = v end)

-- MINIMIZE / RESTORE
local function setMinimized(value)
    minimized = value

    for _, row in ipairs(rows) do
        row.Visible = not minimized
    end

    main.Size = UDim2.fromOffset(
        205, minimized and 43 or 166
    )

    minimize.Text = minimized and "+" or "−"
end

minimize.Activated:Connect(function()
    setMinimized(not minimized)
end)

-- DRAG MENU WITH MOUSE OR TOUCH
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

    local mouseMove =
        input.UserInputType == Enum.UserInputType.MouseMovement
    local touchMove = input == activeTouch

    if mouseMove or touchMove then
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

-- SET UP PLAYERS AND RESPAWNS
local function setupPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if player.Parent == Players then
            addESP(player)
        end
    end)

    player.CharacterRemoving:Connect(function()
        removeESP(player)
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

-- UPDATE DISTANCES
task.spawn(function()
    while gui.Parent do
        refresh()
        task.wait(0.25)
    end
end)

refresh()
