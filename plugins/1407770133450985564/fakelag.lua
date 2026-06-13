local RunService = game:GetService("RunService")

local fakeLagLoop
local respawnConnection

local delay = 2

local Plugin = {
    ["PluginName"] = "Fake Lag",
    ["PluginDescription"] = "Make's your character feel laggy (real)",
    ["Commands"] = {
        ["fakelag"] = {
            ["ListName"] = "fakelag [delay]",
            ["Description"] = "lags your character",
            ["Aliases"] = { "flg", "flag" },
            ["Function"] = function(args, speaker)
                fakeLagLoop = nil
                
                if respawnConnection then
                    respawnConnection:Disconnect()
                    respawnConnection = nil
                end
                
                delay = tonumber(args[1]) or 2
                
                local function startLag(character)
                    fakeLagLoop = true

                    task.spawn(function()
                        while fakeLagLoop do
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.Anchored = true
                                task.wait(delay)
                                hrp.Anchored = false
                            end
                            task.wait(0.05)
                        end
                    end)
                end

                if speaker.Character then
                    startLag(speaker.Character)
                end

                respawnConnection = speaker.CharacterAdded:Connect(function(character)
                    fakeLagLoop = nil
                    startLag(character)
                end)
            end
        },
        ["unfakelag"] = {
            ["ListName"] = "unfakelag / uflg / uflag",
            ["Description"] = "unlags your character",
            ["Aliases"] = { "uflg", "uflag" },
            ["Function"] = function(args, speaker)
                fakeLagLoop = nil
                if respawnConnection then
                    respawnConnection:Disconnect()
                    respawnConnection = nil
                end

                -- for the safety (it might still be anchored)
                local hrp = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = false
                end
            end
        }
     }
}

return Plugin