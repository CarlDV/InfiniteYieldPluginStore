local Plugin = {
    ["PluginName"] = "WFCP",
    ["PluginDescription"] = "my camera plugins",
    ["Commands"] = {
        ["hideacc"] = {
            ["ListName"] = "hideacc / accessories",
            ["Description"] = "hides your accessories if your playermodel is in the workspace's localplayer",
            ["Aliases"] = {"accessories"},
            ["Function"] = function(args, speaker)
                local Player = game:GetService("Players").LocalPlayer
                local RunService = game:GetService("RunService")
                _G.AccHidden = not _G.AccHidden
                
                if _G.AccConnection then 
                    _G.AccConnection:Disconnect() 
                    _G.AccConnection = nil 
                end

                if _G.AccHidden then
                    _G.AccConnection = RunService.RenderStepped:Connect(function()
                        local char = Player.Character
                        if char then
                            for _, v in pairs(char:GetChildren()) do
                                if v:IsA("Accessory") then
                                    local p = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")
                                    if p then
                                        p.LocalTransparencyModifier = 1
                                        p.Transparency = 1
                                    end
                                end
                            end
                        end
                    end)
                else
                    local char = Player.Character
                    if char then
                        for _, v in pairs(char:GetChildren()) do
                            if v:IsA("Accessory") then
                                local p = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")
                                if p then
                                    p.LocalTransparencyModifier = 0
                                    p.Transparency = 0
                                end
                            end
                        end
                    end
                end
            end
        },
        ["backview"] = {
            ["ListName"] = "rearview / rear / f5",
            ["Description"] = "flips camera 180 degrees and inverts controls, best used w/o shiftlock or first person",
            ["Aliases"] = {"rear", "f5"},
            ["Function"] = function(args, speaker)
                local Camera = workspace.CurrentCamera
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local UIS = game:GetService("UserInputService")
                local Player = Players.LocalPlayer

                if _G.RearViewActive then
                    _G.RearViewActive = false
                    Player.DevEnableMouseLock = _G.PrevMouseLock
                    Player.CameraMinZoomDistance = _G.PrevMinZoom
                    Player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
                    
                    local focus = Camera.Focus.Position
                    local offset = Camera.CFrame.Position - focus
                    local rotatedOffset = CFrame.Angles(0, math.pi, 0) * offset
                    Camera.CFrame = CFrame.lookAt(focus + rotatedOffset, focus)
                    return
                end

                _G.PrevMouseLock = Player.DevEnableMouseLock
                _G.PrevMinZoom = Player.CameraMinZoomDistance
                _G.RearViewActive = true
                
                Player.DevEnableMouseLock = false
                Player.CameraMinZoomDistance = 5
                
                local focus = Camera.Focus.Position
                local offset = Camera.CFrame.Position - focus
                local rotatedOffset = CFrame.Angles(0, math.pi, 0) * offset
                Camera.CFrame = CFrame.lookAt(focus + rotatedOffset, focus)

                local Connection
                Connection = RunService.RenderStepped:Connect(function()
                    local char = Player.Character
                    local Hum = char and char:FindFirstChildOfClass("Humanoid")
                    local Root = char and char:FindFirstChild("HumanoidRootPart")

                    if _G.RearViewActive and Hum and Root then
                        Player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
                        local MoveVec = Vector3.new(0, 0, 0)
                        if UIS:IsKeyDown(Enum.KeyCode.S) then MoveVec = MoveVec + Vector3.new(0, 0, -1) end
                        if UIS:IsKeyDown(Enum.KeyCode.W) then MoveVec = MoveVec + Vector3.new(0, 0, 1) end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then MoveVec = MoveVec + Vector3.new(-1, 0, 0) end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then MoveVec = MoveVec + Vector3.new(1, 0, 0) end
                        Hum:Move(MoveVec, true)
                    else
                        _G.RearViewActive = false
                        Connection:Disconnect()
                    end
                end)
            end
        },
        ["worldmodelfp"] = {
            ["ListName"] = "worldmodelfp / fp / realfirstperson",
            ["Description"] = "my custom first person (i really love this command so i might make it a seperate one)",
            ["Aliases"] = {"fp", "realfirstperson"},
            ["Function"] = function(args, speaker)
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local UIS = game:GetService("UserInputService")
                local Camera = workspace.CurrentCamera
                local Player = Players.LocalPlayer

                if _G.WMActive then
                    _G.WMActive = false
                    return
                end

                _G.WMActive = true
                _G.WMYaw = 0
                _G.WMPitch = 0
                
                local Connection
                Connection = RunService.RenderStepped:Connect(function()
                    local char = Player.Character
                    local Root = char and char:FindFirstChild("HumanoidRootPart")
                    local Head = char and char:FindFirstChild("Head")

                    if _G.WMActive and Root and Head then
                        Camera.CameraType = Enum.CameraType.Scriptable
                        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
                        
                        local Delta = UIS:GetMouseDelta()
                        _G.WMYaw = _G.WMYaw - (Delta.X * 0.008)
                        _G.WMPitch = math.clamp(_G.WMPitch - (Delta.Y * 0.008), -1.48, 1.48)
                        
                        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, _G.WMYaw, 0)
                        
                        local HeadPosOnly = CFrame.new(Head.Position)
                        local CamRotation = CFrame.Angles(0, _G.WMYaw, 0) * CFrame.Angles(_G.WMPitch, 0, 0)
                        
                        Camera.CFrame = HeadPosOnly * CamRotation * CFrame.new(0, 0.3, -0.2)
                        
                        Head.LocalTransparencyModifier = 1
                    else
                        _G.WMActive = false
                        Camera.CameraType = Enum.CameraType.Custom
                        UIS.MouseBehavior = Enum.MouseBehavior.Default
                        
                        local char2 = Player.Character
                        if char2 then
                            local head2 = char2:FindFirstChild("Head")
                            if head2 then head2.LocalTransparencyModifier = 0 end
                        end
                        Connection:Disconnect()
                    end
                end)
            end
        },
        ["frontview"] = {
            ["ListName"] = "frontview / resetcam",
            ["Description"] = "straightens your camera",
            ["Aliases"] = {"resetcam"},
            ["Function"] = function(args, speaker)
                local Players = game:GetService("Players")
                local Camera = workspace.CurrentCamera
                local Player = Players.LocalPlayer
                
                local char = Player.Character
                local Root = char and char:FindFirstChild("HumanoidRootPart")
                
                _G.RearViewActive = false
                _G.WMActive = false
                
                Player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
                Player.DevEnableMouseLock = true
                Player.CameraMinZoomDistance = 0.5
                
                if Root then
                    Camera.CameraType = Enum.CameraType.Custom
                    local LookPos = Root.CFrame:PointToWorldSpace(Vector3.new(0, 2, -15))
                    local CamPos = Root.CFrame:PointToWorldSpace(Vector3.new(0, 2, 12))
                    Camera.CFrame = CFrame.new(CamPos, LookPos)
                end
            end
        }
    }
}

return Plugin