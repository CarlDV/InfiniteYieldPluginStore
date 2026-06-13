dofile('spamlist.txt')
delay = 3
local Plugin = {
	["PluginName"] = "chat spammer",
	["PluginDescription"] = "for the trolls",
	["Commands"] = {
		--spams
		["sus"] = {
			["ListName"] = "sus",
			["Description"] = "EMERGENCY MEETING",
			["Aliases"] = {""},
			["Function"] = function(args,speaker)
				for index, value in pairs(xtra[2]) do
					game:GetService("ReplicatedStorage")["DefaultChatSystemChatEvents"].SayMessageRequest:FireServer(value, "All")
					wait(0.1)
				end
			end
		},
		["sus2"] = {
			["ListName"] = "sus2",
			["Description"] = "SUPER IDOL 105",
			["Aliases"] = {""},
			["Function"] = function(args,speaker)
				for index, value in pairs(xtra[1]) do
					game:GetService("ReplicatedStorage")["DefaultChatSystemChatEvents"].SayMessageRequest:FireServer(value, "All")
					wait(0.1)
				end
			end
		},
		["clearchat"] = {
			["ListName"] = "clearChat",
			["Description"] = "clear the chat",
			["Aliases"] = {""},
			["Function"] = function(args, speaker)
				game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻", "All")
				game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻", "All")
			end
		},
		["randspam"] = {
			["ListName"] = "randspam / rs",
			["Description"] = "r/copypasta",
			["Aliases"] = {"rs"},
			["Function"] = function(args, speaker)
				stop = true
				while true do wait(delay)
					if stop == true then
						local rcp = math.random(1, #spamlist)
						if type(spamlist[rcp]) == "table" then
							wait(5)
							for index, value in pairs(spamlist[rcp]) do
								game:GetService("ReplicatedStorage")["DefaultChatSystemChatEvents"].SayMessageRequest:FireServer(value, "All")
								wait(3)
							end
							wait(10)
						else
							game:GetService("ReplicatedStorage")["DefaultChatSystemChatEvents"].SayMessageRequest:FireServer(spamlist[rcp], "All")
						end
					end
				end
			end
		},
		["unrandspam"] = {
			["ListName"] = "unrandspam / unrs",
			["Description"] = "Sorry, the community you are searching for was removed.",
			["Aliases"] = {"unrs"},
			["Function"] = function(args, speaker)
				stop = false
			end
		},
		["delay"] = {
			["ListName"] = "delay [secs]",
			["Description"] = "change delay",
			["Aliases"] = {""},
			["Function"] = function(args, speaker)
				delay = tonumber(args[1])
			end
		},
	}
}
return Plugin