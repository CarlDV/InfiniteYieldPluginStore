local Plugin = {
    ["PluginName"] = "HeadRotation",
    ["PluginDescription"] = "R15 Head Look-at with Raycast/Peek/Invert support",
    ["Commands"] = {
        ["headlook"] = {
            ["ListName"] = "headlook [180/360] [nod]",
            ["Description"] = "Head follows camera (default: 360)",
            ["Aliases"] = {"hlook", "headspin"},
            ["Function"] = function(args, speaker)
                if getgenv().HeadRotationLoop then getgenv().HeadRotationLoop:Disconnect() end
                if getgenv().HeadSpinTrack then getgenv().HeadSpinTrack:Stop() end
                if getgenv().HeadNodTrack then getgenv().HeadNodTrack:Stop() end

                local flags = {}
                for _, v in pairs(args) do flags[v:lower()] = true end

                local mode = flags["180"] and 180 or 360
                local useNod = flags["nod"]

                local Character = Players.LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local Head = Character and Character:FindFirstChild("Head")
                local UpperTorso = Character and Character:FindFirstChild("UpperTorso")
                local Camera = workspace.CurrentCamera

                if not Humanoid or Humanoid.RigType ~= Enum.HumanoidRigType.R15 then 
                    notify("HeadRotation", "R15 required")
                    return 
                end

                local HeadSpin = Instance.new("Animation")
                HeadSpin.AnimationId = "rbxassetid://109668276932875"
                local HeadSpinTrack = Humanoid:LoadAnimation(HeadSpin)
                HeadSpinTrack.Priority = Enum.AnimationPriority.Movement
                HeadSpinTrack:Play(0, 1, 0)
                getgenv().HeadSpinTrack = HeadSpinTrack

                local NodTrack
                if useNod then
                    local Nod = Instance.new("Animation")
                    Nod.AnimationId = "rbxassetid://135009708452344"
                    NodTrack = Humanoid:LoadAnimation(Nod)
                    NodTrack:Play(0, 100, 0)
                    getgenv().HeadNodTrack = NodTrack
                end

                if mode == 360 then
                    local lastYaw = 0
                    local totalRotation = 0
                    getgenv().HeadRotationLoop = RunService.RenderStepped:Connect(function()
                        if not Character or not Character.Parent then 
                            getgenv().HeadRotationLoop:Disconnect() 
                            return 
                        end
                        local lookDirWorld = Camera.CFrame.LookVector
                        local lookDirBody = UpperTorso.CFrame:VectorToObjectSpace(lookDirWorld)
                        local currentYaw = math.atan2(-lookDirBody.X, -lookDirBody.Z)
                        local delta = currentYaw - lastYaw
                        if delta > math.pi then delta = delta - (2 * math.pi)
                        elseif delta < -math.pi then delta = delta + (2 * math.pi) end
                        totalRotation = totalRotation + delta
                        lastYaw = currentYaw
                        local animationPos = (totalRotation / (2 * math.pi)) % 1
                        HeadSpinTrack.TimePosition = -(animationPos * HeadSpinTrack.Length)
                    end)
                else
                    getgenv().HeadRotationLoop = Camera:GetPropertyChangedSignal("CFrame"):Connect(function()
                        if not Character or not Character.Parent then 
                            getgenv().HeadRotationLoop:Disconnect() 
                            return 
                        end
                        local lookDirWorld = (Camera.CFrame.Position - Head.CFrame.Position).Unit
                        local lookDirBody = UpperTorso.CFrame:VectorToObjectSpace(lookDirWorld)
                        local pitchRad = math.asin(lookDirBody.Y)
                        local yawRad = math.atan2(-lookDirBody.X, -lookDirBody.Z)
                        if NodTrack then
                            NodTrack.TimePosition = math.clamp((pitchRad + math.pi/2) / math.pi * NodTrack.Length, 0, NodTrack.Length)
                        end
                        HeadSpinTrack.TimePosition = -math.clamp((yawRad + math.pi) / (2*math.pi) * HeadSpinTrack.Length, -HeadSpinTrack.Length, HeadSpinTrack.Length)
                    end)
                end

                notify("HeadRotation", "Camera " .. mode .. "°" .. (useNod and " +Nod" or ""))
            end
        },
        ["headstare"] = {
            ["ListName"] = "headstare [plr/auto] [180/360/nod/raycast/invert/peek]",
            ["Description"] = "Head follows player with options",
            ["Aliases"] = {"hstare"},
            ["Function"] = function(args, speaker)
                if getgenv().HeadRotationLoop then getgenv().HeadRotationLoop:Disconnect() end
                if getgenv().HeadSpinTrack then getgenv().HeadSpinTrack:Stop() end
                if getgenv().HeadNodTrack then getgenv().HeadNodTrack:Stop() end
                if getgenv().PeekTrack then getgenv().PeekTrack:Stop() end

                local targetArg = args[1] or "auto"
                local flags = {}
                for i = 2, #args do flags[args[i]:lower()] = true end

                local mode = flags["180"] and 180 or 360
                local useNod = flags["nod"]
                local useRaycast = flags["raycast"]
                local useInvert = flags["invert"]
                local usePeek = flags["peek"]

                local Character = Players.LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local Head = Character and Character:FindFirstChild("Head")
                local UpperTorso = Character and Character:FindFirstChild("UpperTorso")
                local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

                if not Humanoid or Humanoid.RigType ~= Enum.HumanoidRigType.R15 then 
                    notify("HeadRotation", "R15 required")
                    return 
                end

                local HeadSpin = Instance.new("Animation")
                HeadSpin.AnimationId = "rbxassetid://109668276932875"
                local HeadSpinTrack = Humanoid:LoadAnimation(HeadSpin)
                HeadSpinTrack.Priority = Enum.AnimationPriority.Movement
                HeadSpinTrack:Play(0, 1, 0)
                getgenv().HeadSpinTrack = HeadSpinTrack

                local NodTrack
                if useNod then
                    local Nod = Instance.new("Animation")
                    Nod.AnimationId = "rbxassetid://135009708452344"
                    NodTrack = Humanoid:LoadAnimation(Nod)
                    NodTrack:Play(0, 100, 0)
                    getgenv().HeadNodTrack = NodTrack
                end

                local PeekLeftTrack, PeekRightTrack
                if usePeek then
                    local PeekLeft = Instance.new("Animation")
                    PeekLeft.AnimationId = "rbxassetid://123862584261569"
                    PeekLeftTrack = Humanoid:LoadAnimation(PeekLeft)
                    PeekLeftTrack.Priority = Enum.AnimationPriority.Action

                    local PeekRight = Instance.new("Animation")
                    PeekRight.AnimationId = "rbxassetid://87095827181320"
                    PeekRightTrack = Humanoid:LoadAnimation(PeekRight)
                    PeekRightTrack.Priority = Enum.AnimationPriority.Action
                end

                local RaycastParams = RaycastParams.new()
                RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
                RaycastParams.FilterDescendantsInstances = {Character}

                local lastYaw = 0
                local totalRotation = 0
                local lastValidYaw = 0
                local currentPeekSide = nil

                local function GetTarget()
                    if targetArg == "auto" then
                        local closest, dist = nil, 100
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                                local d = (Head.Position - p.Character.Head.Position).Magnitude
                                if d < dist then closest = p dist = d end
                            end
                        end
                        return closest
                    else
                        for _, v in pairs(getPlayer(targetArg, speaker)) do
                            return Players[v]
                        end
                    end
                    return nil
                end

                local function IsTargetVisible(targetHead)
                    if not useRaycast then return true end
                    local direction = (targetHead.Position - Head.Position)
                    local result = workspace:Raycast(Head.Position, direction, RaycastParams)
                    if result then
                        return result.Instance:IsDescendantOf(targetHead.Parent)
                    end
                    return true
                end

                local function IsTargetFacingMe(targetChar)
                    if not useInvert then return false end
                    local targetHead = targetChar:FindFirstChild("Head")
                    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetHead or not targetHRP then return false end
                    local dirToMe = (Head.Position - targetHead.Position).Unit
                    local targetLook = targetHRP.CFrame.LookVector
                    return dirToMe:Dot(targetLook) > 0.5
                end

                local function CheckPeekSide(targetPos)
                    if not usePeek then return nil end
                    local rightDir = HumanoidRootPart.CFrame.RightVector
                    local leftDir = -rightDir
                    local forwardDir = HumanoidRootPart.CFrame.LookVector

                    local rightRay = workspace:Raycast(Head.Position, rightDir * 3, RaycastParams)
                    local leftRay = workspace:Raycast(Head.Position, leftDir * 3, RaycastParams)
                    local forwardRay = workspace:Raycast(Head.Position, forwardDir * 5, RaycastParams)

                    local toTarget = (targetPos - Head.Position).Unit
                    local dotRight = toTarget:Dot(rightDir)

                    if forwardRay and not IsTargetVisible(targetPos) then
                        if rightRay and dotRight > 0 then
                            return "right"
                        elseif leftRay and dotRight < 0 then
                            return "left"
                        end
                    end
                    return nil
                end

                getgenv().HeadRotationLoop = RunService.RenderStepped:Connect(function()
                    if not Character or not Character.Parent then 
                        getgenv().HeadRotationLoop:Disconnect() 
                        return 
                    end

                    local targetPlayer = GetTarget()
                    if not targetPlayer or not targetPlayer.Character then return end

                    local targetHead = targetPlayer.Character:FindFirstChild("Head")
                    if not targetHead then return end

                    local isVisible = IsTargetVisible(targetHead)
                    local isFacingMe = IsTargetFacingMe(targetPlayer.Character)

                    if usePeek then
                        local peekSide = CheckPeekSide(targetHead.Position)
                        if peekSide ~= currentPeekSide then
                            if PeekLeftTrack then PeekLeftTrack:Stop() end
                            if PeekRightTrack then PeekRightTrack:Stop() end
                            if peekSide == "left" then
                                PeekLeftTrack:Play()
                            elseif peekSide == "right" then
                                PeekRightTrack:Play()
                            end
                            currentPeekSide = peekSide
                        end
                    end

                    if not isVisible then return end

                    local targetPos = targetHead.Position
                    local lookDirWorld = (targetPos - Head.CFrame.Position).Unit

                    if isFacingMe then
                        lookDirWorld = -lookDirWorld
                    end

                    local lookDirBody = UpperTorso.CFrame:VectorToObjectSpace(lookDirWorld)

                    if mode == 360 then
                        local currentYaw = math.atan2(-lookDirBody.X, -lookDirBody.Z)
                        local delta = currentYaw - lastYaw
                        if delta > math.pi then delta = delta - (2 * math.pi)
                        elseif delta < -math.pi then delta = delta + (2 * math.pi) end
                        totalRotation = totalRotation + delta
                        lastYaw = currentYaw
                        local animationPos = (totalRotation / (2 * math.pi)) % 1
                        HeadSpinTrack.TimePosition = -(animationPos * HeadSpinTrack.Length)
                    else
                        local pitchRad = math.asin(lookDirBody.Y)
                        local yawRad = math.atan2(-lookDirBody.X, -lookDirBody.Z)
                        if NodTrack then
                            NodTrack.TimePosition = math.clamp((pitchRad + math.pi/2) / math.pi * NodTrack.Length, 0, NodTrack.Length)
                        end
                        HeadSpinTrack.TimePosition = -math.clamp((yawRad + math.pi) / (2*math.pi) * HeadSpinTrack.Length, -HeadSpinTrack.Length, HeadSpinTrack.Length)
                    end
                end)

                local flagsStr = ""
                if useNod then flagsStr = flagsStr .. " +Nod" end
                if useRaycast then flagsStr = flagsStr .. " +Raycast" end
                if useInvert then flagsStr = flagsStr .. " +Invert" end
                if usePeek then flagsStr = flagsStr .. " +Peek" end
                notify("HeadRotation", "Staring " .. targetArg .. " " .. mode .. "°" .. flagsStr)
            end
        },
        ["unheadlook"] = {
            ["ListName"] = "unheadlook",
            ["Description"] = "Stops all head rotation",
            ["Aliases"] = {"unhstare", "unheadspin", "unheadstare"},
            ["Function"] = function(args, speaker)
                if getgenv().HeadRotationLoop then 
                    getgenv().HeadRotationLoop:Disconnect()
                    getgenv().HeadRotationLoop = nil
                end
                if getgenv().HeadSpinTrack then 
                    getgenv().HeadSpinTrack:Stop()
                    getgenv().HeadSpinTrack = nil
                end
                if getgenv().HeadNodTrack then 
                    getgenv().HeadNodTrack:Stop()
                    getgenv().HeadNodTrack = nil
                end
                if getgenv().PeekTrack then
                    getgenv().PeekTrack:Stop()
                    getgenv().PeekTrack = nil
                end
                notify("HeadRotation", "Disabled")
            end
        }
    }
}

return Plugin