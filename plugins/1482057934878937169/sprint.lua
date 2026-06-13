local anim = true

local Plugin = {
	["PluginName"] = "Shift To Sprint",
	["PluginDescription"] = "A plugin that tpwalks you when you hold shift",
	["Commands"] = {
		["shifttosprint"] = {
			["ListName"] = "shifttosprint / sts / sprint [speed]",
			["Description"] = "Enable the toggle, arg1 is a sprint speed multiplier. (default is 1.5x)",
			["Aliases"] = { "sts", "sprint" },
			["Function"] = function(args, speaker)
				pcall(function()
					event:Disconnect()
					event2:Disconnect()
					tpwalking:Disconnect()
				end)

				local character = speaker.Character
				local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
				local animController = humanoid or character:FindFirstChildOfClass("AnimationController")

				local multi = (args[1] and isNumber(args[1])) and tonumber(args[1]) or 1.5

				local UserInputService = game:GetService("UserInputService")
				local tpwalking

				event = UserInputService.InputBegan:connect(function(input, gameprocessed)
					if input.KeyCode == Enum.KeyCode.LeftShift then
						tpwalking = RunService.Heartbeat:Connect(function(delta)
							if not (character and humanoid and humanoid.Parent) then
								tpwalking:Disconnect()
								return
							end
							local normalSpeed = humanoid.WalkSpeed
							if normalSpeed > 5 and humanoid.MoveDirection.Magnitude > 0 then
								local speed = normalSpeed / 10 * (multi - 1)
								character:TranslateBy(humanoid.MoveDirection * speed * delta * 10)

								if anim then
									for i,v in next, humanoid:GetPlayingAnimationTracks() do
										v:AdjustSpeed(tonumber(normalSpeed / 16 * multi))
									end
								end
							end
						end)
					end
				end)

				event2 = UserInputService.InputEnded:connect(function(input, gameprocessed)
					if input.KeyCode == Enum.KeyCode.LeftShift then
						tpwalking:Disconnect()
						if anim then
							local normalSpeed = humanoid.WalkSpeed
							for i,v in next, humanoid:GetPlayingAnimationTracks() do
								v:AdjustSpeed(tonumber(normalSpeed / 16))
							end
						end
					end
				end)
			end,
        },

		["noshifttosprint"] = {
			["ListName"] = "noshifttosprint / nsts / nosprint / unsprint",
			["Description"] = "Disconnect the toggle.",
			["Aliases"] = { "nsts", "nosprint", "unsprint" },
			["Function"] = function(args, speaker)
				event:Disconnect()
				event2:Disconnect()
				tpwalking:Disconnect()
			end,
		},

		["sprintanim"] = {
			["ListName"] = "sprintanim / sanimtoggle",
			["Description"] = "toggle animation speeding up when using sprint (true by default)",
			["Aliases"] = { "sanimtoggle" },
			["Function"] = function(args, speaker)
				anim = not anim
			end,
		},
	},
}

return Plugin
