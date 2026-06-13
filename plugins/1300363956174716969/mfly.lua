local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Camera = workspace.CurrentCamera
local ControlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

local AscendKey = Enum.KeyCode.Space
local DescendKey = Enum.KeyCode.LeftShift

local Ascending = false
local Descending = false
local Began, Ended
local Speed = 20        
local VerticalSpeed = 15         
local Acceleration = 25          
local Deceleration = 20
local VerticalDeceleration = 10          
local VerticalAcceleration = 10
local RenderSteppedConnection


local function HandleAscend(Name, State, Input)
    if State == Enum.UserInputState.Begin then
        Ascending = true
    elseif State == Enum.UserInputState.End then
        Ascending = false
    end
end

local function HandleDescend(Name, State, Input)
    if State == Enum.UserInputState.Begin then
        Descending = true
    elseif State == Enum.UserInputState.End then
        Descending = false
    end
end

local Plugin = {
    ["PluginName"] = "M-Fly V1",
    ["PluginDescription"] = "A simple minecraft fly made by z4neC0des / Z4ne",
    ["Commands"] = {
        ["mfly"] = {
            ["ListName"] = "minecraftfly / mfly [speed]",
            ["Description"] = "Enables flying at a specified speed",
            ["Aliases"] = {"minecraftfly"},
            ["Function"] = function(args, speaker)
                local Success, Error = pcall(function()
                    Speed = args[1] or Speed
                    local CurrentVerticalSpeed = 0 
                    local CurrentSpeed = 0
    
                    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    local Humanoid = Character:WaitForChild("Humanoid")
                    local Neck = Character:FindFirstChild("Neck", true)
                    local YOffset = Neck.C0.Y
    
                    Humanoid:ChangeState("Physics")
                    
                    for _, PlayingTrack in next, Humanoid:GetPlayingAnimationTracks() do
                        PlayingTrack:Stop()
                    end
                    
                    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
                        local FlyAnimation = Instance.new("Animation")
                        FlyAnimation.AnimationId = "rbxassetid://12518152696"
                        AnimationTrack = Humanoid:LoadAnimation(FlyAnimation)
                    elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
                        AnimationTrack = Humanoid:LoadAnimation(Character.Animate.run.RunAnim)
                    end
    
                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.Name = "VelocityHandler"
                    BodyVelocity.Parent = HumanoidRootPart
                    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
                    local BodyGyro = Instance.new("BodyGyro")
                    BodyGyro.Name = "GyroHandler"
                    BodyGyro.Parent = HumanoidRootPart
                    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    BodyGyro.P = 1000
                    BodyGyro.D = 50
    
                    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
                        ContextActionService:BindAction("Ascend", HandleAscend, true, AscendKey)
                        ContextActionService:SetPosition("Ascend", UDim2.new(.2, 0, .3, 0))
                        ContextActionService:SetTitle("Ascend", "^")
                        ContextActionService:BindAction("Descend", HandleDescend, true, DescendKey)
                        ContextActionService:SetPosition("Descend", UDim2.new(.2, 0, .5, 0))
                        ContextActionService:SetTitle("Descend", "v")
                    elseif not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
                        Began = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                            if GameProcessed then return end
                            if Input.KeyCode == Enum.KeyCode.Space then
                                Ascending = true
                            elseif Input.KeyCode == Enum.KeyCode.LeftShift then
                                Descending = true
                            end
                        end)
    
                        Ended = UserInputService.InputEnded:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space then
                                Ascending = false
                            elseif Input.KeyCode == Enum.KeyCode.LeftShift then
                                Descending = false
                            end
                        end)
                    end
    
                    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        if Humanoid.Health <= 0 then
                            if VelocityHandler then
                                VelocityHandler:Destroy()
                            end
    
                            if GyroHandler then
                                GyroHandler:Destroy()
                            end
    
                            if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
                                ContextActionService:UnbindAction("Ascend")
                                ContextActionService:UnbindAction("Descend")
                            else
                                if Began then
                                    Began:Disconnect()
                                    Began = nil
                                end
                                if Ended then
                                    Ended:Disconnect()
                                    Ended = nil
                                end
                            end
    
                            if RenderSteppedConnection then
                                RenderSteppedConnection:Disconnect()
                                RenderSteppedConnection = nil
                            end
    
                            Ascending = false
                            Descending = false
                        end
                    end)
 

                    RenderSteppedConnection = RunService.Heartbeat:Connect(function(DeltaTime)
                        AnimationTrack:AdjustSpeed(CurrentSpeed / Speed)
                        BodyGyro.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, select(2, Camera.CFrame:ToEulerAnglesYXZ()), 0)
                        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    
                        local Direction = ControlModule:GetMoveVector()
                    
                        if Direction.X ~= 0 or Direction.Z ~= 0 then
                            CurrentSpeed = math.min(CurrentSpeed + Acceleration * DeltaTime, Speed)
                            if not AnimationTrack.IsPlaying then
                                AnimationTrack:Play()
                            end
                        else
                            CurrentSpeed = math.max(CurrentSpeed - Deceleration * DeltaTime, 0)
                            if CurrentSpeed == 0 then
                                for _, PlayingTrack in next, Humanoid:GetPlayingAnimationTracks() do
                                    PlayingTrack:Stop()
                                end
                            end
                        end
                       
                        local RightVector = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z).Unit
                        local LookVector = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                        local Velocity = Vector3.new(0, 0, 0)
                    
                        if Direction.X > 0 then
                            Velocity = Velocity + RightVector * (Direction.X * CurrentSpeed)
                        elseif Direction.X < 0 then
                            Velocity = Velocity + RightVector * (Direction.X * CurrentSpeed)
                        end
                    
                        if Direction.Z > 0 then
                            Velocity = Velocity - LookVector * (Direction.Z * CurrentSpeed)
                        elseif Direction.Z < 0 then
                            Velocity = Velocity - LookVector * (Direction.Z * CurrentSpeed)
                        end
                    
                        if Ascending then
                            CurrentVerticalSpeed = math.min(CurrentVerticalSpeed + VerticalAcceleration * DeltaTime, VerticalSpeed)
                        elseif Descending then
                            CurrentVerticalSpeed = math.max(CurrentVerticalSpeed - VerticalAcceleration * DeltaTime, -VerticalSpeed)
                        else
                            if CurrentVerticalSpeed > 0 then
                                CurrentVerticalSpeed = math.max(CurrentVerticalSpeed - VerticalDeceleration * DeltaTime, 0)
                            elseif CurrentVerticalSpeed < 0 then
                                CurrentVerticalSpeed = math.min(CurrentVerticalSpeed + VerticalDeceleration * DeltaTime, 0)
                            end
                        end
                    
                        Velocity = Velocity + (HumanoidRootPart.CFrame.UpVector * CurrentVerticalSpeed)
                    
                        BodyVelocity.Velocity = Velocity
                    
                        local CameraDirection = HumanoidRootPart.CFrame:toObjectSpace(Camera.CFrame).lookVector
                        if Neck then
                            if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                                Neck.C0 = CFrame.new(0, YOffset, 0) * CFrame.Angles(0, -math.asin(CameraDirection.x), 0) * CFrame.Angles(math.asin(CameraDirection.y), 0, 0)
                            elseif Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
                                Neck.C0 = CFrame.new(0, YOffset, 0) * CFrame.Angles(3 * math.pi/2, 0, math.pi) * CFrame.Angles(0, 0, -math.asin(CameraDirection.x)) * CFrame.Angles(-math.asin(CameraDirection.y), 0, 0)
                            end
                        end
                    end)
                end)
                
                if Success then
                    print("Success!")
                else
                    print("Error.. : ", Error)
                end
                notify("M-Fly Enabled.", "Fly higher: press spacebar while flying.\n Descend: hold the left \"Shift\" key.")
            end

        },
        ["unmfly"] = {
            ["ListName"] = "unminecraftfly / unmfly",
            ["Description"] = "Disables flying",
            ["Aliases"] = {"unminecraftfly", "unmfly"},
            ["Function"] = function(args, speaker)
                if AnimationTrack and AnimationTrack.IsPlaying then
                    AnimationTrack:Stop()
                end

                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                local Humanoid = Character:WaitForChild("Humanoid")

                Humanoid:ChangeState("Landed")

                local VelocityHandler = HumanoidRootPart:FindFirstChild("VelocityHandler")
                if VelocityHandler then
                    VelocityHandler:Destroy()
                end

                local GyroHandler = HumanoidRootPart:FindFirstChild("GyroHandler")
                if GyroHandler then
                    GyroHandler:Destroy()
                end

                if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
                    ContextActionService:UnbindAction("Ascend")
                    ContextActionService:UnbindAction("Descend")
                else
                    if Began then
                        Began:Disconnect()
                        Began = nil
                    end
                    if Ended then
                        Ended:Disconnect()
                        Ended = nil
                    end
                end

                if RenderSteppedConnection then
                    RenderSteppedConnection:Disconnect()
                    RenderSteppedConnection = nil
                end

                if Neck then
                    Neck.C0 = CFrame.new(0, YOffset, 0) * CFrame.Angles(0, 0, 0)
                end
                
                Ascending = false
                Descending = false
                notify("M-Fly: Disabled.", "Stopped Flying.")
            end
        },
        ["mspeed"] = {
            ["ListName"] = "mspeed / ms [speed]",
            ["Description"] = "Sets the flying speed",
            ["Aliases"] = {"mspeed", "ms"},
            ["Function"] = function(args, speaker)
                local Speed = tonumber(args[1]) or Speed
            end
        }
    }
}

return Plugin