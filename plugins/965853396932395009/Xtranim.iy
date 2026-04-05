local hitmode = false
local sitmode = false
local dashmode = false

local Plugin = {
    ["PluginName"] = "Xtra Animation",
    ["PluginDescription"] = "made by D7M",
    ["Commands"] = {
	
        ["Hit"] = {
            ["ListName"] = "Hit [toggle mode]",
            ["Description"] = "Random Hit Animation on Clicking",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
			

				for _, v in pairs(Players.LocalPlayer.Character:GetChildren()) do
					if v:IsA('Tool') or v:IsA('HopperBin') then
						v.Animation.AnimationId = " "
					end
				end
			
				if not hitmode then
				hitmode = true
				notify("D7M","Hitmode: On")
				
				local play = false
				hitAnim = Instance.new("Animation")
				local Player = Game.Players.LocalPlayer
				local Mouse = Player:GetMouse()
					hitclick = Mouse.Button1Down:Connect(function()
					
					if not play then 
					play = true 
					

					for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
					track:Stop()
					game.Players.LocalPlayer.Character.Animate.Disabled = true
					end
						if speaker.Character:FindFirstChildOfClass('Humanoid').Jump == true then
						randomanim = math.random(12, 13)
						else
						randomanim = math.random(1, 13) 
						end
						if randomanim == 1 then
							hitAnim.AnimationId = "rbxassetid://3334832150"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 0.4
							wait(.5)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 2 then
							hitAnim.AnimationId = "rbxassetid://3334832150"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1
							hit:AdjustSpeed(0.1)
							wait(.3)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 3 then
							hitAnim.AnimationId = "rbxassetid://3334968680"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1.2
							wait(.4)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 4 then
							hitAnim.AnimationId = "rbxassetid://3236842542"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 3.1
							wait(.6)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 5 then
							hitAnim.AnimationId = "rbxassetid://7202863182"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 5.1
							wait(.3)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 6 then
							hitAnim.AnimationId = "rbxassetid://7202863182"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 5.38
							wait(.7)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 7 then
							hitAnim.AnimationId = "rbxassetid://4841403964"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1.2
							wait(.9)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 8 then
							hitAnim.AnimationId = "rbxassetid://3695300085"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1.3
							wait(.5)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 9 then
							hitAnim.AnimationId = "rbxassetid://3337966527"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, -1)
							hit.TimePosition = .7
							wait(.9)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 10 then
							hitAnim.AnimationId = "rbxassetid://3334832150"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, -1)
							hit.TimePosition = 3.8
							wait(1)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
							elseif randomanim == 11 then
							hitAnim.AnimationId = "rbxassetid://3334968680"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, -1)
							hit.TimePosition = 1.6
							wait(.5)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
							elseif randomanim == 12 then
							hitAnim.AnimationId = "rbxassetid://5104344710"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = .5
							for i = 1, 15 do
							getRoot(speaker.Character).CFrame = getRoot(speaker.Character).CFrame * CFrame.new(0,0,-0.1)  * CFrame.Angles(0,math.rad(0),0)
							wait()
							end 
							wait(.2)
							play = false
							execCmd('refreshanim')
							elseif randomanim == 13 then
							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hitAnim.AnimationId = "rbxassetid://5104344710"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, -1)
							hit.TimePosition = 1.1
							for i = 1, 15 do
							getRoot(speaker.Character).CFrame = getRoot(speaker.Character).CFrame * CFrame.new(0,0,-0.2)  * CFrame.Angles(0,math.rad(0),0)
							wait()
							end 
							wait(.7)
							play = false
							execCmd('refreshanim')
							
						end 
					end
					end)
					
				else 
				hitclick:Disconnect()
				hitmode = false
				notify("D7M","Hitmode: Off")
				end 
				
				
				
			
				
            end
        },

        ["Punch"] = {
            ["ListName"] = "Punch [toggle mode]",
            ["Description"] = "Only Punch Animation on Clicking",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
			
						
				if not hitmode then
				hitmode = true
				notify("D7M","Punchmode: On")
				
				hitAnim = Instance.new("Animation")
				local Player = Game.Players.LocalPlayer
				local Mouse = Player:GetMouse()
					hitclick = Mouse.Button1Down:Connect(function()
					if not play then 
					play = true 
					
					for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
						local randomanim = math.random(1, 3)
						if randomanim == 1 then
							hitAnim.AnimationId = "rbxassetid://7202863182"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 5.38
							wait(.7)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 2 then
							hitAnim.AnimationId = "rbxassetid://7202863182"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 5.1
							wait(.3)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						elseif randomanim == 3 then
							hitAnim.AnimationId = "rbxassetid://4841403964"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1.2
							wait(.7)
							hit:AdjustSpeed(0)
							wait(.2)
							play = false
							execCmd('refreshanim')
						end 
					end
					end)
					
				else 
				hitclick:Disconnect()
				hitmode = false
				notify("D7M","Punchmode: Off")
				end 
			
			end
		},
    
	    ["hug"] = {
		    ["ListName"] = "Hug",
            ["Description"] = "Hug Animation",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)

							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hitAnim.AnimationId = "rbxassetid://4210116953"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 0)
							hit.TimePosition = 3
							
			end
		},
    
	    ["sitdown"] = {
		    ["ListName"] = "Sitdown",
            ["Description"] = "Random Sit Pose",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
						if not sitmode then
						sitmode = true  
							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							
							hitAnim.AnimationId = "rbxassetid://5104344710"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 0)
							hit.TimePosition = 2

						else
						sitmode = false 
							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hitAnim.AnimationId = "rbxassetid://5915648917"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 0)
							hit.TimePosition = 1
						end 
			end
		},
		
		["handsup"] = {
		    ["ListName"] = "Handsup",
            ["Description"] = "Handsup Pose",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
			
			
							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hitAnim.AnimationId = "rbxassetid://3338066331"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 0)
							hit.TimePosition = 1.6
			end
		},
		
		["spank"] = {
		    ["ListName"] = "Spank",
            ["Description"] = "Spank animation",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
			
							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hitAnim.AnimationId = "rbxassetid://3695300085"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1.3
							wait(.5)
							hit:AdjustSpeed(0)
							wait(.2)
							execCmd('refreshanim')
			
			end
		},
			
		["dash"] = {
		    ["ListName"] = "dash",
            ["Description"] = "dash mode",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
			
			if not dashmode then
				dashmode = true
				notify("D7M","Dashmode: On use Q/E to activate")

							hit2Anim = Instance.new("Animation")
							hit2Anim.AnimationId = "rbxassetid://3333499508"
							dash = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
							hit2 = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hit2Anim)
							
							if input.KeyCode == Enum.KeyCode.E then
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hit2:Play(.1, 1, 0)
							hit2.TimePosition = 1.5
							for i = 1, 3 do
							getRoot(speaker.Character).CFrame = getRoot(speaker.Character).CFrame * CFrame.new(1,0,0)  * CFrame.Angles(0,math.rad(0),0)
							wait()
							end
							wait(.1)
							execCmd('refreshanim')
							elseif input.KeyCode == Enum.KeyCode.Q then
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hit2:Play(.1, 1, 0)
							hit2.TimePosition = 3.8
							for i = 1, 3 do
							getRoot(speaker.Character).CFrame = getRoot(speaker.Character).CFrame * CFrame.new(-1,0,0)  * CFrame.Angles(0,math.rad(0),0)
							wait()
							end 
							wait(.1)
							execCmd('refreshanim')
							
							end
							end)
			else 
			dashmode = false
			dash:Disconnect()
			notify("D7M","Dashmode: Off")
			end
			end
		},
		
		["twrk"] = {
		    ["ListName"] = "Twrk",
            ["Description"] = "Twrk ig",
            ["Aliases"] = {""},
            ["Function"] = function(args,speaker)
			
							hitAnim = Instance.new("Animation")
							for i, track in pairs (game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
							track:Stop()
							game.Players.LocalPlayer.Character.Animate.Disabled = true
							end
							hitAnim.AnimationId = "rbxassetid://6797888062"
							hit = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(hitAnim)
							hit:Play(.1, 1, 1)
							hit.TimePosition = 1.2
							wait(.9)
							hit:AdjustSpeed(0)
							wait(.2)
							execCmd('refreshanim')
							
			end
		},
	}
}

return Plugin
