local Plugin = {
    ["PluginName"] = "Anti-Anti-Earrape",
    ["PluginDescription"] = "a graxe20 willy show",
    ["Commands"] = {
        ["anti-earrape"] = {
            ["ListName"] = "anti-anti-earrape / aae",
            ["Description"] = "Enables the Anti-Anti-Earrape",
            ["Aliases"] = {"antiantiearrape", "aee"},
            ["Function"] = function()
                local MAX_THRESHOLD = 1000 -- next update u can edit this through infinite yield
                local MIN_THRESHOLD = 860

                local function monitor(sound)
                    local heartbeat
                    heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
                        if sound.IsPlaying then
                            if sound.PlaybackLoudness > MAX_THRESHOLD then
                                -- print("sound muted:", sound.Name, sound.PlaybackLoudness)
                                sound.Volume = 0
                            elseif sound.PlaybackLoudness > MIN_THRESHOLD then
                                sound.Volume = sound.Volume * 59
                                -- print("sound increased:", sound.Name, sound.PlaybackLoudness)
                            end
                        else
                            heartbeat:Disconnect()
                        end
                    end)
                end

                local function findSoundsIn(parent)
                    for _, child in ipairs(parent:GetChildren()) do
                        if child:IsA("Sound") then
                            monitor(child)
                        elseif #child:GetChildren() > 0 then
                            findSoundsIn(child)
                        end
                    end
                end

                findSoundsIn(game)

                game.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Sound") then
                        monitor(descendant)
                    end
                end)
            end
        }
    }
}

return Plugin