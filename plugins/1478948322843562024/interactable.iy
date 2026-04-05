-- spaguetti code that was copy and pasted 1000 times
-- don't even bother editing this just look for the original version ap sent and start from there

local hui = gethui()
local veryinconspicuous = hui:FindFirstChild("interactable esp") or Instance.new("Folder")
veryinconspicuous.Name = "interactable esp"
veryinconspicuous.Parent = hui

local function find(name)
    local f = veryinconspicuous:FindFirstChild(name)
    if not f then
        f = Instance.new("Folder")
        f.Name = name
        f.Parent = veryinconspicuous
    end
    return f
end

local function antiisraeli(a)
    a.Adornee.AncestryChanged:Connect(function(_, parent)
        if not parent then
            a:Destroy()
        end
    end)
end


local Plugin = {
    ["PluginName"] = "interactable objects esp",
    ["PluginDescription"] = "cd = red, pp = green, ti = yellow, seat = light blue, unanchored = purple, no collision = brown, npc = gray",
    ["Commands"] = {

        ["clickdetectoresp"] = {
            ["ListName"] = "clickdetectoresp/clickesp/cdesp",
            ["Description"] = "allows esp for blocks with a clickdetector",
            ["Aliases"] = {"clickesp", "cdesp"},
            ["Function"] = function(args, speaker)
                getgenv().cdesp_enabled = true
                if getgenv().cdesp_conn then getgenv().cdesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("ClickDetector") and v.Parent:IsA("BasePart") then
                if not v.Parent:FindFirstChild("clickdetector esp") then
                local a = Instance.new("BoxHandleAdornment")
			a.Name = "clickdetector esp"
			a.Parent = find("clickdetector esp")
			a.Adornee = v.Parent
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = v.Parent.Size
			a.Transparency = 0.55
			a.Color = BrickColor.new("Really red")
			antiisraeli(a)
                end
                end
                end

                getgenv().cdesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().cdesp_enabled then return end
                    if v:IsA("ClickDetector") and v.Parent:IsA("BasePart") then
                        if v.Parent:FindFirstChild("clickdetector esp") then return end
                        local a = Instance.new("BoxHandleAdornment")
			            a.Name = "clickdetector esp"
			            a.Parent = find("clickdetector esp")
			            a.Adornee = v.Parent
			            a.AlwaysOnTop = true
			            a.ZIndex = 0
			            a.Size = v.Parent.Size
			            a.Transparency = 0.55
			            a.Color = BrickColor.new("Really red")
				    antiisraeli(a)
                    end
                end)
            end
        },
        ["proximityesp"] = {
            ["ListName"] = "proximityesp/promptesp/ppesp",
            ["Description"] = "allows esp for blocks with a proximityprompt",
            ["Aliases"] = {"promptesp", "ppesp"},
            ["Function"] = function(args, speaker)
                getgenv().ppesp_enabled = true
                if getgenv().ppesp_conn then getgenv().ppesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
                if not v.Parent:FindFirstChild("proximity esp") then
                local a = Instance.new("BoxHandleAdornment")
			a.Name = "proximity esp"
			a.Parent = find("proximity esp")
			a.Adornee = v.Parent
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = v.Parent.Size
			a.Transparency = 0.55
			a.Color = BrickColor.new("Lime green")
			antiisraeli(a)
                end
                end
                end

                getgenv().ppesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().ppesp_enabled then return end
                    if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
                        if v.Parent:FindFirstChild("proximity esp") then return end
                        local a = Instance.new("BoxHandleAdornment")
			            a.Name = "proximity esp"
			            a.Parent = find("proximity esp")
			            a.Adornee = v.Parent
			            a.AlwaysOnTop = true
			            a.ZIndex = 0
			            a.Size = v.Parent.Size
			            a.Transparency = 0.55
			            a.Color = BrickColor.new("Lime green")
				    antiisraeli(a)
                    end
                end)
            end
        },
        ["touchinterestesp"] = {
            ["ListName"] = "touchinterestesp/touchesp/tesp",
            ["Description"] = "allows esp for blocks with a touchinterest",
            ["Aliases"] = {"touchesp", "tesp"},
            ["Function"] = function(args, speaker)
                getgenv().tesp_enabled = true
                if getgenv().tesp_conn then getgenv().tesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("TouchTransmitter") and v.Parent:IsA("BasePart") then
                if not v.Parent:FindFirstChild("touchinterest esp") then
                local a = Instance.new("BoxHandleAdornment")
            a.Name = "touchinterest esp"
            a.Parent = find("touchinterest esp")
            a.Adornee = v.Parent
            a.AlwaysOnTop = true
            a.ZIndex = 0
            a.Size = v.Parent.Size
            a.Transparency = 0.55
            a.Color = BrickColor.new("New Yeller")
	    antiisraeli(a)
                end
                end
                end

                getgenv().tesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().tesp_enabled then return end
                    if v:IsA("TouchTransmitter") and v.Parent:IsA("BasePart") then
                        if v.Parent:FindFirstChild("touchinterest esp") then return end
                        local a = Instance.new("BoxHandleAdornment")
                        a.Name = "touchinterest esp"
                        a.Parent = find("touchinterest esp")
                        a.Adornee = v.Parent
                        a.AlwaysOnTop = true
                        a.ZIndex = 0
                        a.Size = v.Parent.Size
                        a.Transparency = 0.3
                        a.Color = BrickColor.new("New Yeller")
			antiisraeli(a)
                    end
                end)
            end
        },
        ["seatesp"] = {
            ["ListName"] = "seatesp/sesp",
            ["Description"] = "allows esp for blocks with a seat",
            ["Aliases"] = {"sesp"},
            ["Function"] = function(args, speaker)
                getgenv().sesp_enabled = true
                if getgenv().sesp_conn then getgenv().sesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Seat") then
                if not v:FindFirstChild("seat esp") then
                local a = Instance.new("BoxHandleAdornment")
            a.Name = "seat esp"
            a.Parent = find("seat esp")
            a.Adornee = v
            a.AlwaysOnTop = true
            a.ZIndex = 0
            a.Size = v.Size
            a.Transparency = 0.55
            a.Color = BrickColor.new("Toothpaste")
	    antiisraeli(a)
                end
                end
                end

                getgenv().sesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().sesp_enabled then return end
                    if v:IsA("Seat") then
                        if v:FindFirstChild("seat esp") then return end
                        local a = Instance.new("BoxHandleAdornment")
                        a.Name = "seat esp"
                        a.Parent = find("seat esp")
                        a.Adornee = v
                        a.AlwaysOnTop = true
                        a.ZIndex = 0
                        a.Size = v.Size
                        a.Transparency = 0.55
                        a.Color = BrickColor.new("Toothpaste")
			antiisraeli(a)
                    end
                end)
            end
        },
        ["nocollisionesp"] = {
            ["ListName"] = "nocollisionesp/ncesp",
            ["Description"] = "allows esp for blocks with no collision",
            ["Aliases"] = {"ncesp"},
            ["Function"] = function(args, speaker)
                getgenv().ncesp_enabled = true
                if getgenv().ncesp_conn then getgenv().ncesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
		local model = v:FindFirstAncestorOfClass("Model")
                if v:IsA("BasePart") and not v.CanCollide and v.Transparency ~= 1 and not (model and model:FindFirstChildOfClass("Humanoid")) then
                if not v:FindFirstChild("nocollision esp") then
                local a = Instance.new("BoxHandleAdornment")
            a.Name = "nocollision esp"
            a.Parent = find("nocollision esp")
            a.Adornee = v
            a.AlwaysOnTop = true
            a.ZIndex = 0
            a.Size = v.Size
            a.Transparency = 0.55
            a.Color = BrickColor.new("Dark orange")
	    antiisraeli(a)
                end
                end
                end

                getgenv().ncesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().ncesp_enabled then return end
			local model = v:FindFirstAncestorOfClass("Model")
	                if v:IsA("BasePart") and not v.CanCollide and v.Transparency ~= 1 and not (model and model:FindFirstChildOfClass("Humanoid")) then
                       if v:FindFirstChild("nocollision esp") then return end
			    local a = Instance.new("BoxHandleAdornment")
		            a.Name = "nocollision esp"
		            a.Parent = find("nocollision esp")
		            a.Adornee = v
		            a.AlwaysOnTop = true
		            a.ZIndex = 0
		            a.Size = v.Size
		            a.Transparency = 0.55
		            a.Color = BrickColor.new("Dark orange")
			    antiisraeli(a)
                    end
                end)
            end
        },
        ["npcesp"] = {
            ["ListName"] = "npcesp",
            ["Description"] = "allows esp for npc models",
            ["Aliases"] = {"npc"},
            ["Function"] = function(args, speaker)
                getgenv().npcesp_enabled = true
                if getgenv().npcesp_conn then getgenv().npcesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("Humanoid") and v.Parent:IsA("Model") and not game.Players:GetPlayerFromCharacter(v.Parent) then
                for _,p in pairs(v.Parent:GetDescendants()) do
                if p:IsA("BasePart") then
                local a = Instance.new("BoxHandleAdornment")
            a.Name = "npc esp"
            a.Parent = find("npc esp")
            a.Adornee = p
            a.AlwaysOnTop = true
            a.ZIndex = 0
            a.Size = p.Size
            a.Transparency = 0.55
            a.Color = BrickColor.new("Fossil")
	    antiisraeli(a)
                end
                end
                end
                end

                getgenv().npcesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().npcesp_enabled then return end
                    if v:IsA("Humanoid") and v.Parent:IsA("Model") and not game.Players:GetPlayerFromCharacter(v.Parent) then
                        for _,p in pairs(v.Parent:GetDescendants()) do
                        if p:IsA("BasePart") then
                        local a = Instance.new("BoxHandleAdornment")
                        a.Name = "npc esp"
                        a.Parent = find("npc esp")
                        a.Adornee = p
                        a.AlwaysOnTop = true
                        a.ZIndex = 0
                        a.Size = p.Size
                        a.Transparency = 0.55
                        a.Color = BrickColor.new("Fossil")
			antiisraeli(a)
                        end
                        end
                    end
                end)
            end
        },
        ["unanchoredesp"] = {
            ["ListName"] = "unanchoresp/uesp",
            ["Description"] = "allows esp for unanchored blocks",
            ["Aliases"] = {"uesp"},
            ["Function"] = function(args, speaker)
                getgenv().uesp_enabled = true
                if getgenv().uesp_conn then getgenv().uesp_conn:Disconnect() end

                for i,v in pairs(game.Workspace:GetDescendants()) do
		local model = v:FindFirstAncestorOfClass("Model")
                if v:IsA("BasePart") and not v.Anchored and not (model and model:FindFirstChildOfClass("Humanoid")) then
                if not v:FindFirstChild("unanchored esp") then
                local a = Instance.new("BoxHandleAdornment")
            a.Name = "unanchored esp"
            a.Parent = find("unanchored esp")
            a.Adornee = v
            a.AlwaysOnTop = true
            a.ZIndex = 0
            a.Size = v.Size
            a.Transparency = 0.55
            a.Color = BrickColor.new("Magenta")
	    antiisraeli(a)
                end
                end
                end

                getgenv().uesp_conn = game.Workspace.DescendantAdded:Connect(function(v)
                    if not getgenv().uesp_enabled then return end
		    local model = v:FindFirstAncestorOfClass("Model")
                    if v:IsA("BasePart") and not v.Anchored and not (model and model:FindFirstChildOfClass("Humanoid")) then
                        if v:FindFirstChild("unanchored esp") then return end
                        local a = Instance.new("BoxHandleAdornment")
                        a.Name = "unanchored esp"
                        a.Parent = find("unanchored esp")
                        a.Adornee = v
                        a.AlwaysOnTop = true
                        a.ZIndex = 0
                        a.Size = v.Size
                        a.Transparency = 0.55
                        a.Color = BrickColor.new("Magenta")
			antiisraeli(a)
                    end
                end)
            end
        },
        ["unclickdetectoresp"] = {
            ["ListName"] = "unclickdetectoresp/uncdesp",
            ["Description"] = "removes esp from blocks w/ clickdetector",
            ["Aliases"] = {"uncdesp"},
            ["Function"] = function(args, speaker)
                getgenv().cdesp_enabled = false
                if getgenv().cdesp_conn then getgenv().cdesp_conn:Disconnect() getgenv().cdesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "clickdetector esp" then
                v:Destroy()
                end
            end
        end
        },
        ["unproximityesp"] = {
            ["ListName"] = "unproximityesp/unppesp",
            ["Description"] = "removes esp from blocks w/ proximityprompt",
            ["Aliases"] = {"unppesp"},
            ["Function"] = function(args, speaker)
                getgenv().ppesp_enabled = false
                if getgenv().ppesp_conn then getgenv().ppesp_conn:Disconnect() getgenv().ppesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "proximity esp" then
                v:Destroy()
                end
            end
        end
        },
        ["untouchinterestesp"] = {
            ["ListName"] = "untouchinterestesp/untouchesp/untesp",
            ["Description"] = "removes esp from blocks w/ touchinterest",
            ["Aliases"] = {"untesp", "untouchesp"},
            ["Function"] = function(args, speaker)
                getgenv().tesp_enabled = false
                if getgenv().tesp_conn then getgenv().tesp_conn:Disconnect() getgenv().tesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "touchinterest esp" then
                v:Destroy()
                end
            end
        end
        },
        ["unseatesp"] = {
            ["ListName"] = "unseatesp/unsesp",
            ["Description"] = "removes esp from blocks w/ seat",
            ["Aliases"] = {"unsesp"},
            ["Function"] = function(args, speaker)
                getgenv().sesp_enabled = false
                if getgenv().sesp_conn then getgenv().sesp_conn:Disconnect() getgenv().sesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "seat esp" then
                    v:Destroy()
                end
            end
        end
        },
        ["unnocollisionesp"] = {
            ["ListName"] = "unnocollision/unncesp",
            ["Description"] = "removes esp from parts with no collision",
            ["Aliases"] = {"unncesp"},
            ["Function"] = function(args, speaker)
                getgenv().ncesp_enabled = false
                if getgenv().ncesp_conn then getgenv().ncesp_conn:Disconnect() getgenv().ncesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "nocollision esp" then
                    v:Destroy()
                end
            end
        end
        },
        ["unnpcesp"] = {
            ["ListName"] = "unnpcesp",
            ["Description"] = "removes esp from npcs",
            ["Aliases"] = {"unnpc"},
            ["Function"] = function(args, speaker)
                getgenv().npcesp_enabled = false
                if getgenv().npcesp_conn then getgenv().npcesp_conn:Disconnect() getgenv().npcesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "npc esp" then
                    v:Destroy()
                end
            end
        end
        },
        ["removeallesp"] = {
            ["ListName"] = "removeallesp",
            ["Description"] = "removes all active esps",
            ["Aliases"] = {"poopyfartskt"},
            ["Function"] = function(args, speaker)
                getgenv().sesp_enabled = false
                getgenv().clickesp_enabled = false
                getgenv().proximityesp_enabled = false
                getgenv().touchesp_enabled = false
                getgenv().nocollisionesp_enabled = false
                getgenv().unanchoredesp_enabled = false
		getgenv().npcesp_enabled = false
		
		if getgenv().npcesp_conn then getgenv().npcesp_conn:Disconnect() end
                if getgenv().sesp_conn then getgenv().sesp_conn:Disconnect() end
                if getgenv().clickesp_conn then getgenv().clickesp_conn:Disconnect() end
                if getgenv().proximityesp_conn then getgenv().proximityesp_conn:Disconnect() end
                if getgenv().touchesp_conn then getgenv().touchesp_conn:Disconnect() end
                if getgenv().nocollisionesp_conn then getgenv().nocollisionesp_conn:Disconnect() end
                if getgenv().unanchoredesp_conn then getgenv().unanchoredesp_conn:Disconnect() end
                
		veryinconspicuous:ClearAllChildren()
            end
        },
        ["nounanchoredesp"] = {
            ["ListName"] = "nounanchoredesp/nouesp",
            ["Description"] = "removes esp from unanchored blocks",
            ["Aliases"] = {"nouesp"},
            ["Function"] = function(args, speaker)
                getgenv().uesp_enabled = false
                if getgenv().uesp_conn then getgenv().uesp_conn:Disconnect() getgenv().uesp_conn = nil end
                for i,v in pairs(game:GetDescendants()) do
                if v:IsA("BoxHandleAdornment") and v.Name == "unanchored esp" then
                    v:Destroy()
            end
        end
    end
    }
}
} -- messy ass pre historic code idk how to fix this without breaking the entire plugin


return Plugin
