local Plugin = {
	["PluginName"] = "Goto Folder",
	["PluginDescription"] = "goto the folder of a part",
	["Commands"] = {
		["gotofolder"] = {
			["ListName"] = "gotofolder [folder name]",
			["Description"] = "Made By D7M",
			["Aliases"] = {},
			["Function"] = function(args, speaker)
					for i,v in pairs(workspace:GetDescendants()) do
					if v.Name:lower() == getstring(1):lower() then
					local Children = v:GetChildren()
					for i = 1, #Children do
					getRoot(speaker.Character).CFrame = Children[i].CFrame
					wait(0.1)
					end

					end
					end
			end
		},
	},
}

return Plugin
