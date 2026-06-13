local Plugin = {
    ["PluginName"] = "ColorESP",
    ["PluginDescription"] = "ESP players or all humanoids based on dominant body color.",
    ["Commands"] = {
        ["loadColorESP"] = {
            ["ListName"] = "loadColorESP",
            ["Description"] = "Loads Color ESP. Optional argument: true = all humanoids, false = players only.",
            ["Aliases"] = {"coloresp", "cesp", "loadesp"},
            ["Function"] = function(args, speaker)
                print("Loading ColorESP...")

                local Players = game:GetService("Players")
                local Workspace = game:GetService("Workspace")
                local LocalPlayer = Players.LocalPlayer
                if not LocalPlayer then
                    warn("No LocalPlayer found.")
                    return
                end

                local SCRIPT_TAG = "COLOR_ESP_PLUGIN_RUNNING"
                local ESP_TAG = "COLOR_ESP_HL"

                local highlightAllHumanoids = false
                if args and args[1] ~= nil then
                    local value = tostring(args[1]):lower()
                    if value == "true" then
                        highlightAllHumanoids = true
                    elseif value == "false" then
                        highlightAllHumanoids = false
                    end
                end

                local old = LocalPlayer:FindFirstChild(SCRIPT_TAG)
                if old and old:IsA("BindableEvent") then
                    pcall(function() old:Fire() end)
                    pcall(function() old:Destroy() end)
                end

                local control = Instance.new("BindableEvent")
                control.Name = SCRIPT_TAG
                control.Parent = LocalPlayer

                local maid = {}
                local running = true

                local function giveTask(task)
                    maid[#maid + 1] = task
                    return task
                end

                local function cleanup()
                    for i = #maid, 1, -1 do
                        local t = maid[i]
                        maid[i] = nil

                        local tt = typeof(t)
                        if tt == "RBXScriptConnection" then
                            pcall(function() t:Disconnect() end)
                        elseif tt == "Instance" then
                            pcall(function() t:Destroy() end)
                        elseif tt == "function" then
                            pcall(t)
                        end
                    end
                end

                local function isCharacterModel(model)
                    return model
                        and model:IsA("Model")
                        and model:FindFirstChildOfClass("Humanoid") ~= nil
                end

                local function dominantColor(character)
                    local counts = {}

                    for _, inst in ipairs(character:GetDescendants()) do
                        if inst:IsA("BasePart") then
                            local c = inst.Color
                            local key = string.format(
                                "%d,%d,%d",
                                math.floor(c.R * 255 + 0.5),
                                math.floor(c.G * 255 + 0.5),
                                math.floor(c.B * 255 + 0.5)
                            )

                            if counts[key] then
                                counts[key].count = counts[key].count + 1
                            else
                                counts[key] = {
                                    count = 1,
                                    color = c
                                }
                            end
                        end
                    end

                    local best = nil
                    for _, entry in pairs(counts) do
                        if not best or entry.count > best.count then
                            best = entry
                        end
                    end

                    return best and best.color or Color3.new(1, 1, 1)
                end

                local function applyESPToModel(model)
                    task.wait(0.15)
                    if not running then return end
                    if not model or not model.Parent then return end
                    if not isCharacterModel(model) then return end

                    local hl = model:FindFirstChild(ESP_TAG)
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = ESP_TAG
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillTransparency = 0.6
                        hl.OutlineTransparency = 0
                        hl.Parent = model
                    end

                    local dom = dominantColor(model)
                    hl.Adornee = model
                    hl.FillColor = dom
                    hl.OutlineColor = dom
                end

                local function watchPlayer(player)
                    local function onCharacterAdded(char)
                        applyESPToModel(char)
                    end

                    if player.Character then
                        onCharacterAdded(player.Character)
                    end

                    giveTask(player.CharacterAdded:Connect(onCharacterAdded))
                end

                local function watchHumanoidModel(model)
                    applyESPToModel(model)
                end

                local function removeAllESP()
                    for _, inst in ipairs(Workspace:GetDescendants()) do
                        if inst:IsA("Highlight") and inst.Name == ESP_TAG then
                            pcall(function() inst:Destroy() end)
                        end
                    end
                end

                local function unload()
                    if not running then return end
                    running = false
                    removeAllESP()
                    cleanup()

                    if control then
                        pcall(function() control:Destroy() end)
                    end

                    print("ColorESP unloaded.")
                end

                giveTask(control.Event:Connect(unload))

                if highlightAllHumanoids then
                    for _, inst in ipairs(Workspace:GetDescendants()) do
                        if isCharacterModel(inst) then
                            watchHumanoidModel(inst)
                        end
                    end

                    giveTask(Workspace.DescendantAdded:Connect(function(inst)
                        if isCharacterModel(inst) then
                            watchHumanoidModel(inst)
                        end
                    end))

                    print("ColorESP loaded for all humanoids.")
                else
                    for _, player in ipairs(Players:GetPlayers()) do
                        watchPlayer(player)
                    end

                    giveTask(Players.PlayerAdded:Connect(watchPlayer))

                    print("ColorESP loaded for players only.")
                end
            end
        },

        ["unloadColorESP"] = {
            ["ListName"] = "unloadColorESP",
            ["Description"] = "Unloads Color ESP",
            ["Aliases"] = {"unloadesp", "stopcoloresp", "stopesp", "uncesp"},
            ["Function"] = function(args, speaker)
                local Players = game:GetService("Players")
                local lp = Players.LocalPlayer
                if not lp then
                    warn("No LocalPlayer found.")
                    return
                end

                local ev = lp:FindFirstChild("COLOR_ESP_PLUGIN_RUNNING")
                if ev and ev:IsA("BindableEvent") then
                    pcall(function() ev:Fire() end)
                    print("Unload signal sent.")
                else
                    print("No running ColorESP instance found.")
                end
            end
        }
    }
}

return Plugin