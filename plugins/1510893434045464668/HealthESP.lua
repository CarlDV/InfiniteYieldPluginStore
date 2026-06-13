local Plugin = {
    ["PluginName"] = "HealthESP",
    ["PluginDescription"] = "Highlights players based on HP and shows their actual HP above their heads.",
    ["Commands"] = {
        ["hesp"] = {
            ["ListName"] = "hesp [team/nteam] [limit]",
            ["Description"] = "Loads Health ESP. Examples: hesp, hesp team, hesp nteam, hesp 3, hesp team 3, hesp nteam 3.",
            ["Aliases"] = {"healthesp", "loadhesp"},
            ["Function"] = function(args, speaker)
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local LocalPlayer = Players.LocalPlayer

                if not LocalPlayer then
                    warn("HealthESP: No LocalPlayer found.")
                    return
                end

                local SCRIPT_TAG = "HEALTH_ESP_PLUGIN_RUNNING"
                local HIGHLIGHT_TAG = "HEALTH_ESP_HL"
                local BILLBOARD_TAG = "HEALTH_ESP_BB"

                local teamMode = "all"
                local limitCount = nil

                if args then
                    for _, arg in ipairs(args) do
                        local value = tostring(arg):lower()

                        if value == "off" or value == "stop" or value == "false" or value == "unload" then
                            local oldControl = LocalPlayer:FindFirstChild(SCRIPT_TAG)
                            if oldControl and oldControl:IsA("BindableEvent") then
                                pcall(function()
                                    oldControl:Fire()
                                end)
                                print("HealthESP unloaded.")
                            else
                                print("No running HealthESP instance found.")
                            end
                            return
                        elseif value == "team" or value == "same" or value == "friendly" or value == "friendlies" then
                            teamMode = "team"
                        elseif value == "nteam" or value == "enemy" or value == "enemies" or value == "other" or value == "others" then
                            teamMode = "nteam"
                        else
                            local numberValue = tonumber(value)
                            if numberValue then
                                limitCount = math.max(1, math.floor(numberValue))
                            end
                        end
                    end
                end

                local old = LocalPlayer:FindFirstChild(SCRIPT_TAG)
                if old and old:IsA("BindableEvent") then
                    pcall(function()
                        old:Fire()
                    end)
                    pcall(function()
                        old:Destroy()
                    end)
                end

                local control = Instance.new("BindableEvent")
                control.Name = SCRIPT_TAG
                control.Parent = LocalPlayer

                local maid = {}
                local visuals = {}
                local running = true
                local lastUpdate = 0

                local function giveTask(taskItem)
                    maid[#maid + 1] = taskItem
                    return taskItem
                end

                local function cleanupTasks()
                    for i = #maid, 1, -1 do
                        local taskItem = maid[i]
                        maid[i] = nil

                        local taskType = typeof(taskItem)
                        if taskType == "RBXScriptConnection" then
                            pcall(function()
                                taskItem:Disconnect()
                            end)
                        elseif taskType == "Instance" then
                            pcall(function()
                                taskItem:Destroy()
                            end)
                        elseif taskType == "function" then
                            pcall(taskItem)
                        end
                    end
                end

                local function hpColor(health, maxHealth)
                    maxHealth = math.max(maxHealth or 100, 1)
                    local ratio = math.clamp(health / maxHealth, 0, 1)

                    local red = Color3.fromRGB(255, 60, 60)
                    local yellow = Color3.fromRGB(255, 220, 70)
                    local green = Color3.fromRGB(70, 255, 90)

                    if ratio <= 0.5 then
                        return red:Lerp(yellow, ratio * 2)
                    end

                    return yellow:Lerp(green, (ratio - 0.5) * 2)
                end

                local function removeVisual(player)
                    local visual = visuals[player]
                    if visual then
                        if visual.Highlight then
                            pcall(function()
                                visual.Highlight:Destroy()
                            end)
                        end

                        if visual.Billboard then
                            pcall(function()
                                visual.Billboard:Destroy()
                            end)
                        end

                        visuals[player] = nil
                    end
                end

                local function removeAllESP()
                    for player in pairs(visuals) do
                        removeVisual(player)
                    end

                    for _, player in ipairs(Players:GetPlayers()) do
                        local character = player.Character
                        if character then
                            local oldHighlight = character:FindFirstChild(HIGHLIGHT_TAG)
                            if oldHighlight then
                                pcall(function()
                                    oldHighlight:Destroy()
                                end)
                            end

                            local oldBillboard = character:FindFirstChild(BILLBOARD_TAG)
                            if oldBillboard then
                                pcall(function()
                                    oldBillboard:Destroy()
                                end)
                            end
                        end
                    end
                end

                local function getHumanoidData(player)
                    local character = player.Character
                    if not character or not character.Parent then
                        return nil
                    end

                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        return nil
                    end

                    local adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                    if not adornee then
                        return nil
                    end

                    return {
                        ["Player"] = player,
                        ["Character"] = character,
                        ["Humanoid"] = humanoid,
                        ["Adornee"] = adornee,
                        ["Health"] = humanoid.Health,
                        ["MaxHealth"] = humanoid.MaxHealth
                    }
                end

                local function isValidTarget(player)
                    if player == LocalPlayer then
                        return false
                    end

                    if teamMode == "all" then
                        return true
                    end

                    if teamMode == "team" then
                        if not LocalPlayer.Team then
                            return false
                        end
                        return player.Team == LocalPlayer.Team
                    end

                    if teamMode == "nteam" then
                        if not LocalPlayer.Team then
                            return true
                        end
                        return player.Team ~= LocalPlayer.Team
                    end

                    return true
                end

                local function getTargets()
                    local targets = {}

                    for _, player in ipairs(Players:GetPlayers()) do
                        if isValidTarget(player) then
                            local data = getHumanoidData(player)
                            if data then
                                targets[#targets + 1] = data
                            end
                        end
                    end

                    table.sort(targets, function(a, b)
                        if a.Health == b.Health then
                            return a.Player.Name < b.Player.Name
                        end

                        return a.Health < b.Health
                    end)

                    if limitCount and #targets > limitCount then
                        local limited = {}
                        for i = 1, limitCount do
                            limited[i] = targets[i]
                        end
                        targets = limited
                    end

                    return targets
                end

                local function getOrCreateVisual(player, character)
                    local visual = visuals[player]

                    if visual and visual.Character == character and visual.Highlight and visual.Billboard and visual.Label then
                        return visual
                    end

                    removeVisual(player)

                    local highlight = Instance.new("Highlight")
                    highlight.Name = HIGHLIGHT_TAG
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.55
                    highlight.OutlineTransparency = 0
                    highlight.Parent = character

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = BILLBOARD_TAG
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 180, 0, 42)
                    billboard.StudsOffset = Vector3.new(0, 3.15, 0)
                    billboard.Parent = character

                    local label = Instance.new("TextLabel")
                    label.Name = "HPLabel"
                    label.BackgroundTransparency = 1
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.Font = Enum.Font.GothamBold
                    label.TextScaled = true
                    label.TextStrokeTransparency = 0.25
                    label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    label.Parent = billboard

                    visual = {
                        ["Character"] = character,
                        ["Highlight"] = highlight,
                        ["Billboard"] = billboard,
                        ["Label"] = label
                    }

                    visuals[player] = visual
                    return visual
                end

                local function updateESP()
                    if not running then
                        return
                    end

                    local targets = getTargets()
                    local active = {}

                    for _, data in ipairs(targets) do
                        local player = data.Player
                        active[player] = true

                        local visual = getOrCreateVisual(player, data.Character)
                        local color = hpColor(data.Health, data.MaxHealth)
                        local health = math.floor(data.Health + 0.5)
                        local maxHealth = math.floor(data.MaxHealth + 0.5)

                        visual.Highlight.Adornee = data.Character
                        visual.Highlight.FillColor = color
                        visual.Highlight.OutlineColor = color

                        visual.Billboard.Adornee = data.Adornee
                        visual.Label.TextColor3 = color
                        visual.Label.Text = string.format("%s | %d/%d HP", player.DisplayName or player.Name, health, maxHealth)
                    end

                    for player in pairs(visuals) do
                        if not active[player] or not player.Parent then
                            removeVisual(player)
                        end
                    end
                end

                local function unload()
                    if not running then
                        return
                    end

                    running = false
                    removeAllESP()
                    cleanupTasks()

                    if control then
                        pcall(function()
                            control:Destroy()
                        end)
                    end

                    print("HealthESP unloaded.")
                end

                giveTask(control.Event:Connect(unload))

                giveTask(RunService.Heartbeat:Connect(function()
                    if not running then
                        return
                    end

                    local now = os.clock()
                    if now - lastUpdate >= 0.15 then
                        lastUpdate = now
                        updateESP()
                    end
                end))

                giveTask(Players.PlayerAdded:Connect(function(player)
                    giveTask(player.CharacterAdded:Connect(function()
                        task.wait(0.25)
                        updateESP()
                    end))
                end))

                giveTask(Players.PlayerRemoving:Connect(function(player)
                    removeVisual(player)
                end))

                for _, player in ipairs(Players:GetPlayers()) do
                    giveTask(player.CharacterAdded:Connect(function()
                        task.wait(0.25)
                        updateESP()
                    end))
                end

                updateESP()

                local modeText = "all players"
                if teamMode == "team" then
                    modeText = "your team only"
                elseif teamMode == "nteam" then
                    modeText = "not your team only"
                end

                local limitText = limitCount and (", lowest HP limit: " .. tostring(limitCount)) or ""
                print("HealthESP loaded for " .. modeText .. limitText .. ".")
            end
        },

        ["unhesp"] = {
            ["ListName"] = "unhesp",
            ["Description"] = "Unloads Health ESP.",
            ["Aliases"] = {"hespoff", "unloadhesp", "stophesp", "nohesp"},
            ["Function"] = function(args, speaker)
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer

                if not LocalPlayer then
                    warn("HealthESP: No LocalPlayer found.")
                    return
                end

                local ev = LocalPlayer:FindFirstChild("HEALTH_ESP_PLUGIN_RUNNING")
                if ev and ev:IsA("BindableEvent") then
                    pcall(function()
                        ev:Fire()
                    end)
                    print("Unload signal sent.")
                else
                    print("No running HealthESP instance found.")
                end
            end
        }
    }
}

return Plugin
