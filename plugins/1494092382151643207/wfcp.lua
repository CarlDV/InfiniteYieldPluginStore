local Plugin = {
    ["PluginName"] = "Weappon's Fun Camera Plugins",
    ["PluginDescription"] = "a few fun (yet useless) camera plugins",
    ["Commands"] = {
        ["backview"] = {
            ["ListName"] = "rearview / rear / f5",
            ["Description"] = "flips camera 180, swaps to SDWA, and disables shiftlock/1st person",
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
                    local Character = Player.Character
                    local Hum = Character and Character:FindFirstChildOfClass("Humanoid")
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

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
            ["Description"] = "body-visible FP with anti-spin logic and head hiding",
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
                    local Character = Player.Character
                    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
                    local Head = Character and Character:FindFirstChild("Head")

                    if _G.WMActive and Root and Head then
                        Camera.CameraType = Enum.CameraType.Scriptable
                        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
                        
                        local Delta = UIS:GetMouseDelta()
                        _G.WMYaw = _G.WMYaw - (Delta.X * 0.008)
                        -- Clamped to 85 degrees to prevent Gimbal Lock / Flipping
                        _G.WMPitch = math.clamp(_G.WMPitch - (Delta.Y * 0.008), math.rad(-85), math.rad(85))
                        
                        -- ROTATION LOGIC: Separated to prevent the "Spin"
                        -- RootPart only rotates horizontally
                        Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, _G.WMYaw, 0)
                        
                        -- Camera follows head position + local mouse rotation
                        local CamPos = Head.Position + Vector3.new(0, 0.1, 0) 
                        Camera.CFrame = CFrame.new(CamPos) * CFrame.Angles(0, _G.WMYaw, 0) * CFrame.Angles(_G.WMPitch, 0, 0)
                        
                        -- Local-only transparency for the head to see through it
                        Head.LocalTransparencyModifier = 1
                    else
                        _G.WMActive = false
                        Camera.CameraType = Enum.CameraType.Custom
                        UIS.MouseBehavior = Enum.MouseBehavior.Default
                        if Head then Head.LocalTransparencyModifier = 0 end
                        Connection:Disconnect()
                    end
                end)
            end
        },
        ["frontview"] = {
            ["ListName"] = "frontview / resetcam",
            ["Description"] = "snaps camera forward and kills all perspective loops",
            ["Aliases"] = {"resetcam"},
            ["Function"] = function(args, speaker)
                local Players = game:GetService("Players")
                local Camera = workspace.CurrentCamera
                local Player = Players.LocalPlayer
                local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                
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