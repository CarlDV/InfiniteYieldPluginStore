local Plugin = {
	["PluginName"] = "StopSound",
	["PluginDescription"] = "Stops all sounds currently playing without muting or blocking future sounds.",
	["Commands"] = {
		["stopsound"] = {
			["ListName"] = "stopsound",
			["Description"] = "Stops all currently playing sounds.",
			["Aliases"] = {},
			["Function"] = function(args, speaker)
				local stopped = 0
				local failed = 0

				for _, obj in ipairs(game:GetDescendants()) do
					if obj:IsA("Sound") then
						local isPlaying = false

						pcall(function()
							isPlaying = obj.IsPlaying or obj.Playing
						end)

						if isPlaying then
							local success = pcall(function()
								obj:Stop()
							end)

							if success then
								stopped += 1
							else
								failed += 1
							end
						end
					end
				end

				if typeof(notify) == "function" then
					notify("StopSound", "Stopped " .. stopped .. " currently playing sound(s).")
				end

				if failed > 0 then
					warn("[StopSound] Failed to stop " .. failed .. " sound(s).")
				end
			end
		}
	}
}

return Plugin