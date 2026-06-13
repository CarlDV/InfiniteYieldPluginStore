local Plugin = {
    ["PluginName"] = "Creep teleport",
    ["PluginDescription"] = "Lets you creepily teleport to people",
    ["Commands"] = {
        ["COMMANDNAME"] = {
            ["ListName"] = "creepteleport [plr] [speed]",
            ["Description"] = "Rise out of the ground behind someone",
            ["Aliases"] = {"creepteleport","creeptele","ctele","creeptp","ctp","creepgoto","cgoto"},
            ["Function"] = function(args,speaker,speed)
                local players = getPlayer(args[1], speaker)
                for i,v in pairs(players)do
                    if Players[v].Character ~= nil then
                        local goal = getRoot(Players[v].Character).CFrame * CFrame.new(0, 0, 2)
                        local view = Instance.new("Part")
                        view.Transparency = 1
                        view.CanCollide = false
                        view.Anchored = true
                        view.CFrame = goal * CFrame.new(speaker.Character.Humanoid.CameraOffset)
                        view.Parent = workspace
                        workspace.Camera.CameraSubject = view
                        if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
                            speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
                            wait(.1)
                        end
                        local HRP = getRoot(speaker.Character)
                        HRP.Anchored = true
                        HRP.CFrame = goal * CFrame.new(0, -15, 0)
                        
                        local tween = game:GetService("TweenService"):Create(HRP, TweenInfo.new(speed and tonumber(speed) or 2), {CFrame = goal})
                        tween:Play()
                        tween.Completed:Connect(function()
                            workspace.Camera.CameraSubject = speaker.Character.Humanoid
                            view:Destroy()
                            HRP.Anchored = false
                        end)
                    end
                end
            end
        }
     }
}

return Plugin