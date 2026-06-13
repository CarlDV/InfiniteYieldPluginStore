local gotonext = {
    ["PluginName"] = "GotoNext",
    ["PluginDescription"] = "Teleport sequentially to parts, models, or folders with optional prefix and delay, with break support",
    ["Commands"] = {}
}

-- Shared running flag
local running = false

-- GotoBreak
gotonext.Commands["GotoBreak"] = {
    ["ListName"] = "GotoBreak",
    ["Description"] = "Stops any running Gotopartnext/Gotomodelnext/Gotofoldernext sequence",
    ["Aliases"] = {"gb"},
    ["Function"] = function(args, speaker)
        if running then
            running = false
            notify("GotoBreak","Teleport sequence stopped!",3)
        else
            notify("GotoBreak","No active teleport sequence.",3)
        end
    end
}

-- Gotopartnext
gotonext.Commands["Gotopartnext"] = {
    ["ListName"] = "Gotopartnext",
    ["Description"] = "Teleport sequentially through parts with optional prefix and delay",
    ["Aliases"] = {"gpn"},
    ["Function"] = function(args, speaker)
        if not speaker.Character then return end
        local hrp = speaker.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local prefix, startNum, endNum, delay
        if tonumber(args[1]) then
            prefix = ""
            startNum = tonumber(args[1])
            endNum = tonumber(args[2]) or startNum
            delay = tonumber(args[3]) or 0.5
        else
            prefix = args[1] or ""
            startNum = tonumber(args[2]) or 0
            endNum = tonumber(args[3]) or startNum
            delay = tonumber(args[4]) or 0.5
        end

        local objects = {}
        for i = startNum, endNum do
            local namesToTry = {prefix..i, prefix.." "..i}
            local foundPart = nil
            for _, name in ipairs(namesToTry) do
                local part = workspace:FindFirstChild(name,true)
                if part and part:IsA("BasePart") then
                    foundPart = part
                    break
                end
            end
            if foundPart then
                table.insert(objects, foundPart)
            else
                notify("Gotopartnext","Part "..prefix..i.." does not exist",2)
            end
        end

        if #objects == 0 then
            notify("Gotopartnext","No parts found for "..prefix.." "..startNum.." to "..endNum,3)
            return
        end

        notify("Gotopartnext","Teleporting "..#objects.." parts with "..delay.."s delay",3)
        running = true

        for _, part in ipairs(objects) do
            if not running then break end
            hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
            notify("Gotopartnext","Teleported to "..part.Name,0.3)
            wait(delay)
        end

        running = false
        notify("Gotopartnext","Teleport sequence finished",2)
    end
}

-- Gotomodelnext
gotonext.Commands["Gotomodelnext"] = {
    ["ListName"] = "Gotomodelnext",
    ["Description"] = "Teleport sequentially through models with optional prefix and delay",
    ["Aliases"] = {"gmn"},
    ["Function"] = function(args, speaker)
        if not speaker.Character then return end
        local hrp = speaker.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local prefix, startNum, endNum, delay
        if tonumber(args[1]) then
            prefix = ""
            startNum = tonumber(args[1])
            endNum = tonumber(args[2]) or startNum
            delay = tonumber(args[3]) or 0.5
        else
            prefix = args[1] or ""
            startNum = tonumber(args[2]) or 0
            endNum = tonumber(args[3]) or startNum
            delay = tonumber(args[4]) or 0.5
        end

        local objects = {}
        for i = startNum, endNum do
            local namesToTry = {prefix..i, prefix.." "..i}
            local foundModel = nil
            for _, name in ipairs(namesToTry) do
                local model = workspace:FindFirstChild(name,true)
                if model and model:IsA("Model") then
                    foundModel = model
                    break
                end
            end
            if foundModel then
                table.insert(objects, foundModel)
            else
                notify("Gotomodelnext","Model "..prefix..i.." does not exist",2)
            end
        end

        if #objects == 0 then
            notify("Gotomodelnext","No models found for "..prefix.." "..startNum.." to "..endNum,3)
            return
        end

        notify("Gotomodelnext","Teleporting "..#objects.." models with "..delay.."s delay",3)
        running = true

        for _, model in ipairs(objects) do
            if not running then break end
            local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0,3,0)
                notify("Gotomodelnext","Teleported to "..model.Name,0.3)
            end
            wait(delay)
        end

        running = false
        notify("Gotomodelnext","Teleport sequence finished",2)
    end
}

-- Gotofoldernext
gotonext.Commands["Gotofoldernext"] = {
    ["ListName"] = "Gotofoldernext",
    ["Description"] = "Teleport sequentially through folders with optional prefix and delay",
    ["Aliases"] = {"gfn"},
    ["Function"] = function(args, speaker)
        if not speaker.Character then return end
        local hrp = speaker.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local prefix, startNum, endNum, delay
        if tonumber(args[1]) then
            prefix = ""
            startNum = tonumber(args[1])
            endNum = tonumber(args[2]) or startNum
            delay = tonumber(args[3]) or 0.5
        else
            prefix = args[1] or ""
            startNum = tonumber(args[2]) or 0
            endNum = tonumber(args[3]) or startNum
            delay = tonumber(args[4]) or 0.5
        end

        local objects = {}
        for i = startNum, endNum do
            local namesToTry = {prefix..i, prefix.." "..i}
            local foundFolder = nil
            for _, name in ipairs(namesToTry) do
                local folder = workspace:FindFirstChild(name,true)
                if folder and folder:IsA("Folder") then
                    foundFolder = folder
                    break
                end
            end
            if foundFolder then
                table.insert(objects, foundFolder)
            else
                notify("Gotofoldernext","Folder "..prefix..i.." does not exist",2)
            end
        end

        if #objects == 0 then
            notify("Gotofoldernext","No folders found for "..prefix.." "..startNum.." to "..endNum,3)
            return
        end

        notify("Gotofoldernext","Teleporting "..#objects.." folders with "..delay.."s delay",3)
        running = true

        for _, folder in ipairs(objects) do
            if not running then break end
            local children = folder:GetChildren()
            table.sort(children, function(a,b) return a.Name < b.Name end)
            for _, obj in ipairs(children) do
                if not running then break end
                local targetPart = nil
                if obj:IsA("BasePart") then
                    targetPart = obj
                elseif obj:IsA("Model") then
                    targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                end
                if targetPart then
                    hrp.CFrame = targetPart.CFrame + Vector3.new(0,3,0)
                    notify("Gotofoldernext","Teleported to "..obj.Name,0.3)
                    wait(delay)
                end
            end
        end

        running = false
        notify("Gotofoldernext","Teleport sequence finished",2)
    end
}

return gotonext