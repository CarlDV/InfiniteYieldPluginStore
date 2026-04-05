local Plugin = {
	["PluginName"] = "Fentanyl",
	["PluginDescription"] = "IY:FE stands for Infinite Yield: Fentanyl Enabled",
	["Commands"] = {
		["fent"] = {
			["ListName"] = "print [text]",
			["Description"] = "Gives 1 Fent",
			["Aliases"] = {"getfent"},
			["Function"] = function(args, speaker)
				local lp = speaker or game.Players.LocalPlayer
				local char = lp.Character
				local hum: Humanoid = char.Humanoid
				local animator: Animator = hum.Animator
				
				if not char or not hum then return end
				if hum.Health <= 0 then notify("Error", "You have to be alive to do fent") return end
				if hum.RigType.Value ~= 0 then notify("Error", "Doing fent is R6 only, R15 rigs are more civilized") return end
				
				local fent = Instance.new("Tool")
				local handle = Instance.new("Part")
				local mesh = Instance.new("SpecialMesh")
				local anim = Instance.new("Animation")
				local gui = Instance.new("ScreenGui")
				local overlay = Instance.new("Frame")
				local track: AnimationTrack
				
				anim.AnimationId = "rbxassetid://27753183"
				track = animator:LoadAnimation(anim)
				handle.Name = "Handle"
				handle.Size = Vector3.one
				handle.CanCollide, handle.CanTouch, handle.CanQuery = false, false, false
				mesh.MeshType = Enum.MeshType.FileMesh
				mesh.MeshId = "rbxassetid://122250743195815"
				mesh.TextureId = "rbxassetid://97378611424537"
				mesh.Scale = Vector3.one * 3
				gui.ClipToDeviceSafeArea = false
				gui.ScreenInsets = Enum.ScreenInsets.None
				overlay.Size = UDim2.fromScale(1, 1)
				overlay.BackgroundTransparency = 0.7
				overlay.Parent = gui
				mesh.Parent = handle
				handle.Parent = fent
				fent.CanBeDropped = false
				fent.Name = "Fent"
				fent.ToolTip = "yummy"
				
				fent.Activated:Connect(function()
					fent.Enabled = false
					fent.Grip = CFrame.Angles(0, 0, math.rad(90))
					track:Play()
					track.Stopped:Connect(function()
						fent:Destroy()
						
						local con = game["Run Service"].RenderStepped:Connect(function()
							overlay.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
						end)
						
						gui.Parent = lp.PlayerGui
						gui.Destroying:Connect(function() con:Disconnect() end)
					end)
				end)
				
				fent.Parent = lp.Backpack
			end
		}
	}
}

return Plugin
