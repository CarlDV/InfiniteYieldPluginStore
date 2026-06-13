local rs = game:GetService("RunService")
local plr = game.Players.LocalPlayer
local flinging = false

local Plugin = {
  ["PluginName"] = "Walk Fling",
  ["PluginDescription"] = "Flings anyone who touches you",
  ["Commands"] = {
    ["walkfling"] = {
      ["ListName"] = "walkfling",
      ["Description"] = "Flings anyone who touches you",
      ["Aliases"] = {"wf"},
      ["Function"] = function (args, speaker)
        if not plr.Character then
          return notify("Error", "You don't have a character.")
        end
        local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
          return notify("Error", "You don't have a root part.")
        end
        local dir = 0.1
        if flinging then
          flinging = false
        else
          notify("WalkFling enabled")
          flinging = true
          while flinging and rootPart and rootPart.Parent and rootPart.Parent.Parent do
            rs.Heartbeat:Wait()
            local velocity = rootPart.Velocity
            rootPart.Velocity = ((velocity * 10000) + Vector3.new(0, 10000, 0))
            rs.RenderStepped:Wait()
            rootPart.Velocity = velocity
            rs.RenderStepped:Wait()
            rootPart.Velocity = velocity + Vector3.new(0, dir, 0)
            dir *= -1
          end
          notify("WalkFling disabled")
          flinging = false
        end
      end
    }
  }
}

return Plugin