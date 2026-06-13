local Plugin = {
    ["PluginName"] = "flipscreen",
    ["PluginDescription"] = "Good Plugin For flipscreen",
    ["Commands"] = {
        ["flipscreen"] = {
            ["ListName"] = "flipscreen",
            ["Description"] = "Flip screen ON/OFF",
            ["Aliases"] = {"flipscreen","fs","rotatescreen","rts","rotatethescreen"},
            ["Function"] = function(args, speaker)

                local RunService = game:GetService("RunService")

                _G.FlipConnection = _G.FlipConnection or nil
                _G.FlipEnabled = not _G.FlipEnabled

                -- OFF
                if not _G.FlipEnabled then
                    if _G.FlipConnection then
                        _G.FlipConnection:Disconnect()
                        _G.FlipConnection = nil
                    end
                    return
                end

                -- ON
                _G.FlipConnection = RunService.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    if not camera then return end

                    local cf = camera.CFrame
                    camera.CFrame = cf * CFrame.Angles(0, 0, math.rad(180))
                end)

            end
        }
    }
}

return Plugin
