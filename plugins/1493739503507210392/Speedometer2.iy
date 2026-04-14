--THIS IS REALLY EXPERIMENTAL I DON'T KNOW HOW TO CODE FOR MOBILE SO LIKE YEAH. have fun tracking your speed. -weapponofchoice
local Plugin = {
    ["PluginName"] = "Speedometer2",
    ["PluginDescription"] = "oh my god! i'm so fast",
    ["Commands"] = {
        ["speedometer"] = {
            ["ListName"] = "speedometer / sps / speedo",
            ["Description"] = "Toggles the Speedometer UI",
            ["Aliases"] = {"sps", "speedo"},
            ["Function"] = function(args, speaker)
                local targetParent = (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                
                if targetParent:FindFirstChild("SPS_Final") then
                    targetParent.SPS_Final:Destroy()
                    return
                end

                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local UIS = game:GetService("UserInputService")
                local TweenService = game:GetService("TweenService")
                local DefaultPos = UDim2.new(0.5, -70, 0.85, 0)

                local ScreenGui = Instance.new("ScreenGui", targetParent)
                ScreenGui.Name = "SPS_Final"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.DisplayOrder = 999
                ScreenGui.IgnoreGuiInset = true

                local Display = Instance.new("Frame", ScreenGui)
                Display.Size = UDim2.new(0, 140, 0, 50)
                Display.Position = DefaultPos
                Display.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                Display.BackgroundTransparency = 0.2
                Display.BorderSizePixel = 0
                Display.ZIndex = 10
                Display.Active = true

                local Stroke = Instance.new("UIStroke", Display)
                Stroke.Color = Color3.fromRGB(60, 60, 60)
                Stroke.Thickness = 1
                Instance.new("UICorner", Display).CornerRadius = UDim.new(0, 4)

                local ValueLabel = Instance.new("TextLabel", Display)
                ValueLabel.Size = UDim2.new(1, 0, 0.6, 0)
                ValueLabel.Position = UDim2.new(0, 0, 0.1, 0)
                ValueLabel.Text = "00.00"
                ValueLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
                ValueLabel.Font = Enum.Font.RobotoMono
                ValueLabel.TextSize = 22
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.ZIndex = 11

                local UnitLabel = Instance.new("TextLabel", Display)
                UnitLabel.Size = UDim2.new(1, 0, 0.3, 0)
                UnitLabel.Position = UDim2.new(0, 0, 0.65, 0)
                UnitLabel.Text = "STUDS / SEC"
                UnitLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                UnitLabel.Font = Enum.Font.RobotoMono
                UnitLabel.TextSize = 9
                UnitLabel.BackgroundTransparency = 1
                UnitLabel.ZIndex = 11

                local Connections = {}
                local function Cleanup()
                    for _, conn in pairs(Connections) do if conn then conn:Disconnect() end end
                    if ScreenGui then ScreenGui:Destroy() end
                end

                local Dragging, DragStart, StartPos

                table.insert(Connections, Display.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        DragStart = input.Position
                        StartPos = Display.Position
                    end
                end))

                table.insert(Connections, UIS.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local Delta = input.Position - DragStart
                        Display.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                    end
                end))

                table.insert(Connections, UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end))

                table.insert(Connections, RunService.RenderStepped:Connect(function()
                    if not ScreenGui or not ScreenGui.Parent then Cleanup() return end
                    local char = Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local speed = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
                        ValueLabel.Text = string.format("%.2f", speed)
                        ValueLabel.TextColor3 = speed > 100 and Color3.fromRGB(255, 50, 50) or speed > 50 and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(0, 180, 255)
                    else
                        ValueLabel.Text = "0.00"
                    end
                end))
            end
        },
        ["stopspeedometer"] = {
            ["ListName"] = "closespeedometer / nosps / unspeedo",
            ["Description"] = "Closes the Speedometer UI",
            ["Aliases"] = {"closespeedometer", "nosps", "unspeedo", "pneumonoultramicroscopicsilicovolcanoconiosis"},
            ["Function"] = function(args, speaker)
                local targetParent = (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local existing = targetParent:FindFirstChild("SPS_Final")
                if existing then
                    existing:Destroy()
                end
            end
        }
    }
}

return Plugin