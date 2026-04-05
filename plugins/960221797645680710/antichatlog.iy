ChatLog = function()	end
game.ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
		if logsEnabled == true then
			CreateLabel(data.FromSpeaker,data.Message)
		end
	end)

return {
    ["PluginName"] = "AntiAntiChatLog",
    ["PluginDescription"] = "made by prisj",
    ["Commands"] = {}
}