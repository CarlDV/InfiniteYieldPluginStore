local Plugin = {
    ["PluginName"] = "FE ReplicateSignal Godmode",
    ["PluginDescription"] = "Godmode using SetStateEnabled and NaN Health",
    ["Commands"] = {
        ["godmode"] = {
            ["ListName"] = "godmode",
            ["Description"] = "Activates godmode",
            ["Aliases"] = {"cgod"},
            ["Function"] = function(args, speaker)
                local self = speaker
                local character = self.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end

                humanoid:SetStateEnabled(15, false)
                humanoid:SetStateEnabled(1, false)
                humanoid:SetStateEnabled(0, false)

                if replicatesignal then
                    replicatesignal(self.Kill)
                else
                    notify("not found replicatesignal :(")
                end

                local success, err = pcall(function() 
                    if sethiddenproperty then
                        sethiddenproperty(humanoid, "maxHealth", 0/0)
                        sethiddenproperty(humanoid, "MaxHealth", 0/0)
                        sethiddenproperty(humanoid, "Health_XML", 0/0)
                        sethiddenproperty(humanoid, "Health", 0/0)
                    elseif setscriptable then
                        setscriptable(humanoid, "maxHealth", true)
                        setscriptable(humanoid, "Health_XML", true)
                        humanoid.maxHealth = 0/0
                        humanoid.MaxHealth = 0/0
                        humanoid.Health_XML = 0/0
                        humanoid.Health = 0/0
                        task.wait()
                        setscriptable(humanoid, "maxHealth", false)
                        setscriptable(humanoid, "Health_XML", false)
                    else
			humanoid.MaxHealth = 0/0
                        humanoid.Health = 0/0
                    end
                end)

                if not success then 
                    warn("error: " .. tostring(err)) 
                end
            end,
        },
    },
}

return Plugin
