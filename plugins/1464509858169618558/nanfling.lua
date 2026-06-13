local Runservice = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))

local Plugin = {
	["PluginName"] = "NaN Fling",
	["PluginDescription"] = "Fling players using nan fling",
	["Commands"] = {
		["nanfling"] = {
			["ListName"] = "nanfling [plr]",
			["Description"] = "send a player to the void",
			["Aliases"] = {"nfling", "nanf"},
			["Function"] = function(args, speaker)
				if not args[1] then return notify('Player Required', 'No player provided') end
				
				local nan_vector = Vector3.new(0/0, 0/0, 0/0)
				
				for _, v in next, getPlayer(args[1], speaker) do
					local trgt = Players:FindFirstChild(v)
					if not trgt or trgt == speaker then continue end
					
					local char = speaker.Character
					local trgt_chr = trgt.Character
					
					if char and trgt_chr then
						local hrp = char:FindFirstChild("HumanoidRootPart")
						local hum = char:FindFirstChildOfClass("Humanoid")
						local trgt_hrp = trgt_chr:FindFirstChild("HumanoidRootPart")
						
						if hrp and hum and trgt_hrp then
							
							notify("Flinging", "Attempting to fling " .. trgt.Name)
							
							hum.PlatformStand = true
							local start_time = tick()
							local heartbeat_connection
							
							heartbeat_connection = Runservice.Heartbeat:Connect(function()
								local current_time = tick()
								
								if (current_time - start_time) >= 1.5 or not char.Parent or not trgt_chr.Parent then
									heartbeat_connection:Disconnect()
									if hum then hum.PlatformStand = false end
									return
								end
								
								hrp.CFrame = trgt_hrp.CFrame
								hrp.AssemblyLinearVelocity = nan_vector
								hrp.AssemblyAngularVelocity = nan_vector
								
								pcall(function()
									hum:Move(nan_vector)
								end)
								
								if sethiddenproperty then
									pcall(function()
										sethiddenproperty(hrp, "PhysicsRepRootPart", trgt_hrp)
									end)
								end
							end)
						end
					end
				end
			end
		}
	}
}

return Plugin