local textChatService = game:GetService("TextChatService")
local chatChannel = textChatService.TextChannels.RBXGeneral
local chatConnection = nil

local isAutoCutie = false
local speakerUserId = nil

-- cant figure out a way to intercept (or at least stop) msg before firing so...
-- + let the server be with the og msg
-- + from msg back, we uwuify and fire out

local function uwuifyString(input, speaker)
	local result = input
	local seed = os.time()
	math.randomseed(seed)

	result = string.gsub(result, "r", "w")
	result = string.gsub(result, "R", "W")
	result = string.gsub(result, "l", "w")
	result = string.gsub(result, "L", "W")
	result = string.gsub(result, "n", "ny")
	result = string.gsub(result, "N", "Ny")
	result = string.gsub(result, "ove", "uv")
	result = string.gsub(result, "OVE", "UV")
	result = string.gsub(result, "th", "d")
	result = string.gsub(result, "Th", "D")
	result = string.gsub(result, "TH", "D")
	result = string.gsub(result, "v", "w")
	result = string.gsub(result, "V", "W")
	result = string.gsub(result, "you", "youw")
	result = string.gsub(result, "You", "Youw")

	local chars = {}
	for i = 1, #result do
		table.insert(chars, result:sub(i, i))
		if math.random() > 0.7 and result:sub(i, i):match("[a-zA-Z]") then
			-- ad-add p-pa-pauses int-o output l-lik-like th-thisssss
			table.insert(chars, result:sub(i, i) .. "-")
		end
	end
	result = table.concat(chars)

	local affixes = {
		" :3",
		" >:3",
		" :333",
		" :3c",
		"!11!!",
		"!!!!",
		"!!!",
		"~~",
		"!!??!",
		"?!?!??",
		" >w<",
		" >.<",
		" owo",
		" OwO",
		" UwU",
		" nyaa~",
		" ^w^",
		" <3",
		" x3",
		" muah~",
		" :D",
		" hehe",
		" rawr",
		" prrr~",
		" ✧w✧",
		" hehehehe",
		" chu~",
		" ~nya",
		" kawaii~",
		" yay!!",
		" :DD",
		" *excited noises*",
		" wheee~~",
		" eheheheheheheh!",
		" heheheheh!!",
		" uheheheheheh!!",
		" uehh",
	}
	result = result .. affixes[math.random(#affixes)]

	return result
end

local function sendMessage(message)
	textChatService.TextChannels.RBXGeneral:SendAsync(message)
end

local function onChatEvent(state)
	if state then
		local alreadySentUwuified = false
		chatConnection = chatChannel.MessageReceived:Connect(function(messageObject)
			if not messageObject.TextSource or messageObject.TextSource.UserId ~= speakerUserId then
				return
			end
			if alreadySentUwuified then
				alreadySentUwuified = false
				return
			end
			if isAutoCutie then
				local original = messageObject.Text or ""
				local cutified = uwuifyString(original)
				if cutified ~= original then
					alreadySentUwuified = true
					chatChannel:SendAsync(cutified)
				end
			end
		end)
	else
		if chatConnection then
			chatConnection:Disconnect()
			chatConnection = nil
		end
	end
end

local Plugin = {
	["PluginName"] = "uwuify (formerly cutestring)",
	["PluginDescription"] = "format chat with cute uwu!!11~",
	["Commands"] = {
		["uwuify"] = {
			["ListName"] = "uwuify [string] / cuteify [string]",
			["Description"] = "makes a string cute",
			["Aliases"] = { "cuteify", "cutestring" },
			["Function"] = function(args, speaker)
				speakerUserId = speaker.UserId
				local output = uwuifyString(table.concat(args, " ") or args[1])
				if output then
					sendMessage(output)
					-- if setclipboard and type(setclipboard) == "function" then
					-- 	setclipboard(output)
					-- 	-- literally only sirhurt has this, hallo??
					-- end
				else
					notify("no output to send")
				end
			end,
		},
		["autouwuify"] = {
			["ListName"] = "autouwuify [boolean?]",
			["Description"] = "toggle uwuify per chat message >:3c",
			["Aliases"] = { "autocutie", "autouwu", "autocutestring" },
			["Function"] = function(args, speaker)
				speakerUserId = speaker.UserId
				local toggle = (args[1] or ""):lower()
				if toggle == "true" then
					isAutoCutie = true
					onChatEvent(true)
					notify(
						"auto-cutie mode on  (warn: original msg will be sent along, use uwuify instead if ure not lazy)"
					)
				elseif toggle == "false" then
					isAutoCutie = false
					onChatEvent(false)
					notify("auto-cutie mode off")
				else
					isAutoCutie = not isAutoCutie
					onChatEvent(isAutoCutie)
					notify(
						`auto-cutie mode toggled {isAutoCutie and "on  (warn: original msg will be sent along, use uwuify instead if ure not lazy)" or "off"}`
					)
				end
			end,
		},
	},
}

return Plugin
