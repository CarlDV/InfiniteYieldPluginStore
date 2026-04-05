local Plugin = {
    ["PluginName"] = "NightVision",
    ["PluginDescription"] = "Player highlighting with distance tracking",
    ["Commands"] = {
        ["nightvision"] = {
            ["Aliases"] = {"nv"},
            ["Function"] = function(args)
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Teams = game:GetService("Teams")
                local RunService = game:GetService("RunService")
                
                if not _G.NightVisionData then
                    _G.NightVisionData = {
                        Active = false,
                        Highlights = {},
                        ESPs = {},
                        Connections = {}
                    }
                end
                
                local data = _G.NightVisionData
                
                local function clearAll()
                    for _, highlight in pairs(data.Highlights) do
                        highlight:Destroy()
                    end
                    for _, esp in pairs(data.ESPs) do
                        esp:Destroy()
                    end
                    for _, conn in ipairs(data.Connections) do
                        conn:Disconnect()
                    end
                    
                    data.Highlights = {}
                    data.ESPs = {}
                    data.Connections = {}
                end
                
                local function createESP(player)
                    if data.ESPs[player] then return end
                    
                    local esp = Instance.new("BillboardGui")
                    esp.Name = "NV_ESP"
                    esp.Size = UDim2.new(0, 200, 0, 50)
                    esp.AlwaysOnTop = true
                    esp.ExtentsOffset = Vector3.new(0, 3, 0)
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Name = "NV_NameLabel"
                    nameLabel.Text = player.Name
                    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    nameLabel.Position = UDim2.new(0, 0, 0, 0)
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Font = Enum.Font.SourceSansBold
                    nameLabel.TextSize = 14
                    nameLabel.Parent = esp
                    
                    local distLabel = Instance.new("TextLabel")
                    distLabel.Name = "NV_DistLabel"
                    distLabel.Text = "0 studs"
                    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distLabel.TextColor3 = Color3.new(1, 1, 1)
                    distLabel.BackgroundTransparency = 1
                    distLabel.Font = Enum.Font.SourceSans
                    distLabel.TextSize = 12
                    distLabel.Parent = esp
                    
                    esp.Parent = player.Character and player.Character:FindFirstChild("Head") or nil
                    data.ESPs[player] = esp
                    
                    player.CharacterAdded:Connect(function(char)
                        if char:FindFirstChild("Head") then
                            esp.Parent = char.Head
                        else
                            char:WaitForChild("Head")
                            esp.Parent = char.Head
                        end
                    end)
                end
                
                local function createHighlight(player, color)
                    if data.Highlights[player] then return end
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "NV_Highlight"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.FillColor = color or Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = color or Color3.fromRGB(255, 50, 50)
                    
                    highlight.Parent = player.Character or player.CharacterAdded:Wait()
                    data.Highlights[player] = highlight
                    
                    player.CharacterAdded:Connect(function(char)
                        highlight.Parent = char
                    end)
                end
                
                local function updateDistances()
                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                    
                    local localPos = LocalPlayer.Character.HumanoidRootPart.Position
                    
                    for player, esp in pairs(data.ESPs) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local playerPos = player.Character.HumanoidRootPart.Position
                            local distance = math.floor((localPos - playerPos).Magnitude)
                            esp.NV_DistLabel.Text = tostring(distance) .. " studs"
                        end
                    end
                end
                
                local function highlightAll()
                    clearAll()
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            createHighlight(player)
                            createESP(player)
                        end
                    end
                    
                    table.insert(data.Connections, RunService.Heartbeat:Connect(updateDistances))
                    
                    data.Active = true
                    return "Highlighting ALL players in red with distance"
                end
                
                local function highlightTeam(teamName)
                    clearAll()
                    local team = Teams:FindFirstChild(teamName)
                    if not team then return "Team not found: "..teamName end
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Team == team then
                            createHighlight(player, team.TeamColor.Color)
                            createESP(player)
                        end
                    end
                    
                    table.insert(data.Connections, RunService.Heartbeat:Connect(updateDistances))
                    
                    data.Active = true
                    return "Highlighting team: "..teamName.." with distance"
                end
                
                local function highlightPlayer(playerName)
                    clearAll()
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if string.lower(player.Name) == string.lower(playerName) then
                            createHighlight(player)
                            createESP(player)
                            table.insert(data.Connections, RunService.Heartbeat:Connect(updateDistances))
                            data.Active = true
                            return "Highlighting player: "..player.Name.." with distance"
                        end
                    end
                    
                    return "Player not found: "..playerName
                end
                
                local function toggleOff()
                    clearAll()
                    data.Active = false
                    return "NightVision disabled"
                end
                
                if #args == 0 then
                    if data.Active then
                        return toggleOff()
                    else
                        return highlightAll()
                    end
                end
                
                if args[1]:lower() == "all" then
                    return highlightAll()
                elseif args[1]:lower() == "all_teams" then
                    clearAll()
                    for _, team in ipairs(Teams:GetTeams()) do
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player.Team == team then
                                createHighlight(player, team.TeamColor.Color)
                                createESP(player)
                            end
                        end
                    end
                    table.insert(data.Connections, RunService.Heartbeat:Connect(updateDistances))
                    data.Active = true
                    return "Highlighting ALL teams with their colors and distance"
                elseif Teams:FindFirstChild(args[1]) then
                    return highlightTeam(args[1])
                else
                    return highlightPlayer(args[1])
                end
            end
        }
    }
}

return Plugin