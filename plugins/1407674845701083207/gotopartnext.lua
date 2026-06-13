-- GotoNext.iy
-- Fully polished Infinite Yield–style plugin
-- Teleport sequentially to Parts, Models, or Folders with advanced duplicate handling, TP All, ESP, and notifications

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local teleporting = false
local totalDuplicatesDetected = 0
local duplicatesSessionOrder = {} -- remembers chosen ordering per "name" for session
local activeDuplicatesGui = nil
local activeTracers = {}
local hue = 0

-- ================== UTILITIES ==================
local function notify(title, text, duration)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "GotoNextNotify"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.05, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextWrapped = true

    task.delay(duration or 2, function()
        if gui.Parent then gui:Destroy() end
    end)
end

local function clearTracers()
    for _, t in ipairs(activeTracers) do
        if t and t.Parent then t:Destroy() end
    end
    activeTracers = {}
end

local function createTracer(nextCFrame)
    clearTracers()
    if not nextCFrame then return end
    local tracer = Instance.new("Part")
    tracer.Name = "GotoNextTracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Size = Vector3.new(2,2,2)
    tracer.CFrame = nextCFrame + Vector3.new(0,3,0)
    tracer.Material = Enum.Material.Neon
    tracer.Parent = workspace
    table.insert(activeTracers, tracer)

    RunService.Heartbeat:Connect(function(dt)
        if tracer.Parent then
            hue = (hue + dt * 0.5) % 1
            tracer.Color = Color3.fromHSV(hue,1,1)
        end
    end)
end

local function fullParentPath(inst)
    if not inst then return "Unknown" end
    local path = {}
    local current = inst.Parent
    while current do
        table.insert(path, 1, current.Name)
        current = current.Parent
    end
    return table.concat(path,".") .. "." .. inst.Name
end

-- Recursively find instances by type and name
local function findMatches(objectType, name)
    local results = {}
    local function search(parent)
        for _, v in ipairs(parent:GetChildren()) do
            if ((objectType=="Part" and v:IsA("BasePart")) or
                (objectType=="Model" and v:IsA("Model")) or
                (objectType=="Folder" and v:IsA("Folder"))) and v.Name == name then
                table.insert(results, {inst=v, parent=v.Parent})
            end
            search(v)
        end
    end
    search(workspace)
    return results
end

local function teleportToInstance(player, inst)
    local character = player and player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local targetCFrame = nil

    if inst:IsA("BasePart") then
        targetCFrame = inst.CFrame
    elseif inst:IsA("Model") then
        targetCFrame = inst.PrimaryPart and inst.PrimaryPart.CFrame or inst:FindFirstChildWhichIsA("BasePart") and inst:FindFirstChildWhichIsA("BasePart").CFrame
    elseif inst:IsA("Folder") then
        return false
    end

    if targetCFrame then
        hrp.CFrame = targetCFrame + Vector3.new(0,3,0)
        return true
    end
    return false
end

-- ================== DUPLICATE GUI ==================
local function showDuplicatesGui(titleText, duplicates)
    local chosenOrder = nil
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GotoNextDuplicatesGui"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    activeDuplicatesGui = screenGui

    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.new(0, 460, 0, 360)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.Position = UDim2.new(0.5,0,0.5,0)
    main.BackgroundColor3 = Color3.fromRGB(30,30,30)
    main.BorderSizePixel = 0

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,-40,0,48)
    title.Position = UDim2.new(0,20,0,12)
    title.BackgroundTransparency = 1
    title.Text = "Duplicates found! — "..titleText
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- close button
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(1,-40,0,12)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 18
    closeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.BorderSizePixel = 0
    closeBtn.MouseButton1Click:Connect(function()
        chosenOrder = nil
        screenGui:Destroy()
        activeDuplicatesGui = nil
    end)

    -- scrolling list
    local list = Instance.new("ScrollingFrame", main)
    list.Size = UDim2.new(1,-40,1,-140)
    list.Position = UDim2.new(0,20,0,92)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 6
    local uiList = Instance.new("UIListLayout", list)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0,8)

    -- buttons
    for idx, info in ipairs(duplicates) do
        local btn = Instance.new("Frame", list)
        btn.Size = UDim2.new(1,0,0,52)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)

        local nameLabel = Instance.new("TextLabel", btn)
        nameLabel.Size = UDim2.new(1,-140,0,24)
        nameLabel.Position = UDim2.new(0,12,0,8)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = info.inst.Name
        nameLabel.TextColor3 = Color3.fromRGB(230,230,230)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 16
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        local parentLabel = Instance.new("TextLabel", btn)
        parentLabel.Size = UDim2.new(1,-140,0,20)
        parentLabel.Position = UDim2.new(0,12,0,28)
        parentLabel.BackgroundTransparency = 1
        parentLabel.Text = "Parent: "..fullParentPath(info.inst)
        parentLabel.TextColor3 = Color3.fromRGB(170,170,170)
        parentLabel.Font = Enum.Font.Gotham
        parentLabel.TextSize = 14
        parentLabel.TextXAlignment = Enum.TextXAlignment.Left

        local pickBtn = Instance.new("TextButton", btn)
        pickBtn.Size = UDim2.new(0,100,0,32)
        pickBtn.Position = UDim2.new(1,-112,0,10)
        pickBtn.Text = "Start Here"
        pickBtn.BackgroundColor3 = Color3.fromRGB(70,120,255)
        pickBtn.BorderSizePixel = 0
        pickBtn.TextColor3 = Color3.new(1,1,1)
        pickBtn.Font = Enum.Font.Gotham
        pickBtn.TextSize = 14

        pickBtn.MouseButton1Click:Connect(function()
            chosenOrder = { info.inst }
            screenGui:Destroy()
            activeDuplicatesGui = nil
        end)
    end

    -- TP ALL button
    local tpAllBtn = Instance.new("TextButton", main)
    tpAllBtn.Size = UDim2.new(0,120,0,36)
    tpAllBtn.Position = UDim2.new(0,20,1,-48)
    tpAllBtn.BackgroundColor3 = Color3.fromRGB(50,200,50)
    tpAllBtn.TextColor3 = Color3.new(1,1,1)
    tpAllBtn.Font = Enum.Font.Gotham
    tpAllBtn.TextSize = 16
    tpAllBtn.Text = "TP All"
    tpAllBtn.MouseButton1Click:Connect(function()
        chosenOrder = {}
        for _,info in ipairs(duplicates) do
            table.insert(chosenOrder, info.inst)
        end
        screenGui:Destroy()
        activeDuplicatesGui = nil
    end)

    -- parent GUI
    screenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")

    -- wait until destroyed or chosen
    while screenGui.Parent and chosenOrder==nil do task.wait(0.1) end
    return chosenOrder
end

-- ================== TELEPORT HANDLER ==================
local function handleSequence(objectType, args, speaker)
    local player = speaker or LocalPlayer
    if teleporting then
        notify("GotoNext","Sequence already running!",2)
        return
    end
    teleporting = true
    totalDuplicatesDetected = 0

    -- parse args
    local prefix, startNum, endNum, delay
    if tonumber(args[1]) then
        prefix = nil
        startNum = tonumber(args[1])
        endNum = tonumber(args[2]) or startNum
        delay = tonumber(args[3]) or 0.5
    else
        prefix = args[1]
        startNum = tonumber(args[2]) or 0
        endNum = tonumber(args[3]) or startNum
        delay = tonumber(args[4]) or 0.5
    end

    notify("GotoNext","Teleporting "..objectType.." "..tostring(startNum).." → "..tostring(endNum).." (delay "..tostring(delay).."s)",3)

    task.spawn(function()
        for i=startNum,endNum do
            if not teleporting then break end
            local name1 = (prefix and prefix..i) or tostring(i)
            local name2 = (prefix and prefix.." "..i) or nil

            local matches = findMatches(objectType,name1)
            if name2 then
                local more = findMatches(objectType,name2)
                for _,m in ipairs(more) do table.insert(matches,m) end
            end

            if #matches==0 then
                notify("GotoNext","No "..objectType.." named "..name1,2)
            else
                -- duplicates handling
                local sessionKey = name1
                if #matches>1 then
                    local chosen = nil
                    if duplicatesSessionOrder[sessionKey] then
                        chosen = duplicatesSessionOrder[sessionKey]
                    else
                        chosen = showDuplicatesGui(name1,matches)
                        if not chosen then
                            notify("GotoNext","Sequence canceled",2)
                            teleporting=false
                            return
                        end
                        duplicatesSessionOrder[sessionKey] = chosen
                    end
                    matches = {}
                    for _,inst in ipairs(chosen) do table.insert(matches,{inst=inst,parent=inst.Parent}) end
                    totalDuplicatesDetected = totalDuplicatesDetected + (#chosen-1)
                end

                -- teleport loop
                for idx,info in ipairs(matches) do
                    if not teleporting then break end
                    local target = info.inst
                    if objectType=="Folder" then
                        local children={}
                        for _,c in ipairs(target:GetDescendants()) do
                            if c:IsA("BasePart") then table.insert(children,c) end
                        end
                        table.sort(children,function(a,b) return a:GetFullName()<b:GetFullName() end)
                        for j=1,#children do
                            if not teleporting then break end
                            createTracer(j<#children and children[j+1].CFrame or nil)
                            teleportToInstance(player,children[j])
                            task.wait(delay)
                        end
                    else
                        createTracer(idx<#matches and (matches[idx+1].inst.PrimaryPart or matches[idx+1].inst:FindFirstChildWhichIsA("BasePart")) and (matches[idx+1].inst.PrimaryPart or matches[idx+1].inst:FindFirstChildWhichIsA("BasePart")).CFrame or nil)
                        teleportToInstance(player,target)
                        task.wait(delay)
                    end
                end
            end
        end

        clearTracers()
        if teleporting then
            notify("GotoNext","Finished teleporting! ⚠ Duplicates: "..tostring(totalDuplicatesDetected),4)
        else
            notify("GotoNext","Sequence stopped.",2)
        end
        teleporting=false
    end)
end

-- ================== PLUGIN TABLE ==================
local plugin = {
    PluginName="GotoNext",
    PluginDescription="Teleport sequentially to parts, models, or folders with advanced duplicate handling, TP All, ESP, and notifications",
    Commands={}
}

plugin.Commands["gotopartnext"]={
    ListName="Gotopartnext",
    Description="Teleport through parts by number sequence (prefix optional).",
    Aliases={"gpn"},
    Function=function(args,speaker) handleSequence("Part",args,speaker) end
}

plugin.Commands["gotomodelnext"]={
    ListName="Gotomodelnext",
    Description="Teleport through models by number sequence (prefix optional).",
    Aliases={"gmn"},
    Function=function(args,speaker) handleSequence("Model",args,speaker) end
}

plugin.Commands["gotofoldernext"]={
    ListName="Gotofoldernext",
    Description="Teleport through parts inside folders by number sequence (folderName required or numeric folder name).",
    Aliases={"gfn"},
    Function=function(args,speaker) handleSequence("Folder",args,speaker) end
}

plugin.Commands["gotobreak"]={
    ListName="GotoBreak",
    Description="Stops any active teleport sequence",
    Aliases={"gb"},
    Function=function()
        if teleporting then
            teleporting=false
            notify("GotoNext","Teleport sequence stopped!",3)
        else
            notify("GotoNext","No teleport in progress.",2)
        end
        if activeDuplicatesGui and activeDuplicatesGui.Parent then activeDuplicatesGui:Destroy() end
        activeDuplicatesGui=nil
        duplicatesSessionOrder={}
        clearTracers()
    end
}

return plugin