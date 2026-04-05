-- Gui2lua for the command line itself, from the official coregui command line.

local Converted = {
	["_CommandLine"] = Instance.new("Frame");
	["_InputField"] = Instance.new("Frame");
	["_TextBox"] = Instance.new("TextBox");
	["_Arrow"] = Instance.new("TextLabel");
}

-- Properties:

Converted["_CommandLine"].BackgroundColor3 = Color3.fromRGB(45.00000111758709, 45.00000111758709, 45.00000111758709)
Converted["_CommandLine"].BorderColor3 = Color3.fromRGB(184.00000423192978, 184.00000423192978, 184.00000423192978)
Converted["_CommandLine"].Position = UDim2.new(0, 0, 1, -30)
Converted["_CommandLine"].Size = UDim2.new(1, 0, 0, 30)
Converted["_CommandLine"].Name = "CommandLine"

Converted["_InputField"].BackgroundTransparency = 1
Converted["_InputField"].ClipsDescendants = true
Converted["_InputField"].Position = UDim2.new(0, 30, 0, 0)
Converted["_InputField"].Size = UDim2.new(1, -30, 0, 30)
Converted["_InputField"].Name = "InputField"
Converted["_InputField"].Parent = Converted["_CommandLine"]

Converted["_TextBox"].ClearTextOnFocus = false
Converted["_TextBox"].Font = Enum.Font.Code
Converted["_TextBox"].PlaceholderText = "command line"
Converted["_TextBox"].Text = ""
Converted["_TextBox"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_TextBox"].TextSize = 15
Converted["_TextBox"].TextXAlignment = Enum.TextXAlignment.Left
Converted["_TextBox"].BackgroundTransparency = 1
Converted["_TextBox"].Size = UDim2.new(1, 0, 1, 0)
Converted["_TextBox"].Parent = Converted["_InputField"]

Converted["_Arrow"].Font = Enum.Font.Code
Converted["_Arrow"].Text = "> "
Converted["_Arrow"].TextColor3 = Color3.fromRGB(255, 255, 255)
Converted["_Arrow"].TextSize = 15
Converted["_Arrow"].TextXAlignment = Enum.TextXAlignment.Right
Converted["_Arrow"].BackgroundTransparency = 1
Converted["_Arrow"].Size = UDim2.new(0, 30, 1, 0)
Converted["_Arrow"].Name = "Arrow"
Converted["_Arrow"].Parent = Converted["_CommandLine"]


local COMMAND_LINE = Converted["_CommandLine"]

-- Real scripting starts here...

local DevConsoleInjectEnabled = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandLineStorage = ReplicatedStorage:FindFirstChild("CommandLineStorage") or Instance.new("Folder")
CommandLineStorage.Name = "CommandLineStorage"
CommandLineStorage.Parent = ReplicatedStorage
CommandLineStorage:ClearAllChildren() -- remove duplicates

COMMAND_LINE.Parent = CommandLineStorage

-- reset the line to initial state
local function ResetCommandLine()
	if COMMAND_LINE.Parent ~= CommandLineStorage then
		COMMAND_LINE.Parent = CommandLineStorage
	end
	if COMMAND_LINE.InputField.TextBox.Text ~= "" then
		COMMAND_LINE.InputField.TextBox.Text = ""
	end
end

local Textbox = COMMAND_LINE.InputField.TextBox

-- execute handling
Textbox.FocusLost:Connect(function(enterPressed)
	if enterPressed == true then
		local commandText = Textbox.Text
		print("> " .. commandText)
		Textbox.Text = ""

		local success, errormsg = pcall(function()
			loadstring(commandText, "console")()
		end)

		-- oopsie error
		if not success then
			local filtered = errormsg:gsub("%[string \"console\"%]:", "console:") or errormsg
			game.TestService:Error(filtered)
		end
	end
end)

local dbg = false

function Pront(txt)
	if dbg == true then
		print(txt)
	end
end

-- scary inject loop
-- kinda trash but idc it works
spawn(function()
	while true do
		wait()
		local WillInject = true


		if DevConsoleInjectEnabled == false then
			ResetCommandLine()
			Pront("Not enabled")
			WillInject = false
		end
		local CoreGui = game.CoreGui
		local DevConsoleMaster = CoreGui:FindFirstChild("DevConsoleMaster")
		if not DevConsoleMaster then
			ResetCommandLine()
			Pront("No Master")
			WillInject = false
		end
		if DevConsoleMaster then
			local DevConsoleWindow = DevConsoleMaster:FindFirstChild("DevConsoleWindow")
			if not DevConsoleWindow then
				ResetCommandLine()
				Pront("No Window")
				WillInject = false
			end
			if DevConsoleWindow then
				if DevConsoleWindow.Visible == false then
					ResetCommandLine()
					Pront("No Window")
					WillInject = false
				end

				local DevConsoleUI = DevConsoleWindow:FindFirstChild("DevConsoleUI")
				if not DevConsoleUI then
					ResetCommandLine()
					Pront("No UI")
					WillInject = false
				end

				if WillInject == true then
					Pront("Injected")
					COMMAND_LINE.Parent = DevConsoleWindow
				end
			end
		end
	end
end)


local Plugin = {
	["PluginName"] = "Kommander",
	["PluginDescription"] = "Gives you the command line from the Developer Console, which executes with loadstring. It behaves like the server-side Command Line.\nRun ;inject true to enable it. Use an event bind to enable by default.",
	["Commands"] = {
		["ToggleLine"] = {
			["ListName"] = "inject [true/false]",
			["Description"] = "Toggles injecting the Command Line into the developer console. If false, the command line will be hidden.",
			["Aliases"] = {"inject"},
			["Function"] = function(args,speaker)
				if args[1] == "true" then
					DevConsoleInjectEnabled = true
					notify("Kommander","Injecting has been enabled. Try using the Developer Console!")
				elseif args[1] == "false" then
					DevConsoleInjectEnabled = false
					notify("Kommander","Injecting disabled.")
				else
					notify("bruh","Two options. 'true' or 'false'. PICK ONE!")
				end
			end
		},
	}
}

return Plugin
