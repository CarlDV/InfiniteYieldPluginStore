local Speed = 2
local Playing = false

local Plugin = {
	["PluginName"] = "Animation Speed Plugin",
	["PluginDescription"] = "Made by Cateh",
	["Commands"] = {
		["animspeedloop"] = {
			["ListName"] = "animspeedloop [numb]",
			["Description"] = "The same as 'animspeed' but looped",
			["Aliases"] = {},
			["Function"] = function(args,speaker)
				Speed = args[1]
				local humanoid = speaker.Character:FindFirstChild("Humanoid")
				if humanoid then
					Playing = false
					Playing = true
					while Playing == true do wait() print(1)
						for _,v in next, humanoid.Animator:GetPlayingAnimationTracks() do
        					v:AdjustSpeed(Speed) print(2)
    					end 
					end
				else
					notify("Error", "Unable to find Humanoid, try respawning?")
				end
			end
		},
		["stopanimspeed"] = {
			["ListName"] = "stopanimspeed",
			["Description"] = "Stops animspeedloop",
			["Aliases"] = {},
			["Function"] = function(args,speaker)
				Playing = false
			end
		},
	}
}
return Plugin
