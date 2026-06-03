local textChatService = game:GetService("TextChatService")
local chatChannel = textChatService.TextChannels.RBXGeneral
local chatConnection = nil

local isAutoCutie = false
local isRobloxChatExperienceUI = false
local speakerUserId = nil

local uwuifyFlag = {
	["stutter"] = true,
	["cuteaffix"] = true,
}

-- still cant figure out a way to intercept (or at least stop) msg on textChatService level so...
-- + hook into chat box + send btn
-- + handle sending chat out manually

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
	result = string.gsub(result, "ou", "ouw")

	if uwuifyFlag.stutter then
		local chars = {}
		for i = 1, #result do
			table.insert(chars, result:sub(i, i))
			if math.random() > 0.7 and result:sub(i, i):match("[a-zA-Z]") then
				-- ad-add p-pa-pauses int-o output l-lik-like th-thisssss
				table.insert(chars, result:sub(i, i) .. "-")
			end
		end
		result = table.concat(chars)
	end

	if uwuifyFlag.cuteaffix then
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
			" mmm~",
			" ✧w✧",
			" hehehehe",
			" chu~",
			" ~nya",
			" kawaii~",
			" yay!!",
			" :DD",
			" *excited*",
			" wheee~~",
			" eheheheheheheh!",
			" heheheheh!!",
			" uheheheheheh!!",
			" uehh",
		}
		result = result .. affixes[math.random(#affixes)]
	end

	return result
end

local function sendMessage(message)
	textChatService.TextChannels.RBXGeneral:SendAsync(message)
end

local function detectChatExperience()
	local success, result = pcall(function()
		return game:GetService("CoreGui"):FindFirstChild("ExperienceChat")
	end)
	if success and result then
		isRobloxChatExperienceUI = true
	else
		isRobloxChatExperienceUI = false
		notify("failed to find default experienceChat, please use `uwuify [string] instead`... ")
	end
end

detectChatExperience()

local function onChatEvent(state)
	if state then
		if not isRobloxChatExperienceUI then
			isAutoCutie = true
			return
		end

		local coreGui = game:GetService("CoreGui")
		local experienceChat = coreGui:FindFirstChild("ExperienceChat")
		if not experienceChat then
			return
		end

		local textBox =
			experienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox
		local sendBtn = experienceChat.appLayout.chatInputBar.Background.Container.SendButton
		if not textBox or not sendBtn then
			return
		end

		textBox.FocusLost:Connect(function(enterPressed)
			if enterPressed and isAutoCutie then
				local connections = getconnections(textBox.FocusLost)
				for _, con in pairs(connections) do
					con:Disable()
				end

				local msg = textBox.Text
				msg = uwuifyString(msg)
				sendMessage(msg)
				textBox.Text = ""

				for _, con in pairs(connections) do
					con:Enable()
				end
			end
		end)

		sendBtn.Activated:Connect(function()
			if isAutoCutie then
				local connections = getconnections(sendBtn.Activated)
				for _, con in pairs(connections) do
					con:Disable()
				end

				local msg = textBox.Text
				msg = uwuifyString(msg)
				sendMessage(msg)
				textBox.Text = ""

				for _, con in pairs(connections) do
					con:Enable()
				end
			end
		end)

		isAutoCutie = true
	else
		isAutoCutie = false
	end
end

local Plugin = {
	["PluginName"] = "uwuify (formerly cutestring)",
	["PluginDescription"] = "spices up your chat with cute uwus!!11~ (v1.1)",
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
					if setclipboard and type(setclipboard) == "function" then
						setclipboard(output)
						-- literally only sirhurt has this, hallo??
					end
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
					notify("auto-cutie mode on!")
				elseif toggle == "false" then
					isAutoCutie = false
					onChatEvent(false)
					notify("auto-cutie mode off!")
				else
					isAutoCutie = not isAutoCutie
					onChatEvent(isAutoCutie)
					notify(`auto-cutie mode toggled {isAutoCutie and "on!" or "off!"}`)
				end
			end,
		},
		["uwuifyFlag"] = {
			["ListName"] = "uwuifyflag [stutter | cuteAffix] [boolean?]",
			["Description"] = "toggle uwuify flag (stutter/cuteaffix)",
			["Aliases"] = { "cutestringflag", "uwuflag" },
			["Function"] = function(args, speaker)
				local flag = (args[1] or ""):lower()
				local toggle = (args[2] or ""):lower()

				if flag ~= "stutter" and flag ~= "cuteaffix" then
					notify("invalid flag: " .. flag .. " required (stutter/cuteaffix)")
					return
				end

				if toggle == "true" or toggle == "false" then
					uwuifyFlag[flag] = toggle == "true" and true or false
				else
					uwuifyFlag[flag] = not uwuifyFlag[flag]
				end
				notify(`flag {flag} set to {uwuifyFlag[flag] and "on!" or "off!"}`)
			end,
		},
	},
}

return Plugin
