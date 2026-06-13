local Plugin = {
    ["PluginName"] = "NPC Controller",
    ["PluginDescription"] = "Advanced NPC Control",
    ["Commands"] = {}
}

local TargetNPC = nil
local ControlConnection = nil
local PhysicsConnections = {}
local SelectedBox = nil
local HoverBox = nil

local InputService = Services.UserInputService
local RunService = Services.RunService
local Players = Services.Players
local Workspace = Services.Workspace
local Camera = Workspace.CurrentCamera

local FlingPower = 50e35
local IsFlinging = false
local ControlMode = false
local RideOffset = CFrame.new()

local realcharacter = nil
local fakecharacter = nil
local originalUIStates = {}
local originalPhysics = {}

local function getCoreUI(speaker)
    local gui = nil
    pcall(function() gui = gethui() end)
    return gui or Services.CoreGui or speaker:FindFirstChildWhichIsA("PlayerGui")
end

local function enforcePhysics(part, prop, targetValue)
    local conn = part:GetPropertyChangedSignal(prop):Connect(function()
        if part[prop] ~= targetValue then
            part[prop] = targetValue
        end
    end)
    table.insert(PhysicsConnections, conn)
end

local function setCharPhysics(speaker, enabled)
    if not realcharacter then return end
    
    for _, conn in pairs(PhysicsConnections) do
        conn:Disconnect()
    end
    table.clear(PhysicsConnections)

    for _, v in pairs(realcharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            if not enabled then
                if not originalPhysics[v] then
                    originalPhysics[v] = {
                        CanCollide = v.CanCollide,
                        CanTouch = v.CanTouch,
                        CanQuery = v.CanQuery,
                        Massless = v.Massless
                    }
                end
                v.CanCollide = false
                v.CanTouch = false
                v.CanQuery = false
                v.Massless = true
                enforcePhysics(v, "CanCollide", false)
                enforcePhysics(v, "CanTouch", false)
                enforcePhysics(v, "CanQuery", false)
                enforcePhysics(v, "Massless", true)
            else
                if originalPhysics[v] then
                    v.CanCollide = originalPhysics[v].CanCollide
                    v.CanTouch = originalPhysics[v].CanTouch
                    v.CanQuery = originalPhysics[v].CanQuery
                    v.Massless = originalPhysics[v].Massless
                end
            end
        end
    end
    
    if enabled then table.clear(originalPhysics) end
end

local function handleUI(speaker, isControlling)
    local gui = speaker:FindFirstChildWhichIsA("PlayerGui")
    if not gui then return end
    
    if isControlling then
        for _, v in pairs(gui:GetChildren()) do
            if v:IsA("ScreenGui") then
                originalUIStates[v] = v.ResetOnSpawn
                v.ResetOnSpawn = false
            end
        end
    else
        for v, state in pairs(originalUIStates) do
            if v and v.Parent then
                v.ResetOnSpawn = state
            end
        end
        table.clear(originalUIStates)
    end
end

local function getMoveVector()
    if InputService:GetFocusedTextBox() then return Vector3.zero end
    
    local moveVec = Vector3.new(0, 0, 0)
    if InputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + Camera.CFrame.LookVector end
    if InputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - Camera.CFrame.LookVector end
    if InputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - Camera.CFrame.RightVector end
    if InputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + Camera.CFrame.RightVector end
    
    if moveVec.Magnitude > 0 then
        return Vector3.new(moveVec.X, 0, moveVec.Z).Unit
    end
    
    return Vector3.zero
end

Plugin.Commands["npcpath"] = {
    ["ListName"] = "npcpath",
    ["Description"] = "Select an NPC",
    ["Aliases"] = {"selectnpc"},
    ["Function"] = function(args, speaker)
        local ui = getCoreUI(speaker)
        if not HoverBox then
            HoverBox = Instance.new("SelectionBox", ui)
            HoverBox.Color3 = Color3.new(1, 1, 1)
            SelectedBox = Instance.new("SelectionBox", ui)
            SelectedBox.Color3 = Color3.new(0, 1, 0)
        end

        local mouse = IYMouse
        local moveConn, clickConn
        
        moveConn = mouse.Move:Connect(function()
            local target = mouse.Target
            if target and target.Parent:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(target.Parent) then
                    HoverBox.Adornee = target.Parent
                else
                    HoverBox.Adornee = nil
                end
            else
                HoverBox.Adornee = nil
            end
        end)

        clickConn = mouse.Button1Down:Connect(function()
            local target = mouse.Target
            if target and target.Parent:FindFirstChildOfClass("Humanoid") then
                if not Players:GetPlayerFromCharacter(target.Parent) then
                    TargetNPC = target.Parent
                    SelectedBox.Adornee = TargetNPC
                    moveConn:Disconnect()
                    clickConn:Disconnect()
                    HoverBox.Adornee = nil
                    
                    if toClipboard then
                        toClipboard(TargetNPC:GetFullName())
                    end
                    
                    task.delay(5, function()
                        if SelectedBox then SelectedBox.Adornee = nil end
                    end)
                end
            else
                moveConn:Disconnect()
                clickConn:Disconnect()
                HoverBox.Adornee = nil
            end
        end)
    end
}

Plugin.Commands["controlnpcmode"] = {
    ["ListName"] = "controlnpcmode [true/false]",
    ["Description"] = "Toggle method of control",
    ["Aliases"] = {"cnpcmode"},
    ["Function"] = function(args, speaker)
        if args[1] and (args[1]:lower() == "true" or args[1]:lower() == "on") then
            ControlMode = true
        else
            ControlMode = false
        end
    end
}

Plugin.Commands["controlnpc"] = {
    ["ListName"] = "controlnpc [path] [x] [y] [z] [rx] [ry] [rz]",
    ["Description"] = "Take control of the selected NPC",
    ["Aliases"] = {"cnpc"},
    ["Function"] = function(args, speaker)
        if not TargetNPC then return end
        if Players:GetPlayerFromCharacter(TargetNPC) then return end
        
        realcharacter = speaker.Character
        fakecharacter = TargetNPC

        if not realcharacter or not fakecharacter then return end

        local ox = tonumber(args[2]) or 0
        local oy = tonumber(args[3]) or 0
        local oz = tonumber(args[4]) or 0
        local rx = tonumber(args[5]) or 0
        local ry = tonumber(args[6]) or 0
        local rz = tonumber(args[7]) or 0

        RideOffset = CFrame.new(ox, oy, oz) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))

        execCmd("noclipping")
        setCharPhysics(speaker, false)

        if ControlMode then
            handleUI(speaker, true)
            speaker.Character = fakecharacter
        end

        ControlConnection = RunService.Heartbeat:Connect(function()
            if not fakecharacter or not fakecharacter.Parent or not realcharacter.Parent then
                execCmd("uncontrolnpc")
                return
            end

            if sethidden then
                pcall(sethidden, speaker, "SimulationRadius", 100000000)
            end

            local realRoot = realcharacter:FindFirstChild("HumanoidRootPart")
            local fakeRoot = fakecharacter:FindFirstChild("HumanoidRootPart") or fakecharacter:FindFirstChild("Torso")
            local fakeHum = fakecharacter:FindFirstChildOfClass("Humanoid")

            if not realRoot or not fakeRoot or not fakeHum then return end

            if not ControlMode then
                realRoot.CFrame = fakeRoot.CFrame * RideOffset
                if sethidden then
                    pcall(sethidden, realRoot, "PhysicsRepRootPart", fakeRoot:GetPivot() * RideOffset)
                end
                realRoot.AssemblyLinearVelocity = fakeRoot.AssemblyLinearVelocity
                realRoot.AssemblyAngularVelocity = fakeRoot.AssemblyAngularVelocity
            end

            local moveVec = getMoveVector()
            
            if moveVec.Magnitude > 0 then
                if IsFlinging and not ControlMode then
                    fakeHum:Move(Vector3.one * FlingPower)
                else
                    fakeHum:Move(moveVec)
                end
            else
                fakeHum:Move(Vector3.zero)
            end

            if InputService:IsKeyDown(Enum.KeyCode.Space) and not InputService:GetFocusedTextBox() then
                fakeHum.Jump = true
            end
        end)
    end
}

Plugin.Commands["ridenpc"] = {
    ["ListName"] = "ridenpc [x] [y] [z] [rx] [ry] [rz]",
    ["Description"] = "Ride the selected NPC",
    ["Aliases"] = {"npcride"},
    ["Function"] = function(args, speaker)
        if not TargetNPC then return end
        execCmd("controlnpc")
        
        local hum = realcharacter and realcharacter:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.Sit = true end
    end
}

Plugin.Commands["uncontrolnpc"] = {
    ["ListName"] = "uncontrolnpc",
    ["Description"] = "Return character control",
    ["Aliases"] = {"uncnpc"},
    ["Function"] = function(args, speaker)
        if ControlConnection then ControlConnection:Disconnect() end
        
        if ControlMode and realcharacter then
            speaker.Character = realcharacter
            handleUI(speaker, false)
        end

        setCharPhysics(speaker, true)
        
        if realcharacter then
            local hum = realcharacter:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.Sit = false end
        end
        
        if fakecharacter then
            local fakeHum = fakecharacter:FindFirstChildWhichIsA("Humanoid")
            if fakeHum then fakeHum:Move(Vector3.zero) end
        end
        
        execCmd("unnoclip")
        realcharacter = nil
        fakecharacter = nil
        ControlMode = false
        RideOffset = CFrame.new()
    end
}

Plugin.Commands["npcflingmode"] = {
    ["ListName"] = "npcflingmode [power]",
    ["Description"] = "Toggle NaN fling for NPC",
    ["Aliases"] = {"nfmode"},
    ["Function"] = function(args, speaker)
        IsFlinging = not IsFlinging
        if args[1] then FlingPower = tonumber(args[1]) end
    end
}

return Plugin