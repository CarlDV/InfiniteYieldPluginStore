local ServiceDictionary = setmetatable({},{__index = function(self,index) return game:GetService(index) end})

shared["IYAimlock"] = false
shared["IYAimbot"] = false
shared["BreakLoops"] = false
shared["IYLocalUser"] = ServiceDictionary.Players.LocalPlayer
shared["IYPluginCreator"] = ServiceDictionary.Players:GetNameFromUserIdAsync(1708043824)

local plugin = {
	PluginName = ("More Commands 1.0");
	PluginDescription = ("More commands for Infinite Yield, created by " .. shared["IYPluginCreator"]);
	Commands = {
		["emote"] = {
			ListName = "emote [name]";
			Description = "Use an emote in the ROBLOX catalog.";
			Aliases = {};
			Function = function(args,speaker)
				local animations = {
					["Agree"]						= 4841397952;
					["Disagree"]					= 4841401869;
					["Power Blast"]					= 4841403964;
					["Happy"]						= 4841405708;
					["Sad"]							= 4841407203;
					["Bunny Hop"]					= 4641985101;
					["Peanut Butter Jelly Dance"] 	= 4406555273;
					["Around Town"]					= 3303391864;
					["Top Rock"]					= 3361276673;
					["Jumping Wave"]				= 4940564896;
					["Keeping Time"]				= 4555808220;
					["Fashionable"]					= 3333331310;
					["Robot"]						= 3338025566;
					["Twirl"]						= 3334968680;
					["Jacks"]						= 3338066331;
					["TPose"]						= 3338010159;
					["Shy"]							= 3337978742;
					["Monkey"]						= 3333499508;
					["Borock's Rage"]				= 3236842542;
					["Ud'zal's Summoning"]			= 3303161675;
					["Hype Dance"]					= 3695333486;
					["Godlike"]						= 3337994105;
					["Swoosh"]						= 3361481910;
					["Sneaky"]						= 3334424322;
					["Side to Side"]				= 3333136415;
					["Greatest"]					= 3338042785;
					["Louder"]						= 3338083565;
					["Celebrate"]					= 3338097973;
					["Haha"]						= 3337966527;
					["Get Out"]						= 3333272779;
					["Tree"]						= 4049551434;
					["Fishing"]						= 3334832150;
					["Fast Hands"]					= 4265701731;
					["Y"]							= 4349285876;
					["Zombie"]						= 4210116953;
					["Baby Dance"]					= 4265725525;
					["Line Dance"]					= 4049037604;
					["Dizzy"]						= 3361426436;
					["Shuffle"]						= 4349242221;
					["Dorky Dance"]					= 4212455378;
					["BodyBuilder"]					= 3333387824;
					["Idol"]						= 4101966434;
					["Fancy Feet"]					= 3333432454;
					["Curtsy"]						= 4555816777;
					["Air Dance"]					= 4555782893;
					["Chicken Dance"]				= 4841399916;
					["Sleep"]						= 4686925579;
					["Hero Landing"]				= 5104344710;
					["Confused"]					= 4940561610;
					["Cower"]						= 4940563117;
					["Tantrum"]						= 5104341999;
					["Bored"]						= 5230599789;
					["Beckon"]						= 5230598276;
					["Hello"]						= 3344650532;
					["Salute"]						= 3333474484;
					["Stadium"]						= 3338055167;
					["Tilt"]						= 3334538554;
					["Point"]						= 3344585679;
					["Shrug"]						= 3334392772;
				};
				local function playanimtrack(id)
					animationdebounce = true
					local Anim = Instance.new("Animation")
					Anim.AnimationId = "rbxassetid://"..id
					local salute = speaker.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(Anim)
					salute:Play()
					salute.Stopped:Connect(function()
						speaker.Character.Animate.Disabled = false
						animationdebounce = false
					end)
				end
				local gotanim = false
				local lower = string.lower(args[1])
				for i,v in pairs(animations) do
					if lower == string.sub(string.lower(tostring(i)), 1, #lower) and gotanim == false then
						gotanim = true
						playanimtrack(v)
					end
				end
				connection = speaker.Character:FindFirstChildOfClass("Humanoid").Running:Connect(function()
					pcall(function() connection:Disconnect() end)
					for index,value in pairs(speaker.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
						pcall(function() value:Stop() end)
					end
				end)
			end
		};
		["tpose"] = {
			ListName = "tpose";
			Description = "";
			Aliases = {};
			Function = function(args,speaker)
				local RunService = game:GetService("RunService")
				local Animation = Instance.new("Animation")
				Animation.AnimationId = "rbxassetid://27432691"
				tposeAnimation = speaker.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(Animation)
				tposeAnimation:Play()
				tposeAnimation:AdjustSpeed(1.5)
				repeat
					RunService.RenderStepped:Wait()
				until tposeAnimation.TimePosition >= 1.46
				tposeAnimation:AdjustSpeed(0)
			end
		};
		["untpose"] = {
			ListName = "untpose",
			Description = "",
			Aliases = {},
			Function = function()
				pcall(function() tposeAnimation:Stop() tposeAnimation:Destroy() end)
			end
		};
		["blockreach"] = {
			ListName = "blockreach / subreach [size]",
			Description = "Modify the held tool's Handle size by all Axis.",
			Aliases = {"subreach"},
			Function = function(args,speaker)
				local s,r = pcall(function()
					local size = args[1] ~= nil and args[1] or 100
					local tool = speaker.Character:FindFirstChildOfClass("Tool")
					local handle = tool:FindFirstChild("Handle")
					handle.CanCollide = false
					handle.Massless = true
					handle.Size = Vector3.new(tonumber(size),tonumber(size),tonumber(size))
					local selectionBox = Instance.new("SelectionBox")
					selectionBox.Name = "IYSelectionBox"
					selectionBox.Color3 = Color3.fromRGB(248,248,248)
					selectionBox.LineThickness = 0.1
					selectionBox.Visible = true
					selectionBox.Adornee = handle
					selectionBox.Parent = handle
					game:GetService("RunService").RenderStepped:Wait()
					speaker.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
					game:GetService("RunService").RenderStepped:Wait()
					speaker.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
				end)
				if not s then
					notify("Please have a tool with a Handle equipped, or else this will not work.")
				end
			end,
		};
		["loadstring"] = {
			ListName = "loadstring / runscript / script [code]",
			Description = "Run code using Infinite Yield.",
			Aliases = {"runscript","script"},
			Function = function(args,speaker)
				local s,r = pcall(function()
					local code = typeof(args) == "table" and table.concat(args," ") or tostring(args)
					return loadstring(code)()
				end)
				if not s then notify(r) end
			end
		};
		["qlog"] = {
			ListName = "qlog",
			Description = "Quickly copies all audios to your clipboard.",
			Aliases = {"logall"},
			Function = function(args,speaker)
				local logged = {}
				if not setclipboard then
					setclipboard = print
					notify("Your exploit does not support setclipboard, posted in Developer Console (F9) instead.")
				end
				for index,value in pairs(workspace:GetDescendants()) do
					if value:IsA("Sound") and value:FindFirstAncestorOfClass("Tool") then
						local audio = string.match(value.SoundId,"%d+")
						if not table.find(logged,audio) then
							shared["LOGGED_" .. tostring(audio)] = value:FindFirstAncestorOfClass("Tool").Name
							table.insert(logged,audio)
						end
					end
				end
				setclipboard(table.concat(logged,", "))
				coroutine.resume(coroutine.create(function()
					for index,value in pairs(logged) do
						local ProductInfo = ServiceDictionary.MarketplaceService:GetProductInfo(tonumber(value))
						print(string.format("[%s]",tostring(value)) .. string.format(":\n\tName = %s",ProductInfo.Name) .. string.format("\n\tTool = %s",shared["LOGGED_" .. tostring(value)]))
						shared["LOGGED_" .. tostring(value)] = nil
					end
					notify("All audio descriptions have been put inside of the Developer Console (F9).")
				end))
			end
		};
		["antiskid"] = {
			ListName = "antiskid [plr] (CLIENT)",
			Description = "Enables a loop that prevents other exploiters from FE-Killing you.",
			Aliases = {},
			Function = function(args,speaker)
				local players = getPlayer(args[1],speaker)
				antiSkidConnections = {}
				for index,value in pairs(players) do
					antiSkidConnections[#antiSkidConnections + 1] = value.CharacterAdded:Connect(function(character)
						repeat
							wait()
						until character:FindFirstChildWhichIsA("BackpackItem") and not character:FindFirstChildOfClass("Humanoid")
						character:Destroy()
					end)
				end
			end
		};
		["unantiskid"] = {
			ListName = "unantiskid",
			Description = "Disables the loop that prevents other exploiters from FE-Killing you.",
			Aliases = {},
			Function = function(args,speaker)
				for index,value in pairs(antiSkidConnections) do
					pcall(function() value:Disconnect() end)
				end
			end
		};
		["byteconvert"] = {
			ListName = "byteconvert",
			Description = "Converts the given string in \'string.byte\' format & copies it to your clipboard.",
			Aliases = {},
			Function = function(args,speaker)
				local stringval = table.concat(args," ")
				local ns = ""
				for i = 1,string.len(stringval) do
					ns = ns .. string.format("\\%s",string.byte(string.sub(stringval,i,i)))
				end
				if not setclipboard then
					setclipboard = print
					notify("Your exploit does not support setclipboard, posted in Developer Console (F9) instead.")
				end
				setclipboard(ns)
			end
		};
		["avatarcontext"] = {
			ListName = "avatarcontext [boolean]",
			Description = "Enable or disable the avatar context-menu.",
			Aliases = {},
			Function = function(args,speaker)
				contextenabled = not contextenabled
				ServiceDictionary.StarterGui:SetCore("AvatarContextMenuEnabled",contextenabled)
			end
		};
		["classicchat"] = {
			ListName = "classicchat",
			Description = "Enable the ClassicChat setting.",
			Aliases = {},
			Function = function(args,speaker)
				local PlayerGui = speaker:WaitForChild("PlayerGui")
				PlayerGui:WaitForChild("Chat")
				if PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible ~= true then
					PlayerGui.Chat.Frame.ChatBarParentFrame.Position = PlayerGui.Chat.Frame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(0,0),PlayerGui.Chat.Frame.ChatChannelParentFrame.Size.Y)
					PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible = true
					PlayerGui.Chat.Frame.ChatChannelParentFrame.Size = UDim2.new(1,0,1,-46)	
				end
			end
		};
		["bytechat"] = {
			ListName = "bytechat [msg]",
			Description = "Communicate through byte translation, good for bypassing the filter.",
			Aliases = {},
			Function = function(args,speaker)
				local realmessage = table.concat(args," ")
				local ns = ""
				for i = 1,string.len(realmessage) do
					ns = ns .. string.format("\\%s",string.byte(string.sub(realmessage,i,i)))
				end
				pcall(function() game:GetService("ReplicatedStorage")["DefaultChatSystemChatEvents"].SayMessageRequest:FireServer(ns,"All") end)
			end
		};
		["bytecomm"] = {
			ListName = "bytecomm",
			Description = string.format("Turns on %s's ByteComm communicator.",shared["IYPluginCreator"]),
			Aliases = {},
			Function = function(args,speaker)
				for _,player in pairs(ServiceDictionary.Players:GetPlayers()) do
					player.Chatted:Connect(function(message)
						local n_message = " " .. message
						if string.match(message,"%a") then
							return
						end
						local newstring = ""
						for index,value in pairs(string.split(n_message,[[\]])) do
							if index ~= 1 then
								newstring = newstring .. string.char(value)
							end	
						end
						ServiceDictionary.StarterGui:SetCore("ChatMakeSystemMessage",{
							Text = string.format("[%s]: ",player.Name) .. newstring,
						})
						return newstring
					end)
				end
				ServiceDictionary.Players.PlayerAdded:Connect(function(player)
					player.Chatted:Connect(function(message)
						local n_message = " " .. message
						if string.match(message,"%a") then
							return
						end
						local newstring = ""
						for index,value in pairs(string.split(n_message,[[\]])) do
							if index ~= 1 then
								newstring = newstring .. string.char(value)
							end	
						end
						ServiceDictionary.StarterGui:SetCore("ChatMakeSystemMessage"){
							Text = string.format("[%s]: ",player.Name) .. newstring,
						}
						return newstring
					end)
				end)
			end
		}
	};
};

return plugin