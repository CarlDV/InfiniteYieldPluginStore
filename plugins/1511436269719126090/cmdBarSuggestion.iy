local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

-- cmdBar: used for hook
-- Cmdbar: original and property of iy's var (as mentioned 3000 years ago)
local cmdBar = Cmdbar and Cmdbar.ClassName == "TextBox" and Cmdbar or nil

local function isDesktop()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return false
	end
	return true
end

local function getTopCommand()
	if cmdBar and cmdBar.Text == "" then
		return nil
	end
	local typed = cmdBar.Text

	-- customaliases (I)
	for alias, entry in pairs(customAlias) do
		if alias:sub(1, #typed) == typed then
			return alias
		end
	end

	-- cmdaliases (II)
	for _, entry in ipairs(cmds) do
		local name = entry.NAME
		if not name then
			continue
		end
		for _, alias in ipairs(entry.ALIAS or {}) do
			if alias:sub(1, #typed) == typed then
				return name
			end
		end
	end

	-- cmd names (III)
	for _, entry in ipairs(cmds) do
		local name = entry.NAME
		if not name then
			continue
		end
		if name:sub(1, #typed) == typed then
			return name
		end
	end

	return nil
end

function partialAutoComplete()
	if not cmdBar then
		notify("cmdbarsuggest", "cant find CmdBar, please try on different version of infinite yield", 10)
		return
	end
	local overlay = Instance.new("TextButton")

	overlay.AutoButtonColor = false
	overlay.Parent = cmdBar.Parent
	overlay.BackgroundTransparency = 1
	overlay.TextColor3 = cmdBar.TextColor3:Lerp(Color3.new(0.5, 0.5, 0.5), 0.5)
	overlay.TextXAlignment = Enum.TextXAlignment.Left
	overlay.Font = cmdBar.Font
	overlay.TextSize = cmdBar.TextSize
	overlay.ZIndex = cmdBar.ZIndex + 1
	overlay.Size = UDim2.new(1, -4, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.Text = ""
	overlay.Name = "fyAutoComplete"

	cmdBar:GetPropertyChangedSignal("Text"):Connect(function()
		local text = cmdBar.Text
		local suggestion = getTopCommand()

		if text ~= "" and suggestion and suggestion ~= text then
			local remainder = suggestion:sub(#text + 1)
			local typedWidth = TextService:GetTextSize(text, cmdBar.TextSize, cmdBar.Font, Vector2.new(9999, 9999))
			local typedWidthX = typedWidth.X -- char's x width

			local xPos
			if cmdBar.TextXAlignment == Enum.TextXAlignment.Center then
				local containerWidth = cmdBar.Parent.AbsoluteSize.X
				xPos = (containerWidth / 2) + (typedWidthX / 2) + 4
			else
				xPos = typedWidthX + 4
			end

			overlay.Text = remainder .. `  ({isDesktop() and "TAB" or "TAP"})`
			overlay.Position = UDim2.new(0, xPos, 0, 0)
			overlay.Visible = true
		else
			overlay.Visible = false
		end
	end)

	overlay.MouseButton1Click:Connect(function()
		local topCommand = getTopCommand()
		if topCommand then
			autoComplete(topCommand, cmdBar.Text)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if not cmdBar:IsFocused() then
			return
		end

		local suggestion = getTopCommand()
		if not suggestion then
			return
		end

		if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.Right then
			autoComplete(suggestion, cmdBar.Text)
		end
	end)
end
partialAutoComplete()

local Plugin = {
	["PluginName"] = "cmdBarSuggestion",
	["PluginDescription"] = "suggests commands to your command bar, finite yield!",
	["Commands"] = {
		["cmdbarsuggest"] = {
			["ListName"] = "cmdbarsuggest",
			["Description"] = "suggests commands to your command bar",
			["Aliases"] = { "ALIAS1", "ALIAS2", "ALIAS3" },
			["Function"] = function(args, speaker)
				notify(
					"cmdbarsuggest",
					`{cmdBar and "already ran, u can remove plugin to stop" or "cant find CmdBar, please try on different version of infinite yield"}`,
					10
				)
			end,
		},
	},
}

return Plugin
