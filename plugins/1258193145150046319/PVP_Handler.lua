local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local CSpeed = false
local m = 0
local LineEsp = false
local LineEspColor = Color3.new(1, 1, 1)
local AimBot = {Part = "HumanoidRootPart", Active = false}
local Cam = workspace.CurrentCamera
local AimPlayer = {Active = false, Target = nil}

RunService.Stepped:Connect(function()
    if CSpeed then
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + character.Humanoid.MoveDirection * m
        end
    end

    if LineEsp then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player then
                local camera = workspace.CurrentCamera
                local Vector = camera:WorldToViewportPoint(v.Character.UpperTorso.Position)

                local Line = Drawing.new("Line")
                Line.Visible = true
                Line.Color = LineEspColor
                Line.Thickness = 1
                Line.Transparency = 1

                Line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                Line.To = Vector2.new(Vector.X, Vector.Y)
                task.wait(0.01)
                Line:Remove()
            end
        end
    end

    if AimBot.Active and not AimPlayer.Active then
        for _, v in pairs(Players:GetChildren()) do
            local char = v.Character
            if char and char:FindFirstChild(AimBot.Part) and (v ~= player) then
                Cam.CFrame = CFrame.new(
                    Cam.CFrame.Position,
                    char[AimBot.Part].Position or char[AimBot.Part].CFrame.Position
                )
            end
        end
    end

    if AimPlayer.Active and AimPlayer.Target then
        local targetChar = workspace:FindFirstChild(AimPlayer.Target)
        if targetChar and targetChar:FindFirstChild(AimBot.Part) then
            Cam.CFrame = CFrame.new(
                Cam.CFrame.Position,
                targetChar[AimBot.Part].Position or targetChar[AimBot.Part].CFrame.Position
            )
        end
    end
end)

local Plugin = {
    ["PluginName"] = "PVP Handler",
    ["PluginDescription"] = "Boost your Infinite Yield with PVP useful commands",
    ["Commands"] = {
        ["cframespeed"] = {
            ["Listname"] = "cframespeed [multiplier]",
            ["Description"] = "Boosts your character Walk Speed by HumanoidRootPart CFrame",
            ["Aliases"] = {"cspeed", "cwalkspeed", "cframewalkspeed"},
            ["Function"] = function(multiplier, speaker)
                m = tonumber(multiplier)
                if m and m > 0 then
                    CSpeed = true
                else
                    CSpeed = false
                end
                return m, CSpeed
            end
        },
        ["LineEsp"] = {
            ["ListName"] = "LineEsp [Color1] [Color2] [Color3]",
            ["Description"] = "Toggle LineEsp",
            ["Aliases"] = {"EspLine"},
            ["Function"] = function(speaker)
                if Drawing then
                    LineEsp = not LineEsp
                    return LineEsp
                else
                    notif("ERROR", "Your executor needs Drawing Library to use this function")
                end
            end
        },
        ["SetLineEspColor"] = {
            ["ListName"] = "SetLineEspColor",
            ["Description"] = "Sets Line Esp Color (apply to all Line Esps)",
            ["Aliases"] = {"setespcolor", "espcolor", "linecolor"},
            ["Function"] = function(Color1, Color2, Color3, speaker)
                LineEspColor = Color3.new(tonumber(Color1), tonumber(Color2), tonumber(Color3))
                notif("Commands+", "Done!")
                return LineEspColor
            end
        },
        ["Aimbot"] = {
            ["ListName"] = "Aimbot",
            ["Description"] = "Toggle Aimbot",
            ["Aliases"] = {"aim", "toggleaimbot", "toggleaim"},
            ["Function"] = function(speaker)
                AimBot.Active = not AimBot.Active
                return AimBot
            end
        },
        ["PlayerAimbot"] = {
            ["ListName"] = "PlayerAimbot [player]",
            ["Description"] = "Aimbot at a player",
            ["Aliases"] = {"paimbot", "aimbotplayer", "aplayer"},
            ["Function"] = function(player, speaker)
                AimPlayer.Active = true
                AimPlayer.Target = tostring(player)
                return AimPlayer
            end
        }
    }
}

return Plugin
