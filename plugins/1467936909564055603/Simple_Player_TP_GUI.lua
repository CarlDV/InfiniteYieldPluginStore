local Plugin = {
    ["PluginName"] = "Simple Player TP GUI",
    ["PluginDescription"] = "Opens a GUI to TP to players",
    ["Commands"] = {
        ["playertpgui"] = {
            ["ListName"] = "playertpgui / plrtg /ptg",
            ["Description"] = "Opens a GUI to TP to a Player",
            ["Aliases"] = {"plrtg","ptg",},
            ["Function"] = function(args, speaker)
                -- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- ======================
-- CONFIG COLORS
-- ======================
local BG_COLOR = Color3.fromRGB(30, 30, 30)
local BUTTON_COLOR = Color3.fromRGB(50, 50, 50)
local BUTTON_HOVER = Color3.fromRGB(70, 70, 70)
local TEXT_COLOR = Color3.new(1, 1, 1)

-- ======================
-- STATE VARIABLES
-- ======================
local selectedPlayer = nil
local teleportEnabled = false
local positionBehind = true
local distanceFromTarget = 5.5

-- ======================
-- SCREEN GUI
-- ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerButtons"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ======================
-- SELECT PLAYER BUTTON
-- ======================
local toggleListButton = Instance.new("TextButton")
toggleListButton.Text = "Select Player"
toggleListButton.Size = UDim2.new(0, 220, 0, 30)
toggleListButton.Position = UDim2.new(0, 10, 0, 10)
toggleListButton.BackgroundColor3 = BG_COLOR
toggleListButton.BorderSizePixel = 0
toggleListButton.TextColor3 = TEXT_COLOR
toggleListButton.TextXAlignment = Enum.TextXAlignment.Center
toggleListButton.Font = Enum.Font.SourceSans
toggleListButton.TextSize = 18
toggleListButton.ZIndex = 2
toggleListButton.Parent = screenGui
toggleListButton.Active = true

-- ======================
-- PLAYER POPUP MENU
-- ======================
local popupFrame = Instance.new("Frame")
popupFrame.Size = UDim2.new(0, 300, 0, 400)
popupFrame.Position = UDim2.new(0.7, 0, 0.5, 0)
popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
popupFrame.BackgroundColor3 = BG_COLOR
popupFrame.BorderSizePixel = 1
popupFrame.Visible = false
popupFrame.ZIndex = 10
popupFrame.Parent = screenGui
popupFrame.Active = true
popupFrame.ClipsDescendants = true

local popupStroke = Instance.new("UIStroke")
popupStroke.Color = Color3.fromRGB(100, 100, 100)
popupStroke.Thickness = 2
popupStroke.Parent = popupFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Select Player"
titleLabel.Size = UDim2.new(1, -20, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = TEXT_COLOR
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.ZIndex = 11
titleLabel.Parent = popupFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
scrollFrame.ZIndex = 11
scrollFrame.Parent = popupFrame
scrollFrame.Active = true

local closeButton = Instance.new("TextButton")
closeButton.Text = "Close"
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, 0, 1, -40)
closeButton.AnchorPoint = Vector2.new(0.5, 0)
closeButton.BackgroundColor3 = BUTTON_COLOR
closeButton.BorderSizePixel = 0
closeButton.TextColor3 = TEXT_COLOR
closeButton.Font = Enum.Font.SourceSans
closeButton.ZIndex = 11
closeButton.Parent = popupFrame
closeButton.Active = true

-- ======================
-- OTHER UI BUTTONS
-- ======================
local startX, startY = 10, 50
local buttonWidth, buttonHeight = 130, 30
local gapY = 40

-- Teleport toggle
local teleportToggleButton = Instance.new("TextButton")
teleportToggleButton.Text = "Teleport OFF"
teleportToggleButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
teleportToggleButton.Position = UDim2.new(0, startX, 0, startY)
teleportToggleButton.BackgroundColor3 = BG_COLOR
teleportToggleButton.BorderSizePixel = 0
teleportToggleButton.TextColor3 = TEXT_COLOR
teleportToggleButton.ZIndex = 2
teleportToggleButton.Parent = screenGui
teleportToggleButton.Active = true

-- Hide All
local hideAllButton = Instance.new("TextButton")
hideAllButton.Text = "Hide All"
hideAllButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
hideAllButton.Position = UDim2.new(0, startX, 0, startY + gapY)
hideAllButton.BackgroundColor3 = BG_COLOR
hideAllButton.BorderSizePixel = 0
hideAllButton.TextColor3 = TEXT_COLOR
hideAllButton.ZIndex = 2
hideAllButton.Parent = screenGui
hideAllButton.Active = true

-- Show All
local showAllButton = Instance.new("TextButton")
showAllButton.Text = "▶"
showAllButton.Size = UDim2.new(0, 30, 0, 30)
showAllButton.Position = UDim2.new(0, startX, 0, startY + gapY)
showAllButton.BackgroundColor3 = BG_COLOR
showAllButton.BorderSizePixel = 0
showAllButton.TextColor3 = TEXT_COLOR
showAllButton.Visible = false
showAllButton.ZIndex = 2
showAllButton.Parent = screenGui
showAllButton.Active = true

-- Position toggle
local positionButton = Instance.new("TextButton")
positionButton.Text = "Position: Behind"
positionButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
positionButton.Position = UDim2.new(0, startX, 0, startY + 2 * gapY)
positionButton.BackgroundColor3 = BG_COLOR
positionButton.BorderSizePixel = 0
positionButton.TextColor3 = TEXT_COLOR
positionButton.ZIndex = 2
positionButton.Parent = screenGui
positionButton.Active = true

-- Distance buttons and label
local minusButton = Instance.new("TextButton")
minusButton.Text = "-"
minusButton.Size = UDim2.new(0, 30, 0, 30)
minusButton.Position = UDim2.new(0, startX, 0, startY + 3 * gapY)
minusButton.BackgroundColor3 = BG_COLOR
minusButton.BorderSizePixel = 0
minusButton.TextColor3 = TEXT_COLOR
minusButton.ZIndex = 2
minusButton.Parent = screenGui
minusButton.Active = true

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Text = "Distance: 5.5"
distanceLabel.Size = UDim2.new(0, 120, 0, 30)
distanceLabel.Position = UDim2.new(0, startX + 40, 0, startY + 3 * gapY)
distanceLabel.BackgroundColor3 = BG_COLOR
distanceLabel.BorderSizePixel = 0
distanceLabel.TextColor3 = TEXT_COLOR
distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
distanceLabel.ZIndex = 2
distanceLabel.Parent = screenGui

local plusButton = Instance.new("TextButton")
plusButton.Text = "+"
plusButton.Size = UDim2.new(0, 30, 0, 30)
plusButton.Position = UDim2.new(0, startX + 170, 0, startY + 3 * gapY)
plusButton.BackgroundColor3 = BG_COLOR
plusButton.BorderSizePixel = 0
plusButton.TextColor3 = TEXT_COLOR
plusButton.ZIndex = 2
plusButton.Parent = screenGui
plusButton.Active = true

-- ======================
-- PLAYER LIST FUNCTIONS
-- ======================
local function createPlayerButton(player)
    local btn = Instance.new("TextButton")
    btn.Text = (player.DisplayName ~= "" and player.DisplayName) or player.Name
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = BUTTON_COLOR
    btn.BorderSizePixel = 0
    btn.TextColor3 = TEXT_COLOR
    btn.Font = Enum.Font.SourceSans
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.ZIndex = 11
    btn.Parent = scrollFrame
    btn.Active = true

    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = BUTTON_HOVER end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = BUTTON_COLOR end)

    btn.MouseButton1Click:Connect(function()
        selectedPlayer = player
        toggleListButton.Text = btn.Text
        popupFrame.Visible = false
    end)

    return btn
end

local function refreshPlayerList()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local yOffset = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local btn = createPlayerButton(player)
            btn.Position = UDim2.new(0, 5, 0, yOffset)
            yOffset = yOffset + 35
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

toggleListButton.MouseButton1Click:Connect(function()
    popupFrame.Visible = not popupFrame.Visible
    if popupFrame.Visible then
        refreshPlayerList()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    popupFrame.Visible = false
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        selectedPlayer = nil
        toggleListButton.Text = "Select Player"
    end
    refreshPlayerList()
end)

-- ======================
-- TELEPORT LOGIC
-- ======================
teleportToggleButton.MouseButton1Click:Connect(function()
    teleportEnabled = not teleportEnabled
    teleportToggleButton.Text = teleportEnabled and "Teleport ON" or "Teleport OFF"
end)

positionButton.MouseButton1Click:Connect(function()
    positionBehind = not positionBehind
    positionButton.Text = positionBehind and "Position: Behind" or "Position: In Front"
end)

plusButton.MouseButton1Click:Connect(function()
    distanceFromTarget += 0.5
    distanceLabel.Text = "Distance: " .. string.format("%.1f", distanceFromTarget)
end)

minusButton.MouseButton1Click:Connect(function()
    distanceFromTarget = math.max(0.5, distanceFromTarget - 0.5)
    distanceLabel.Text = "Distance: " .. string.format("%.1f", distanceFromTarget)
end)

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    if not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if not localPlayer.Character then return end
    local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return end

    local targetHRP = targetPlayer.Character.HumanoidRootPart
    local offset = positionBehind and -targetHRP.CFrame.LookVector * distanceFromTarget
                                  or targetHRP.CFrame.LookVector * distanceFromTarget
    localHRP.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
end

RunService.Heartbeat:Connect(function()
    if teleportEnabled and selectedPlayer then
        teleportToPlayer(selectedPlayer)
    end
end)

-- ======================
-- HIDE / SHOW UI
-- ======================
hideAllButton.MouseButton1Click:Connect(function()
    toggleListButton.Visible = false
    teleportToggleButton.Visible = false
    hideAllButton.Visible = false
    positionButton.Visible = false
    plusButton.Visible = false
    minusButton.Visible = false
    distanceLabel.Visible = false
    popupFrame.Visible = false
    showAllButton.Visible = true
end)

showAllButton.MouseButton1Click:Connect(function()
    toggleListButton.Visible = true
    teleportToggleButton.Visible = true
    hideAllButton.Visible = true
    positionButton.Visible = true
    plusButton.Visible = true
    minusButton.Visible = true
    distanceLabel.Visible = true
    showAllButton.Visible = false
end)
            end,
        },
    },
}

return Plugin