local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local Plugin = {
	["PluginName"] = "Fling V2",
	["PluginDescription"] = "Flings a player without ever needing to walk past through them.",
	["Commands"] = {
		["flingv2"] = {
			["ListName"] = "flingv2 [player]",
			["Description"] = "Attaches you to a player and flings it.",
			["Aliases"] = {"fv2"},
			["Function"] = function(args, speaker)
				local players = getPlayer(args[1], speaker)
				
				if #players == 0 then
					return
				end
				
				local hrp = speaker.Character:FindFirstChild("HumanoidRootPart")
				
				if not hrp then
					notify("Your character does not have a root part.")
					return
				end
				local lastCFrame = hrp.CFrame
				local attachTo = nil
				velocity = hrp.Velocity
				bazinga = rs.RenderStepped:Connect(function()
					if attachTo ~= nil then
						hrp.CFrame = attachTo.CFrame
					end
				end)
				
				speaker.Character.Humanoid.Died:Connect(function()
					bazinga:Disconnect()
				end)
				
				local target = plrs[players[1]]
				local targethrp = target.Character:FindFirstChild("HumanoidRootPart")
				
				if not targethrp then
					notify("Target's character does not have a root part")
					return
				end
				
				whatthesigma = target.Character.Humanoid.Died:Connect(function()
					execCmd("unfling")
					bazinga:Disconnect()
				end)
				
				execCmd("fling")
				attachTo = targethrp
			end
		},
		["unflingv2"] = {
			["ListName"] = "unflingv2",
			["Description"] = "Unattaches you to the target and stops flinging. Can be a failsafe",
			["Aliases"] = {"ufv2"},
			["Function"] = function(args, speaker)
				execCmd("unfling")
				bazinga:Disconnect()
			end
		}
	}
}
return Plugin