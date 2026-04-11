local Plugin = {
    ["PluginName"] = "FlingPackCustom",
    ["PluginDescription"] = "Advanced fling bundle for IY",
    ["Commands"] = {
        ["ffling"] = {
            ["ListName"] = "ffling [power]",
            ["Description"] = "Custom spin fling. Default power is 99999",
            ["Aliases"] = {"ff"},
            ["Function"] = function(args, speaker)
                local power = tonumber(args[1]) or 99999
                flinging = false
                for _, child in pairs(speaker.Character:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
                    end
                end
                execCmd('noclip')
                task.wait(0.1)
                local bambam = Instance.new("BodyAngularVelocity")
                bambam.Name = randomString()
                bambam.Parent = getRoot(speaker.Character)
                bambam.MaxTorque = Vector3.new(0, math.huge, 0)
                bambam.P = math.huge
                
                for _, v in next, speaker.Character:GetChildren() do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.Massless = true
                        v.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                flinging = true
                flingDied = speaker.Character:FindFirstChildWhichIsA('Humanoid').Died:Connect(function()
                    execCmd('unffling')
                end)
                repeat
                    bambam.AngularVelocity = Vector3.new(0, power, 0)
                    task.wait(0.2)
                    bambam.AngularVelocity = Vector3.new(0, 0, 0)
                    task.wait(0.1)
                until flinging == false
            end
        },
        ["unffling"] = {
            ["ListName"] = "unffling",
            ["Description"] = "Stops ffling",
            ["Aliases"] = {"noffling"},
            ["Function"] = function(args, speaker)
                execCmd('clip')
                if flingDied then flingDied:Disconnect() end
                flinging = false
                task.wait(0.1)
                local speakerChar = speaker.Character
                if not speakerChar or not getRoot(speakerChar) then return end
                for _, v in pairs(getRoot(speakerChar):GetChildren()) do
                    if v.ClassName == 'BodyAngularVelocity' then v:Destroy() end
                end
                for _, child in pairs(speakerChar:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end
                end
            end
        },
        ["walkffling"] = {
            ["ListName"] = "walkffling [x] [y] [z]",
            ["Description"] = "Fling by walking. Can set X, Y, Z power. Default is 10000",
            ["Aliases"] = {"wff"},
            ["Function"] = function(args, speaker)
                execCmd("unwalkffling")
                local pX = tonumber(args[1]) or 10000
                local pY = tonumber(args[2]) or pX
                local pZ = tonumber(args[3]) or pX
                
                local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
                if humanoid then
                    humanoid.Died:Connect(function() execCmd("unwalkffling") end)
                end
                execCmd("noclip nonotify")
                walkflinging = true
                repeat RunService.Heartbeat:Wait()
                    local character = speaker.Character
                    local root = getRoot(character)
                    local vel, movel = nil, 0.1
                    if character and root then
                        vel = root.Velocity
                        root.Velocity = (vel * Vector3.new(pX, pY, pZ)) + Vector3.new(0, pY, 0)
                        RunService.RenderStepped:Wait()
                        if root then root.Velocity = vel end
                        RunService.Stepped:Wait()
                        if root then
                            root.Velocity = vel + Vector3.new(0, movel, 0)
                            movel = movel * -1
                        end
                    end
                until walkflinging == false
            end
        },
        ["unwalkffling"] = {
            ["ListName"] = "unwalkffling",
            ["Description"] = "Stops walkffling",
            ["Aliases"] = {"nowalkffling"},
            ["Function"] = function(args, speaker)
                walkflinging = false
                execCmd("unnoclip nonotify")
            end
        },
        ["moveffling"] = {
            ["ListName"] = "moveffling [power]",
            ["Description"] = "Uses Move humanoid state to fling",
            ["Aliases"] = {"mff"},
            ["Function"] = function(args, speaker)
                execCmd("unmoveffling")
                local p = tonumber(args[1]) or 50e35
                local VOID_VEL = Vector3.one * p
                local character = speaker.Character
                local hum = character and character:FindFirstChildWhichIsA("Humanoid")
                if hum then
                    mFlingL = RunService.Heartbeat:Connect(function()
                        if hum and hum.Parent then hum:Move(VOID_VEL) else execCmd("unmoveffling") end
                    end)
                    mFlingD = hum.Died:Once(function() execCmd("unmoveffling") end)
                end
            end
        },
        ["unmoveffling"] = {
            ["ListName"] = "unmoveffling",
            ["Description"] = "Stops moveffling",
            ["Aliases"] = {"nomoveffling"},
            ["Function"] = function(args, speaker)
                if mFlingL then mFlingL:Disconnect() mFlingL = nil end
                if mFlingD then mFlingD:Disconnect() mFlingD = nil end
            end
        }
    }
}

return Plugin
