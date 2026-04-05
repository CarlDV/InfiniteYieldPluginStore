h,withA,hrpA = Instance.new("HingeConstraint"),Instance.new("Attachment"),Instance.new("Attachment")
h.Name = "HingeGeneratedByGlueIYPlugin"
withA.Name = "AttachmentGeneratedByGlueIYPlugin"
hrpA.Name = "AttachmentGeneratedByGlueIYPlugin"
h.Visible = false
withA.Visible = false
hrpA.Visible = false

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    h:Destroy()
    withA:Destroy()
    hrpA:Destroy()
    h,withA,hrpA = Instance.new("HingeConstraint"),Instance.new("Attachment"),Instance.new("Attachment")
    h.Name = "HingeGeneratedByGlueIYPlugin"
    withA.Name = "AttachmentGeneratedByGlueIYPlugin"
    hrpA.Name = "AttachmentGeneratedByGlueIYPlugin"
    h.Visible = false
    withA.Visible = false
    hrpA.Visible = false
end)

glued = false
last = nil
rs = nil

local Plugin = { --Made by 👑Certified Gamer 👑#6509 / TheGuyMadeOfCheese#3391
    ["PluginName"] = "Glue",
    ["PluginDescription"] = "Allows you to stick to parts!",
    ["Commands"] = {
        ["glue"] = {
            ["ListName"] = "glue / stick",
            ["Description"] = "Run this to stick to parts!",
            ["Aliases"] = {"stick"},
            ["Function"] = function(args,speaker)
				local touched
				local legName
				if speaker.Character:FindFirstChild("Left Leg") then
					legName = "Left Leg"
				else
					legName = "LeftLowerLeg"
				end
				touched = speaker.Character[legName].Touched:Connect(function (with)
					if with.Parent ~= speaker.Character then
						glued = true
						touched:Disconnect()
						last = with
						speaker.Character.Humanoid.PlatformStand = true
						hrpA.Parent = speaker.Character.HumanoidRootPart
						hrpA.Position = -Vector3.new(0,3,0)
						withA.Parent = with
						withA.WorldPosition = hrpA.WorldPosition
						withA.WorldOrientation = speaker.Character.HumanoidRootPart.Orientation + Vector3.new(0,0,90)
						hrpA.WorldOrientation = speaker.Character.HumanoidRootPart.Orientation + Vector3.new(0,0,90)
						--speaker.Character.Humanoid:SetStateEnabled("RunningNoPhysics",true)
						h.Parent = speaker.Character.HumanoidRootPart
						h.Attachment0 = hrpA
						h.Attachment1 = withA
						execCmd('noclip nonotify')
				        for _,v in pairs(speaker.Character:GetChildren()) do if v:IsA("BasePart") then v.Massless = true end end
					end
				end)
            end
		},
        ["unglue"] = {
            ["ListName"] = "unglue / unstick",
            ["Description"] = "Run this to stop sticking to parts!",
            ["Aliases"] = {"unstick"},
            ["Function"] = function(args,speaker)
				glued = false
				speaker.Character.Humanoid.PlatformStand = false
				hrpA.Parent = nil
				withA.Parent = nil
				h.Parent = nil
				speaker.Character.Humanoid:SetStateEnabled("Landed",true)
				for _,v in pairs(speaker.Character:GetChildren()) do if v:IsA("BasePart") then v.Massless = false end end
				if rs ~= nil then
				    rs:Disconnect()    
				end
				last = nil
				execCmd('clip nonotify')
            end
        }
     }
}

return Plugin