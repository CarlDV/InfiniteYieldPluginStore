--[[
░██████╗░░█████╗░███╗░░░███╗███████╗░██████╗
██╔════╝░██╔══██╗████╗░████║██╔════╝██╔════╝
██║░░██╗░███████║██╔████╔██║█████╗░░╚█████╗░
██║░░╚██╗██╔══██║██║╚██╔╝██║██╔══╝░░░╚═══██╗
╚██████╔╝██║░░██║██║░╚═╝░██║███████╗██████╔╝
 ░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░
]]--
-- Version 1.0 / Версия 1.0 

local player = game.Players.LocalPlayer

local Plugin = {
    ["PluginName"] = "– Create Scripts –--",
    ["PluginDescription"] = "Good Plugin For UGC Hunting and for create scripts",
    ["Commands"] = {
        ["copyteleport"] = {
           ["ListName"] = "CopyTeleport / CT",
           ["Description"] = "Copy Teleport Script To Your Position",
           ["Aliases"] = {"copyteleport","ct"},
           ["Function"] = function(args, speaker)
              local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
              if type(setclipboard ) == "function" then
                 local pos
                 local char = player.Character
                 local hum = char and player.Character:FindFirstChild("HumanoidRootPart")
                 if char and hum then
                    pos = hum.Position
                    local copy = string.format("game.Players.LocalPlayer.Character:PivotTo(CFrame.new(Vector3.new(%f, %f, %f)))", pos.X, pos.Y, pos.Z)
                    setclipboard(tostring(copy))
                 else
                    local camera = workspace.Camera
                    if not camera then return end
                    pos = camera.Focus.Position
                    local copy = string.format("game.Players.LocalPlayer.Character:PivotTo(CFrame.new(Vector3.new(%f, %f, %f)))", pos.X, pos.Y - 1.5, pos.Z)
                    setclipboard(tostring(copy))
                 end
              else
                 notify("Error", "Your Executor doesn't support setclipboard or another function")
              end
           end
        },
        ["copytween"] = {
           ["ListName"] = "CopyTween / CTW",
           ["Description"] = "Copy Tween Script To Your Position",
           ["Aliases"] = {"copytween","ctw"},
           ["Function"] = function(args, speaker)
              local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
              if type(setclipboard) == "function" then
                 local pos
                 local char = player.Character
                 local hum = char and player.Character:FindFirstChild("HumanoidRootPart")
                 if char and hum then
                    pos = hum.Position
                    local copy = string.format('local tweenInfo = TweenInfo.new(2)\nlocal goal = {CFrame = CFrame.new(%f, %f, %f)}\nlocal tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, goal)\ntween:Play()', pos.X, pos.Y, pos.Z)
                   setclipboard(tostring(copy))
                else
                   local camera = workspace.Camera
                   if not camera then return end
                   pos = camera.Focus.Position
                   local copy = string.format('local tweenInfo = TweenInfo.new(2)\nlocal goal = {CFrame = CFrame.new(%f, %f, %f)}\nlocal tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, goal)\ntween:Play()', pos.X, pos.Y - 1.5, pos.Z)
                   setclipboard(tostring(copy))
                end
              else
                 notify("Error", "Your Executor doesn't support setclipboard or another function")
              end
           end
        },
        ["copymoveto"] = {
           ["ListName"] = "CopyMoveTo / CMT",
           ["Description"] = "Copy Move To Script To Your Position",
           ["Aliases"] = {"copymoveto","cmt"},
           ["Function"] = function(args, speaker)
              local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
              if type(setclipboard) == "function" then
                 local pos
                 local char = player.Character
                 local hum = char and player.Character:FindFirstChild("HumanoidRootPart")
                 if char and hum then
                    pos = hum.Position
                    local copy = string.format('local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart\nlocal position = "%f, %f, %f"\nlocal humanoid = game.Players.LocalPlayer.Character.Humanoid\nhumanoid.WalkSpeed = 16\nhumanoid.JumpPower = 19\nhumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)\nhumanoid:MoveTo(position)', pos.X, pos.Y, pos.Z)
                    setclipboard(tostring(copy))
                 else
                    local camera = workspace.Camera
                    if not camera then return end
                    pos = camera.Focus.Position
                    local copy = string.format('local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart\nlocal position = "%f, %f, %f"\nlocal humanoid = game.Players.LocalPlayer.Character.Humanoid\nhumanoid.WalkSpeed = 16\nhumanoid.JumpPower = 19\nhumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)\nhumanoid:MoveTo(position)', pos.X, pos.Y - 1.5, pos.Z)
                    setclipboard(tostring(copy))
                 end
              else
                 notify("Error", "Your Executor doesn't support setclipboard or another function")
              end
           end
        },
        ["copylerp"] = {
           ["ListName"] = "CopyLerp / CL",
           ["Description"] = "Copy Lerp Script To Your Position",
           ["Aliases"] = {"copylerp","cl"},
           ["Function"] = function(args, speaker)
              local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
              if type(setclipboard) == "function" then
                 local pos
                 local char = player.Character
                 local hum = char and player.Character:FindFirstChild("HumanoidRootPart")
                 if char and hum then
                    pos = hum.Position
                    local copy  = string.format('local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart\nlocal goal = CFrame.new(%f, %f, %f)\nfor i = 0, 1, 0.05 do\nhrp.CFrame = hrp.CFrame:Lerp(goal, i)\ntask.wait()\nend', pos.X, pos.Y, pos.Z)
                    setclipboard(tostring(copy))
                 else
                    local camera = workspace.Camera
                    if not camera then return end
                    pos = camera.Focus.Position
                    local copy  = string.format('local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart\nlocal goal = CFrame.new(%f, %f, %f)\nfor i = 0, 1, 0.05 do\nhrp.CFrame = hrp.CFrame:Lerp(goal, i)\ntask.wait()\nend', pos.X, pos.Y - 1.5, pos.Z)
                    setclipboard(tostring(copy))
                 end
              else
                 notify("Error", "Your Executor doesn't support setclipboard or another function")
              end
           end
        },
        ["copytptogame"] = {
           ["ListName"] = "CopyTpToGame / CTTG",
           ["Description"] = "Copy Teleport Script To This game",
           ["Aliases"] = {"copytptogame","cttg"},
           ["Function"] = function(args, speaker)
              local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
              if type(setclipboard) == "function" then
                 setclipboard('game:GetService("TeleportService"):Teleport('..game.PlaceId..',game.Players.LocalPlayer)')
              else
                 notify("Error", "Your Executor doesn't support setclipboard or another function")
              end
           end
        },
        ["copytptoserver"] = {
           ["ListName"] = "CopyTpToServer / CTTS",
           ["Description"] = "Copy Teleport Script To This Server",
           ["Aliases"] = {"copytptoserver","ctts"},
           ["Function"] = function(args, speaker)
              local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
              if type(setclipboard) == "function" then
                 setclipboard('game:GetService("TeleportService"):TeleportToPlaceInstance('..game.PlaceId..',"'..game.JobId..'",game.Players.LocalPlayer)')
              else
                 notify("Error", "Your Executor doesn't support setclipboard or another function")
              end
           end
        }
    }
}

return Plugin