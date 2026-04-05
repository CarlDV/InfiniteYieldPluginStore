local event = nil

local Plugin = {
  ["PluginName"] = "POV",
  ["PluginDescription"] = "Let's you view as a pov from inside any character model. Made by FFJ 2.0#6693",
  ["Commands"] = {
    ["pov"] = {
      ["ListName"] = "pov [name]",
      ["Description"] = "Views the POV as the character model.",
      ["Aliases"] = {
        "startpov"
      },
      ["Function"] = function(args,speaker)
      if event then
        return notify("POV", "You are already in a pov.")
      end
      if not args[1] then
        return notify("POV", "You gotta specify the character model's name to view as.")
      end
      local name = getstring(1)
      local model = nil
      for i, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Model") and string.lower(v.Name) == string.lower(name) then
          model = v
          break
        end
      end
      if not model then
        return notify("POV", "I guess i wasn't able to find the character model with the given name.")
      end
      local part = model:FindFirstChild("Head") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart", true)
      if not part then
        return notify("POV", "There isn't any part on the model to get pov as.")
      end
      local cam = game.Workspace.CurrentCamera
      event = game:GetService("RunService").RenderStepped:Connect(function ()
        cam.CFrame = part.CFrame
        end)
      end
    },

    ["unpov"] = {
      ["ListName"] = "pov [name]",
      ["Description"] = "Views the POV as the character model.",
      ["Aliases"] = {
        "exitpov"
      },
      ["Function"] = function(args,speaker)
      if not event then
        return notify("POV", "You aren't in a pov.")
      end
      event:Disconnect()
      event = nil
      end
    }
  }
}

return Plugin