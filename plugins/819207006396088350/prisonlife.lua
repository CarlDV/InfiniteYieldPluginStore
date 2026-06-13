local PluginAPI = loadstring(game:HttpGet("https://pastebin.com/raw/u7HEbm8q"))()
local Plugin = PluginAPI:CreatePlugin("Prison Life Plugin", "made by lolpippiou")
Plugin.Functions:AddCommand("givetools", "givetools",  "Gives you every tool.", {"giveitems", "gt"}, function(args, speaker) 
    workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)
	workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver["AK-47"].ITEMPICKUP)
	workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver.M9.ITEMPICKUP)
	workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.single["Crude Knife"].ITEMPICKUP)
	workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.single.Hammer.ITEMPICKUP)
end)
Plugin.Functions:AddCommand("plkill", "plkill [plr]", "Kills any player. (FIXED, KILL ALL TAKES A WHILE)", {"die"}, function(args, speaker)
	for i, plr in pairs(getPlayer(args[1])) do
		game.Workspace.Remote.ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP) 
		
		wait(0.1)
		Workspace.Remote.TeamEvent:FireServer("Medium stone grey")
		
		local A_1 = 
		{
			[1] = 
		{
			["RayObject"] = Ray.new(Vector3.new(827.412415, 101.489777, 2296.84326), Vector3.new(277.738678, 6.89340925, 287.773712)), 
			["Distance"] = 4.7204174995422, 
			["Cframe"] = CFrame.new(832.049377, 101.392006, 2300.97168, 0.843892097, -0.0554918349, 0.533635378, 0, 0.994636595, 0.103430569, -0.536512911, -0.0872842371, 0.839366019), 
			["Hit"] = game.Workspace:FindFirstChild(plr).Head
		}, 
			[2] = 
		{
			["RayObject"] = Ray.new(Vector3.new(827.412415, 101.489777, 2296.84326), Vector3.new(303.047546, 21.3568707, 260.203888)), 
			["Distance"] = 4.8114862442017, 
			["Cframe"] = CFrame.new(832.390259, 101.550629, 2300.74097, 0.738044441, -0.112958886, 0.665229917, 7.45057971e-09, 0.985887885, 0.16740793, -0.674752235, -0.123554483, 0.727628946), 
			["Hit"] = game.Workspace:FindFirstChild(plr).Head
		}, 
			[3] = 
		{
			["RayObject"] = Ray.new(Vector3.new(827.412415, 101.489777, 2296.84326), Vector3.new(296.800507, 7.00420141, 268.067932)), 
			["Distance"] = 4.444625377655, 
			["Cframe"] = CFrame.new(832.185486, 101.391617, 2300.70264, 0.775115669, -0.0692948848, 0.628007889, 7.45057971e-09, 0.993967533, 0.109675139, -0.631819367, -0.0850109085, 0.770439863), 
			["Hit"] = game.Workspace:FindFirstChild(plr).Head
		}, 
			[4] = 
		{
			["RayObject"] = Ray.new(Vector3.new(827.412415, 101.489777, 2296.84326), Vector3.new(284.930573, 11.9850616, 280.483368)), 
			["Distance"] = 4.6211166381836, 
			["Cframe"] = CFrame.new(832.10083, 101.445007, 2300.86963, 0.820150614, -0.0735745132, 0.567397356, 0, 0.991697431, 0.128593579, -0.572147667, -0.105466105, 0.81334126), 
			["Hit"] = game.Workspace:FindFirstChild(plr).Head
		}, 
			[5] = 
		{
			["RayObject"] = Ray.new(Vector3.new(827.412415, 101.489777, 2296.84326), Vector3.new(294.625824, 2.15741801, 270.538269)), 
			["Distance"] = 4.4639973640442, 
			["Cframe"] = CFrame.new(832.169434, 101.341301, 2300.73438, 0.784266233, -0.0537625961, 0.618090749, -3.7252903e-09, 0.99623847, 0.086654529, -0.620424569, -0.0679602176, 0.781316102), 
			["Hit"] = game.Workspace:FindFirstChild(plr).Head
		}
		}
		local A_2 = game.Players.LocalPlayer.Backpack["Remington 870"]
		local Event = game:GetService("ReplicatedStorage").ShootEvent
		local position = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace:FindFirstChild(plr).HumanoidRootPart.CFrame + Vector3.new(3, 1, 0)
		wait(0.1)
		Event:FireServer(A_1, A_2)
		wait(0.1)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = position
		
		wait(0.25)
		workspace.Remote.TeamEvent:FireServer("Bright orange")
		wait(0.25)
	end
end)
Plugin.Functions:AddCommand("plteamr", "plteamr [team]", "Changes your team and respawns. You can use these: Guards, Inmates, Neutral, Criminals", {}, function(args, speaker)
	local team = args[1]
	if team == "Guards" then
		workspace.Remote.TeamEvent:FireServer("Bright blue")
		workspace.Remote.loadchar:InvokeServer()
	elseif team == "Inmates" then
		workspace.Remote.TeamEvent:FireServer("Bright orange")
		workspace.Remote.loadchar:InvokeServer()
	elseif team == "Neutral" then
		workspace.Remote.TeamEvent:FireServer("Medium stone grey")
	elseif team == "Criminals" then
		local Apart = Instance.new("Part")

		Apart.Name = "PlrsPos"
		Apart.Parent = workspace
		Apart.Anchored = true
		Apart.Archivable = true
		Apart.CFrame = CFrame.new(9e99, 9e99, 9e99)

		LCS = game.Workspace["Criminals Spawn"].SpawnLocation
	
		_G.killAura = true
		wait(0.2)
	
		Apart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		Apart.Transparency = 1
		Apart.Anchored = true
		Apart.CanCollide = false
	
		istptoplr = true
		wait(0.004)
			
			
		LCS = game.Workspace["Criminals Spawn"].SpawnLocation

		LCS.CanCollide = false
		LCS.Size = Vector3.new(51.05, 24.12, 54.76)
		LCS.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		LCS.Transparency = 1
		
		wait(2)
		
		istptoplr = false
		_G.killAura = false
		
		wait(0.04)
		
		if istptoplr == false then
		    LCS.CFrame = CFrame.new(-920.510803, 92.2271957, 2138.27002, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		    LCS.Size = Vector3.new(6, 0.2, 6)
		    LCS.Transparency = 0
		    istptoplr = false
		end
		
		workspace.Remote.loadchar:InvokeServer()
	end
end)
Plugin.Functions:AddCommand("plteam", "plteam [team]", "Changes your team without respawning. You can use these: Guards, Inmates, Neutral, Criminals", {}, function(args, speaker)
	local team = args[1]
	if team == "Guards" then
		workspace.Remote.TeamEvent:FireServer("Bright blue")
	elseif team == "Inmates" then
		workspace.Remote.TeamEvent:FireServer("Bright orange")
	elseif team == "Neutral" then
		workspace.Remote.TeamEvent:FireServer("Medium stone grey")
	elseif team == "Criminals" then
		local Apart = Instance.new("Part")

		Apart.Name = "PlrsPos"
		Apart.Parent = workspace
		Apart.Anchored = true
		Apart.Archivable = true
		Apart.CFrame = CFrame.new(9e99, 9e99, 9e99)

		LCS = game.Workspace["Criminals Spawn"].SpawnLocation
	
		_G.killAura = true
		wait(0.2)
	
		Apart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		Apart.Transparency = 1
		Apart.Anchored = true
		Apart.CanCollide = false
	
		istptoplr = true
		wait(0.004)
			
			
		LCS = game.Workspace["Criminals Spawn"].SpawnLocation

		LCS.CanCollide = false
		LCS.Size = Vector3.new(51.05, 24.12, 54.76)
		LCS.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		LCS.Transparency = 1
		
		wait(2)
		
		istptoplr = false
		_G.killAura = false
		
		wait(0.04)
		
		if istptoplr == false then
		    LCS.CFrame = CFrame.new(-920.510803, 92.2271957, 2138.27002, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		    LCS.Size = Vector3.new(6, 0.2, 6)
		    LCS.Transparency = 0
		    istptoplr = false
		end
	end
end)
Plugin.Functions:AddCommand("arrest", "arrest [plr]", "Arrests any player.", {}, function(args, speaker)
	for i, plr in pairs(getPlayer(args[1], speaker)) do
		local position = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace:FindFirstChild(plr).HumanoidRootPart.CFrame
		wait(0.25)
		workspace.Remote.arrest:InvokeServer(workspace:FindFirstChild(plr).HumanoidRootPart)
		wait(0.25)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = position
	end
end)
Plugin.Functions:AddCommand("loopbringgui", "loopbringgui", "Loads the loopbring GUI by Jake11price.", {}, function(args, speaker)
	--//  Made By Jake11price, i am not taking any credit.

	local playerchar = (game.Players.LocalPlayer.Character)
	local gui = Instance.new("ScreenGui")
	local main = Instance.new("Frame")
	local Bringmain = Instance.new("Frame")
	local Bringtext = Instance.new("TextBox")
	local Credits = Instance.new("TextLabel")
	local Bringoffmain = Instance.new("Frame")
	local Bringoff = Instance.new("TextButton")
	local Bringonmain = Instance.new("Frame")
	local Bringon = Instance.new("TextButton")

	gui.Name = "gui"
	gui.Parent = game.CoreGui

	main.Name = "main"
	main.Parent = gui
	main.BackgroundColor3 = Color3.new(0, 0, 0)
	main.Position = UDim2.new(0.132017255, 0, 0.617936134, 0)
	main.Size = UDim2.new(0, 161, 0, 100)
	main.Active = true
	main.Draggable = true

	Bringmain.Name = "Bringmain"
	Bringmain.Parent = main
	Bringmain.BackgroundColor3 = Color3.new(0, 0, 0)
	Bringmain.Position = UDim2.new(0, 0, -0.100000001, 0)
	Bringmain.Size = UDim2.new(0, 161, 0, 110)

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local function RemoveSpaces(String)
		return String:gsub("%s+", "") or String
	end

	local function FindPlayer(String)
		String = RemoveSpaces(String)
		for _, _Player in pairs(Players:GetPlayers()) do
			if _Player.Name:lower():match('^'.. String:lower()) then
				return _Player
			end
		end
		return nil
	end

	Bringtext.Name = "Bringtext"
	Bringtext.Parent = Bringmain
	Bringtext.BackgroundColor3 = Color3.new(1, 1, 1)
	Bringtext.Position = UDim2.new(0, 0, 0.232727259, 0)
	Bringtext.Size = UDim2.new(0, 161, 0, 41)
	Bringtext.Font = Enum.Font.SciFi
	Bringtext.Text = ""
	Bringtext.TextColor3 = Color3.new(0, 0, 0)
	Bringtext.TextSize = 14

	Credits.Name = "Credits"
	Credits.Parent = Bringmain
	Credits.BackgroundColor3 = Color3.new(0.333333, 1, 0)
	Credits.Size = UDim2.new(0, 161, 0, 25)
	Credits.Font = Enum.Font.GothamBold
	Credits.Text = "LOOPBRING"
	Credits.TextColor3 = Color3.new(0, 0, 0)
	Credits.TextSize = 14

	Bringoffmain.Name = "Bringoffmain"
	Bringoffmain.Parent = Bringmain
	Bringoffmain.BackgroundColor3 = Color3.new(1, 1, 1)
	Bringoffmain.Position = UDim2.new(0, 0, 0.609090924, 0)
	Bringoffmain.Size = UDim2.new(0, 161, 0, 43)

	Bringoff.Name = "Bringoff"
	Bringoff.Parent = Bringoffmain
	Bringoff.BackgroundColor3 = Color3.new(1, 0, 0)
	Bringoff.Position = UDim2.new(-0.00621099072, 0, 0, 0)
	Bringoff.Size = UDim2.new(0, 161, 0, 43)
	Bringoff.Font = Enum.Font.Highway
	Bringoff.Text = "Loop Bring (OFF)"
	Bringoff.TextColor3 = Color3.new(0, 0, 0)
	Bringoff.TextSize = 14
	Bringoff.MouseButton1Down:connect(function()
	Bringoffmain.Visible = false
	Bringonmain.Visible = true
	_G.Bringplr = true
	local player = FindPlayer(Bringtext.Text)
	Players.PlayerRemoving:Connect(function(playerleft)
	if playerleft.Name == (player.Name) then
	_G.Bringplr = false
	Bringonmain.Visible = false
	Bringoffmain.Visible = true
	end
	end)
	if player and player.Character then
	NOW = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
	repeat local player = FindPlayer(Bringtext.Text)
	game.Players.LocalPlayer.Character.Humanoid.Sit = false

	for i,v in pairs(Workspace.Prison_ITEMS.giver:GetChildren()) do
		if v.Name == "M9" then
		   lol = Workspace.Remote.ItemHandler:InvokeServer(v.ITEMPICKUP)
		end
	end
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
	game.Players.LocalPlayer.Character.Humanoid.Name = 1
	local l = game.Players.LocalPlayer.Character["1"]:Clone()
	if game.Players.LocalPlayer.Character["1"] then
	l.Parent = game.Players.LocalPlayer.Character
	l.Name = "Humanoid"
	wait()
	game.Players.LocalPlayer.Character["1"]:Destroy()
	game.Workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character
	game.Players.LocalPlayer.Character.Animate.Disabled = true
	end
	wait()
	game.Players.LocalPlayer.Character.Animate.Disabled = false
	game.Players.LocalPlayer.Character.Humanoid.DisplayDistanceType = "None"
	for i,v in pairs(game:GetService'Players'.LocalPlayer.Backpack:GetChildren())do
		if v.Name == "M9" then
	game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
	end
	end
	player.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame 
	wait(0.3)
	local A_1 = "\66\114\111\121\111\117\98\97\100\100"
	local Event = game:GetService("Workspace").Remote.loadchar
	Event:InvokeServer(A_1)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
			until _G.Bringplr == false
	end
	end)

	Bringonmain.Name = "Bringonmain"
	Bringonmain.Parent = Bringmain
	Bringonmain.BackgroundColor3 = Color3.new(1, 1, 1)
	Bringonmain.Position = UDim2.new(0, 0, 0.609090805, 0)
	Bringonmain.Size = UDim2.new(0, 161, 0, 43)
	Bringonmain.Visible = false

	Bringon.Name = "Bringon"
	Bringon.Parent = Bringonmain
	Bringon.BackgroundColor3 = Color3.new(0.333333, 1, 0)
	Bringon.Position = UDim2.new(-0.0062110424, 0, -1.11758709e-08, 0)
	Bringon.Size = UDim2.new(0, 161, 0, 43)
	Bringon.Font = Enum.Font.Highway
	Bringon.Text = "Loop Bring (ON)"
	Bringon.TextColor3 = Color3.new(0, 0, 0)
	Bringon.TextSize = 14
	Bringon.MouseButton1Down:connect(function()
	Bringonmain.Visible = false
	Bringoffmain.Visible = true
	_G.Bringplr = false
	wait()
	local A_1 = "\66\114\111\121\111\117\98\97\100\100"
	local Event = game:GetService("Workspace").Remote.loadchar
	Event:InvokeServer(A_1)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
	end)

	game:GetService('RunService').Stepped:connect(function()
	if _G.Bringplr == true then
	game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
	local player = FindPlayer(Bringtext.Text)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW
	player.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = NOW * CFrame.new(0,1,0)
	end
	end)
end)
Plugin.Functions:AddCommand("superpunch", "superpunch", "Everytime you punch somebody, the person dies instantly.", {}, function(args, speaker)
	mainRemotes = game.ReplicatedStorage meleeRemote = mainRemotes['meleeEvent'] mouse = game.Players.LocalPlayer:GetMouse() punching = false cooldown = false function punch() cooldown = true local part = Instance.new("Part", game.Players.LocalPlayer.Character) part.Transparency = 1 part.Size = Vector3.new(5, 2, 3) part.CanCollide = false local w1 = Instance.new("Weld", part) w1.Part0 = game.Players.LocalPlayer.Character.Torso w1.Part1 = part w1.C1 = CFrame.new(0,0,2) part.Touched:connect(function(hit) if game.Players:FindFirstChild(hit.Parent.Name) then local plr = game.Players:FindFirstChild(hit.Parent.Name) if plr.Name ~= game.Players.LocalPlayer.Name then part:Destroy() for i = 1,100 do meleeRemote:FireServer(plr) end end end end) wait(1) cooldown = false part:Destroy() end mouse.KeyDown:connect(function(key) if cooldown == false then if key:lower() == "f" then punch() end end end)
end)
return Plugin.PluginTable