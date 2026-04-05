local Plugin = {
    ["PluginName"] = "interactable objects esp",
    ["PluginDescription"] = "clickdetectors are red, proximityprompts are green.",
    ["Commands"] = {
        ["clickdetectoresp"] = {
            ["ListName"] = "clickdetectoresp/clickesp/cdesp",
            ["Description"] = "allows esp for blocks with a clickdetector",
            ["Aliases"] = {"clickesp", "cdesp"},
            ["Function"] = function(args, speaker)
                for i,v in pairs(game:GetDescendants()) do
                if v.ClassName == "ClickDetector" then
                local a = Instance.new("BoxHandleAdornment")
			a.Name = "clickdetector esp"
			a.Parent = v.Parent
			a.Adornee = v.Parent
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = v.Parent.Size
			a.Transparency = 0.3
			a.Color = BrickColor.new("Really red")
            end
        end
    end
        },
        ["proximityesp"] = {
            ["ListName"] = "proximityesp/promptesp/ppesp",
            ["Description"] = "allows esp for blocks with a proximityprompt",
            ["Aliases"] = {"promptesp", "ppesp"},
            ["Function"] = function(args, speaker)
                for i,v in pairs(Game:GetDescendants()) do
                if v.ClassName == "ProximityPrompt" then
                local a = Instance.new("BoxHandleAdornment")
			a.Name = "proximity esp"
			a.Parent = v.Parent
			a.Adornee = v.Parent
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = v.Parent.Size
			a.Transparency = 0.3
			a.Color = BrickColor.new("Lime green")
            end
        end
    end
        },
        ["unclickdetectoresp"] = {
            ["ListName"] = "unclickdetectoresp/uncdesp",
            ["Description"] = "removes esp from blocks w/ clickdetector",
            ["Aliases"] = {"uncdesp"},
            ["Function"] = function(args, speaker)
                for i,v in pairs(Game:GetDescendants()) do
                if v.ClassName == "BoxHandleAdornment" and v.Name == "clickdetector esp" then
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
                for i,v in pairs(Game:GetDescendants()) do
                if v.ClassName == "BoxHandleAdornment" and v.Name == "proximity esp" then
                v:Destroy()
                end
            end
        end
        }
    }
}

return Plugin
