--[[
░██████╗░░█████╗░███╗░░░███╗███████╗░██████╗
██╔════╝░██╔══██╗████╗░████║██╔════╝██╔════╝
██║░░██╗░███████║██╔████╔██║█████╗░░╚█████╗░
██║░░╚██╗██╔══██║██║╚██╔╝██║██╔══╝░░░╚═══██╗
╚██████╔╝██║░░██║██║░╚═╝░██║███████╗██████╔╝
 ░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░
]]--
-- Version 1.1 / Версия 1.1

local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local tpjumping, boost = nil, 0

local Plugin = {
    ["PluginName"] = "– Teleport Jump –--",
    ["PluginDescription"] = "Good Plugin For Teleport Jump",
    ["Commands"] = {
        ["teleportjump"] = {
           ["ListName"] = "TeleportJump / TpJump [num]",
           ["Description"] = "TeleportWalk but for Jump",
           ["Aliases"] = {"teleportjump","tpjump"},
           ["Function"] = function(args, speaker)
              boost = (args[1] and isNumber(args[1])) and tonumber(args[1]) or 2
              if tpjumping then 
                 tpjumping:Disconnect() 
              end
              if boost == 0 then 
                 return
              end
              local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid") or nil
              if not humanoid then
                 notify("Error", "Humanoid not found")
                 return
              end
              tpjumping = RunService.Heartbeat:Connect(function(delta) -- I Love Delta Users :)
                 if humanoid.Parent then
                    local root = humanoid.Parent:FindFirstChild("HumanoidRootPart")
                    if root then
                       local state = humanoid:GetState()
                       if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
                          root.CFrame = root.CFrame + Vector3.new(0, boost * delta * 10, 0)
                       end
                    end
                 end
              end)
           end
        },
        ["unteleportjump"] = {
           ["ListName"] = "UnTeleportJump / UnTpJump",
           ["Description"] = "TeleportWalk but for Jump",
           ["Aliases"] = {"unteleportjump","untpjump"},
           ["Function"] = function(args, speaker)
              if tpjumping then
                 tpjumping:Disconnect()
                 boost = 0
              end
           end
        }
    }
}

return Plugin