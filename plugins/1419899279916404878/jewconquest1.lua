local Plugin = {
    ["PluginName"] = "kill the jews with pew pew",
    ["PluginDescription"] = "made by bob company",
    ["Commands"] = {
        ["jews"] = {
            ["ListName"] = "jews [amount] [time]",
            ["Description"] = "oh no you dropped a penny!",
            ["Aliases"] = {"dropapenny","penny"},
            ["Function"] = function(args,speaker)
                local plr = speaker
                local chr = plr.Character or plr.CharacterAdded:Wait()
                local TextChatService = game:GetService("TextChatService")
                
                local cloneCount = tonumber(args[1]) or 5
                local countdownTime = tonumber(args[2]) or 10
                
                local hatIds = {
                    "rbxassetid://12347087688",
                    "rbxassetid://14089474860",
                    "rbxassetid://6535831523"
                }
                local shirtUrl = "http://www.roblox.com/asset/?id=17793854519"
                local pantsUrl = "http://www.roblox.com/asset/?id=123817216958488"
                local walkAnimId = "rbxassetid://507777826"
                local dialogues = {"OY OY VEY", "IS THAT A PENNY?", "I CONTROL THE PRESS", "I DID 9/11"} 
                
                local gui = Instance.new("ScreenGui")
                gui.Parent = plr.PlayerGui
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0,200,0,50)
                label.Position = UDim2.new(0,10,0,10)
                label.BackgroundTransparency = 0.3
                label.BackgroundColor3 = Color3.new(0,0,0)
                label.TextColor3 = Color3.new(1,1,1)
                label.Font = Enum.Font.SourceSansBold
                label.TextScaled = true
                label.Parent = gui
                
                local countdownLabel = Instance.new("TextLabel")
                countdownLabel.Size = UDim2.new(0,200,0,50)
                countdownLabel.Position = UDim2.new(0,10,0,70)
                countdownLabel.BackgroundTransparency = 0.3
                countdownLabel.BackgroundColor3 = Color3.new(0,0,0)
                countdownLabel.TextColor3 = Color3.new(1,0,0)
                countdownLabel.Font = Enum.Font.SourceSansBold
                countdownLabel.TextScaled = true
                countdownLabel.Parent = gui
                
                local alive = 0
                local spawnedClones = {}
                
                local function updateLabel()
                    label.Text = "jews left: " .. alive
                end
                
                local head = chr:WaitForChild("Head")
                local currentAudio = Instance.new("Sound")
                currentAudio.SoundId = "rbxassetid://1837189819"
                currentAudio.Looped = true
                currentAudio.Parent = head
                currentAudio:Play()
                
                local function ragdollHumanoid(hum)
                    local model = hum.Parent
                    for _, joint in ipairs(model:GetDescendants()) do
                        if joint:IsA("Motor6D") then
                            joint:Destroy()
                        elseif joint:IsA("BasePart") then
                            joint.Anchored = false
                            joint.CanCollide = true
                        end
                    end
                end
                
                local function checkAllDead()
                    for _, hum in ipairs(spawnedClones) do
                        if hum and hum.Parent and hum.Health > 0 then
                            return false
                        end
                    end
                    return true
                end
                
                local function handleAllDead()
                    for _, g in ipairs(plr.PlayerGui:GetChildren()) do
                        g:Destroy()
                    end
                
                    local killedLabel = Instance.new("TextLabel")
                    killedLabel.Size = UDim2.new(0,200,0,100)
                    killedLabel.Position = UDim2.new(0.5, -100, 0.5, -50)
                    killedLabel.BackgroundTransparency = 0.3
                    killedLabel.BackgroundColor3 = Color3.new(0,0,0)
                    killedLabel.TextColor3 = Color3.new(1,0,0)
                    killedLabel.Font = Enum.Font.SourceSansBold
                    killedLabel.TextScaled = true
                    killedLabel.Text = "-"..cloneCount
                    killedLabel.Parent = plr.PlayerGui
                
                    task.wait(1)
                    plr:Kick("you saved the world from the goys")
                end
                
                for i = 1, cloneCount do
                    local spawned = Instance.new("Model")
                    spawned.Name = "goyboy"
                    spawned.Parent = workspace
                
                    local spawnPos = chr.HumanoidRootPart.Position + Vector3.new(
                        math.random(6, 15) * (math.random(0,1) == 0 and -1 or 1),
                        0,
                        math.random(6, 15) * (math.random(0,1) == 0 and -1 or 1)
                    )
                
                    local hum
                    local rootPart
                    local headPart
                
                    for _, child in ipairs(chr:GetChildren()) do
                        if child:IsA("BasePart") then
                            local part = child:Clone()
                            part.Anchored = false
                            part.CanCollide = true
                            part.CFrame = child.CFrame + (spawnPos - chr.HumanoidRootPart.Position)
                            part.Parent = spawned
                            if child.Name == "HumanoidRootPart" then
                                rootPart = part
                            elseif child.Name == "Head" then
                                headPart = part
                            end
                        elseif child:IsA("Humanoid") then
                            hum = child:Clone()
                            hum.DisplayName = "kike"
                            hum.RigType = Enum.HumanoidRigType.R15
                            hum.Parent = spawned
                        end
                    end
                
                    alive = alive + 1
                    updateLabel()
                    table.insert(spawnedClones, hum)
                
                    local shirt = Instance.new("Shirt")
                    shirt.ShirtTemplate = shirtUrl
                    shirt.Parent = spawned
                
                    local pants = Instance.new("Pants")
                    pants.PantsTemplate = pantsUrl
                    pants.Parent = spawned
                
                    local animator = hum:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", hum)
                    local anim = Instance.new("Animation")
                    anim.AnimationId = walkAnimId
                    local track = animator:LoadAnimation(anim)
                    track.Looped = true
                    track:Play()
                
                    hum.Died:Connect(function()
                        alive = alive - 1
                        updateLabel()
                        ragdollHumanoid(hum)
                        if checkAllDead() then
                            handleAllDead()
                        end
                    end)
                
                    task.spawn(function()
                        while hum and hum.Parent and rootPart and rootPart.Parent do
                            local target = rootPart.Position + Vector3.new(math.random(-60,60),0,math.random(-60,60))
                            hum:MoveTo(target)
                            task.wait(0.5)
                        end
                    end)
                
                    task.spawn(function()
                        while hum and hum.Parent and headPart and headPart.Parent do
                            local msg = dialogues[math.random(1,#dialogues)]
                            TextChatService:DisplayBubble(headPart, msg)
                            task.wait(math.random(5,10))
                        end
                    end)
                
                    for _, id in ipairs(hatIds) do
                        local hat = game:GetObjects(id)[1]
                        if hat then
                            hat.Parent = spawned
                        end
                    end
                end
                
                task.spawn(function()
                    local countdown = countdownTime
                    while countdown > 0 do
                        countdownLabel.Text = "time left: "..countdown.."s"
                        countdown = countdown - 1
                        task.wait(1)
                    end
                
                    local stillAlive = false
                    for _, hum in ipairs(spawnedClones) do
                        if hum and hum.Parent and hum.Health > 0 then
                            stillAlive = true
                            break
                        end
                    end
                
                    if stillAlive then
                        plr:Kick("the jews dominated the world")
                    end
                end)
                
                local gun = Instance.new("Tool")
                gun.Name = ".1488 revolver"
                gun.RequiresHandle = true
                
                local handle = Instance.new("Part")
                handle.Name = "Handle"
                handle.Size = Vector3.new(0.5,0.5,2)
                handle.Color = Color3.new(0.2,0.2,0.2)
                handle.Parent = gun
                
                gun.Parent = plr.Backpack
                
                gun.Activated:Connect(function()
                    local bullet = Instance.new("Part")
                    bullet.Size = Vector3.new(0.2,0.2,0.2)
                    bullet.Shape = Enum.PartType.Ball
                    bullet.BrickColor = BrickColor.new("Bright red")
                    bullet.CanCollide = false
                    bullet.CFrame = chr.Head.CFrame + (chr.Head.CFrame.LookVector * 2)
                    bullet.Velocity = chr.Head.CFrame.LookVector * 300
                    bullet.Parent = workspace
                
                    local connection
                    connection = bullet.Touched:Connect(function(hit)
                        for _, hum in ipairs(spawnedClones) do
                            if hum and hum.Parent and hit:IsDescendantOf(hum.Parent) then
                                hum:TakeDamage(25)
                                bullet:Destroy()
                                connection:Disconnect()
                                break
                            end
                        end
                    end)
                
                    game.Debris:AddItem(bullet,5)
                end)
            end
        }
     }
}

return Plugin
