task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
end)

local HS = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CORE = game:GetService("CoreGui")
local PLR = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")

local function applyImage(url, img)
    task.spawn(function()
        local name = url:match("([^/]+)$") or "temp.png"
        local path = "iy_store_" .. name
        if isfile and isfile(path) and getcustomasset then
            pcall(function()
                img.Image = getcustomasset(path)
            end)
            return
        end
        local ok, data = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and data and writefile and getcustomasset then
            pcall(function()
                writefile(path, data)
                img.Image = getcustomasset(path)
            end)
        end
    end)
end

local API = "https://iyplugins.pages.dev"

local existing = CORE:FindFirstChild("IYStoreUI") or PLR.PlayerGui:FindFirstChild("IYStoreUI")
if existing then
    existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "IYStoreUI"
gui.ResetOnSpawn = false
pcall(function()
    gui.Parent = CORE
end)
if not gui.Parent then
    gui.Parent = PLR:WaitForChild("PlayerGui")
end

local splash = Instance.new("Frame", gui)
splash.Size = UDim2.new(0, 280, 0, 130)
splash.Position = UDim2.new(0.5, 0, 0.5, 0)
splash.AnchorPoint = Vector2.new(0.5, 0.5)
splash.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
splash.BorderSizePixel = 0

Instance.new("UICorner", splash).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", splash).Color = Color3.fromRGB(48, 48, 52)

local splashLogo = Instance.new("ImageLabel", splash)
splashLogo.Size = UDim2.new(0, 36, 0, 36)
splashLogo.Position = UDim2.new(0.5, -18, 0, 15)
splashLogo.BackgroundTransparency = 1
splashLogo.ScaleType = Enum.ScaleType.Fit
applyImage("https://iyplugins.pages.dev/assets/Logo_Small.png", splashLogo)

local splashTitle = Instance.new("TextLabel", splash)
splashTitle.Text = "Plugin Store"
splashTitle.Size = UDim2.new(1, 0, 0, 32)
splashTitle.Position = UDim2.new(0, 0, 0, 52)
splashTitle.TextColor3 = Color3.fromRGB(245, 245, 247)
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextSize = 16
splashTitle.BackgroundTransparency = 1

local splashStatus = Instance.new("TextLabel", splash)
splashStatus.Text = "Initializing..."
splashStatus.Size = UDim2.new(1, 0, 0, 16)
splashStatus.Position = UDim2.new(0, 0, 0, 76)
splashStatus.TextColor3 = Color3.fromRGB(158, 158, 162)
splashStatus.Font = Enum.Font.Gotham
splashStatus.TextSize = 11
splashStatus.BackgroundTransparency = 1

local bar = Instance.new("Frame", splash)
bar.Size = UDim2.new(0.7, 0, 0, 2)
bar.Position = UDim2.new(0.15, 0, 0.85, 0)
bar.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
bar.BorderSizePixel = 0

local fill = Instance.new("Frame", bar)
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(245, 245, 247)
fill.BorderSizePixel = 0

local all = {}
local pluginMap = {}
local cur = nil
local winPos = UDim2.new(0.5, 0, 0.5, 0)
local window, details, installBtn, scrl, dTitle, dScrl

local storeConfig = { useAnims = true }
pcall(function()
    if isfile and isfile("iy_store_config.json") and readfile then
        local data = HS:JSONDecode(readfile("iy_store_config.json"))
        if type(data) == "table" then storeConfig = data end
    end
end)

local function saveConfig()
    if writefile then
        pcall(function() writefile("iy_store_config.json", HS:JSONEncode(storeConfig)) end)
    end
end

local function connectHover(btn, def, hover)
    btn.MouseEnter:Connect(function()
        TS:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = hover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TS:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = def }):Play()
    end)
end

local function playAnim(tgt, open, cb)
    local isWindow = (tgt == window)
    local targetSize = isWindow and UDim2.new(0.9, 0, 0.85, 0) or UDim2.new(0.95, 0, 0.9, 0)
    
    if not storeConfig.useAnims then
        if open then
            tgt.Visible = true
            tgt.Size = targetSize
            tgt.BackgroundTransparency = 0
            local stroke = tgt:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = 0 end
            if cb then cb() end
        else
            tgt.Visible = false
            if cb then cb() end
        end
        return
    end

    if open then
        tgt.Visible = true
        tgt.Size = UDim2.new(0, 0, 0, 1)
        tgt.BackgroundTransparency = 1
        local stroke = tgt:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Transparency = 1 end
        
        local t1 = TS:Create(tgt, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset, 0, 1),
            BackgroundTransparency = 0
        })
        t1:Play()
        t1.Completed:Connect(function()
            local t2 = TS:Create(tgt, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = targetSize
            })
            t2:Play()
            if stroke then TS:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 0 }):Play() end
            if cb then t2.Completed:Connect(cb) end
        end)
    else
        local t1 = TS:Create(tgt, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset, 0, 1)
        })
        local stroke = tgt:FindFirstChildOfClass("UIStroke")
        if stroke then TS:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 1 }):Play() end
        t1:Play()
        t1.Completed:Connect(function()
            local t2 = TS:Create(tgt, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 1),
                BackgroundTransparency = 1
            })
            t2:Play()
            t2.Completed:Connect(function()
                tgt.Visible = false
                tgt.Size = targetSize
                tgt.BackgroundTransparency = 0
                if stroke then stroke.Transparency = 0 end
                if cb then cb() end
            end)
        end)
    end
end

local function isGot(p)
    if not isfile then return false end
    for _, f in pairs(p.files or {}) do
        if f.filename:lower():match("%.iy$") and isfile(f.filename) then
            return true
        end
    end
    return false
end

local function getTitle(p)
    local names = {}
    for _, f in pairs(p.files or {}) do
        if f.filename:lower():match("%.iy$") then
            table.insert(names, (f.filename:gsub("%.iy$", "")))
        end
    end
    if #names > 0 then
        return table.concat(names, ", ")
    end
    return p.name or "nan"
end

local function dragGUI(handle, target)
    local dragging = false
    local startInput, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if target == window then
                winPos = target.Position
            end
        end
    end)
end

local function updateDownBtn()
    if cur then
        local got = isGot(cur)
        installBtn.Text = got and "Installed" or "Install"
        installBtn.BackgroundColor3 = got and Color3.fromRGB(44, 44, 48) or Color3.fromRGB(245, 245, 247)
        installBtn.TextColor3 = got and Color3.fromRGB(158, 158, 162) or Color3.fromRGB(24, 24, 26)
    end
end

local function refreshStates()
    task.spawn(function()
        for i, card in ipairs(scrl:GetChildren()) do
            if card:IsA("TextButton") and card:GetAttribute("p_id") then
                local pId = card:GetAttribute("p_id")
                local p = pluginMap[pId]
                if p then
                    local got = isGot(p)
                    local gb = card:FindFirstChild("gb")
                    local db = card:FindFirstChild("db")
                    if gb then
                        gb.Text = got and "GOT" or "GET"
                        gb.BackgroundColor3 = got and Color3.fromRGB(44, 44, 48) or Color3.fromRGB(245, 245, 247)
                        gb.TextColor3 = got and Color3.fromRGB(158, 158, 162) or Color3.fromRGB(24, 24, 26)
                    end
                    if db then
                        db.Visible = got
                    end
                end
            end
            if i % 10 == 0 then
                task.wait()
            end
        end
        updateDownBtn()
    end)
end

local function md(s)
    if type(s) ~= "string" or s == "" then return "" end
    
    s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    
    local blocks = {}
    s = s:gsub("```(.-)```", function(c)
        table.insert(blocks, c)
        return "\001" .. #blocks .. "\001"
    end)
    
    local inlines = {}
    s = s:gsub("`([^`\n]+)`", function(c)
        table.insert(inlines, c)
        return "\002" .. #inlines .. "\002"
    end)
    
    s = "\n" .. s
    s = s:gsub("\n&gt;&gt;&gt; (.*)", "\n<font color='#808080'><i>%1</i></font>")
    s = s:gsub("\n&gt; ([^\n]+)", "\n<font color='#808080'><i>%1</i></font>")
    s = s:gsub("\n### ([^\n]+)", "\n<font size='15'><b>%1</b></font>")
    s = s:gsub("\n## ([^\n]+)", "\n<font size='17'><b>%1</b></font>")
    s = s:gsub("\n# ([^\n]+)", "\n<font size='21'><b>%1</b></font>")
    s = s:gsub("\n%-# ([^\n]+)", "\n<font size='10' color='#707070'>%1</font>")
    s = s:gsub("\n%- ([^\n]+)", "\n• %1")
    s = s:gsub("\n%* ([^\n]+)", "\n• %1")
    s = s:sub(2)
    
    s = s:gsub("%[([^\n]-)%]%(([^\n]-)%)", "<font color='#5865F2'><u>%1</u></font>")
    
    s = s:gsub("%*%*%*([^\n]-)%*%*%*", "<b><i>%1</i></b>")
    s = s:gsub("%*%*([^\n]-)%*%*", "<b>%1</b>")
    s = s:gsub("__([^\n]-)__", "<u>%1</u>")
    s = s:gsub("%*([^\n]-)%*", "<i>%1</i>")
    s = s:gsub("_([^\n]-)_", "<i>%1</i>")
    s = s:gsub("~~([^\n]-)~~", "<s>%1</s>")
    s = s:gsub("||([^\n]-)||", "<font color='#404040'>[Spoiler: %1]</font>")
    
    s = s:gsub("&lt;@!?%d+&gt;", "<font color='#5865F2'>@user</font>")
    s = s:gsub("&lt;#%d+&gt;", "<font color='#5865F2'>#channel</font>")
    s = s:gsub("&lt;@&amp;%d+&gt;", "<font color='#5865F2'>@role</font>")
    s = s:gsub("&lt;a?:([^\n]-):%d+&gt;", ":%1:")
    
    for i = 1, #inlines do
        local safe = inlines[i]:gsub("%%", "%%%%")
        s = s:gsub("\002" .. i .. "\002", "<font face='RobotoMono' color='#A0A0A0'>" .. safe .. "</font>")
    end
    for i = 1, #blocks do
        local c = blocks[i]
        c = c:gsub("^%w+\n", "")
        local safe = c:gsub("%%", "%%%%")
        s = s:gsub("\001" .. i .. "\001", "<font face='RobotoMono' color='#A0A0A0'>" .. safe .. "</font>")
    end
    
    return s
end

window = Instance.new("Frame", gui)
window.Size = UDim2.new(0.9, 0, 0.85, 0)
window.Position = winPos
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
window.BorderSizePixel = 0
window.ClipsDescendants = true
window.Visible = false

Instance.new("UISizeConstraint", window).MaxSize = Vector2.new(460, 500)
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", window).Color = Color3.fromRGB(48, 48, 52)
Instance.new("UIScale", window)

local top = Instance.new("Frame", window)
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundTransparency = 1
top.BorderSizePixel = 0
top.ZIndex = 2
dragGUI(top, window)

local topSeparator = Instance.new("Frame", top)
topSeparator.Size = UDim2.new(1, 0, 0, 1)
topSeparator.Position = UDim2.new(0, 0, 1, -1)
topSeparator.BackgroundColor3 = Color3.fromRGB(48, 48, 52)
topSeparator.BorderSizePixel = 0
topSeparator.ZIndex = 2

local logo = Instance.new("ImageLabel", top)
logo.Size = UDim2.new(0, 24, 0, 24)
logo.Position = UDim2.new(0, 12, 0, 8)
logo.BackgroundTransparency = 1
logo.ScaleType = Enum.ScaleType.Fit
logo.ZIndex = 3
applyImage("https://iyplugins.pages.dev/assets/Logo_Small.png", logo)

local title = Instance.new("TextLabel", top)
title.Text = "Plugin Store"
title.TextColor3 = Color3.fromRGB(245, 245, 247)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 44, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.ZIndex = 3

local close = Instance.new("TextButton", top)
close.Text = "X"
close.Size = UDim2.new(0, 40, 1, 0)
close.Position = UDim2.new(1, -40, 0, 0)
close.BackgroundTransparency = 1
close.TextColor3 = Color3.fromRGB(158, 158, 162)
close.Font = Enum.Font.GothamMedium
close.TextSize = 14
close.BorderSizePixel = 0
close.ZIndex = 10
close.Active = true

local min = Instance.new("TextButton", top)
min.Text = "-"
min.Size = UDim2.new(0, 40, 1, 0)
min.Position = UDim2.new(1, -80, 0, 0)
min.BackgroundTransparency = 1
min.TextColor3 = Color3.fromRGB(158, 158, 162)
min.Font = Enum.Font.GothamMedium
min.TextSize = 16
min.BorderSizePixel = 0
min.ZIndex = 10
min.Active = true

local animBtn = Instance.new("TextButton", top)
animBtn.Text = storeConfig.useAnims and "★" or "☆"
animBtn.Size = UDim2.new(0, 40, 1, 0)
animBtn.Position = UDim2.new(1, -120, 0, 0)
animBtn.BackgroundTransparency = 1
animBtn.TextColor3 = storeConfig.useAnims and Color3.fromRGB(245, 245, 247) or Color3.fromRGB(158, 158, 162)
animBtn.Font = Enum.Font.GothamMedium
animBtn.TextSize = 16
animBtn.BorderSizePixel = 0
animBtn.ZIndex = 10
animBtn.Active = true

animBtn.MouseButton1Click:Connect(function()
    storeConfig.useAnims = not storeConfig.useAnims
    animBtn.Text = storeConfig.useAnims and "★" or "☆"
    animBtn.TextColor3 = storeConfig.useAnims and Color3.fromRGB(245, 245, 247) or Color3.fromRGB(158, 158, 162)
    saveConfig()
end)

connectHover(close, Color3.fromRGB(32, 32, 36), Color3.fromRGB(190, 60, 60))
connectHover(min, Color3.fromRGB(32, 32, 36), Color3.fromRGB(44, 44, 48))
connectHover(animBtn, Color3.fromRGB(32, 32, 36), Color3.fromRGB(44, 44, 48))

local box = Instance.new("TextBox", window)
box.PlaceholderText = "Search directory..."
box.Text = ""
box.Size = UDim2.new(1, -24, 0, 32)
box.Position = UDim2.new(0, 12, 0, 52)
box.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
box.TextColor3 = Color3.fromRGB(245, 245, 247)
box.PlaceholderColor3 = Color3.fromRGB(158, 158, 162)
box.BorderSizePixel = 0
box.Font = Enum.Font.Gotham
box.TextSize = 13
box.TextXAlignment = Enum.TextXAlignment.Left

Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", box).Color = Color3.fromRGB(48, 48, 52)
Instance.new("UIPadding", box).PaddingLeft = UDim.new(0, 10)

scrl = Instance.new("ScrollingFrame", window)
scrl.Size = UDim2.new(1, -20, 1, -100)
scrl.Position = UDim2.new(0, 10, 0, 94)
scrl.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
scrl.BorderSizePixel = 0
scrl.ScrollBarThickness = 2
scrl.ScrollBarImageColor3 = Color3.fromRGB(44, 44, 48)
scrl.CanvasSize = UDim2.new(0, 0, 0, 0)
scrl.AutomaticCanvasSize = Enum.AutomaticSize.Y

local gl = Instance.new("UIGridLayout", scrl)
gl.CellPadding = UDim2.new(0, 8, 0, 8)
gl.CellSize = UDim2.new(0.5, -4, 0, 52)
gl.HorizontalAlignment = Enum.HorizontalAlignment.Center

details = Instance.new("Frame", gui)
details.Size = UDim2.new(0.95, 0, 0.9, 0)
details.Position = UDim2.new(0.5, 0, 0.5, 0)
details.AnchorPoint = Vector2.new(0.5, 0.5)
details.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
details.BorderSizePixel = 0
details.ClipsDescendants = true
details.ZIndex = 15
details.Visible = false

Instance.new("UISizeConstraint", details).MaxSize = Vector2.new(420, 400)
Instance.new("UICorner", details).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", details).Color = Color3.fromRGB(48, 48, 52)
Instance.new("UIScale", details)

dTitle = Instance.new("TextLabel", details)
dTitle.Size = UDim2.new(1, -24, 0, 36)
dTitle.Position = UDim2.new(0, 12, 0, 8)
dTitle.BackgroundTransparency = 1
dTitle.TextColor3 = Color3.fromRGB(245, 245, 247)
dTitle.Font = Enum.Font.GothamBold
dTitle.TextSize = 16
dTitle.ZIndex = 16
dTitle.TextXAlignment = Enum.TextXAlignment.Left

dScrl = Instance.new("ScrollingFrame", details)
dScrl.Size = UDim2.new(1, -24, 1, -100)
dScrl.Position = UDim2.new(0, 12, 0, 52)
dScrl.BackgroundTransparency = 1
dScrl.CanvasSize = UDim2.new(0, 0, 0, 0)
dScrl.AutomaticCanvasSize = Enum.AutomaticSize.Y
dScrl.ScrollBarThickness = 2
dScrl.ZIndex = 16
dScrl.ScrollBarImageColor3 = Color3.fromRGB(44, 44, 48)

local dl = Instance.new("UIListLayout", dScrl)
dl.Padding = UDim.new(0, 8)

installBtn = Instance.new("TextButton", details)
installBtn.Text = "Install"
installBtn.Size = UDim2.new(0.5, -16, 0, 36)
installBtn.Position = UDim2.new(0, 12, 1, -42)
installBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 247)
installBtn.TextColor3 = Color3.fromRGB(24, 24, 26)
installBtn.Font = Enum.Font.GothamMedium
installBtn.TextSize = 14
installBtn.ZIndex = 17
installBtn.BorderSizePixel = 0
installBtn.Active = true
Instance.new("UICorner", installBtn).CornerRadius = UDim.new(0, 6)

local backBtn = Instance.new("TextButton", details)
backBtn.Text = "Close"
backBtn.Size = UDim2.new(0.5, -16, 0, 36)
backBtn.Position = UDim2.new(0.5, 4, 1, -42)
backBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 48)
backBtn.TextColor3 = Color3.fromRGB(245, 245, 247)
backBtn.BorderSizePixel = 0
backBtn.ZIndex = 17
backBtn.Font = Enum.Font.GothamMedium
backBtn.TextSize = 14
backBtn.Active = true
Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)

local openBtn = Instance.new("TextButton", gui)
openBtn.Text = "Store"
openBtn.Size = UDim2.new(0, 60, 0, 30)
openBtn.Position = UDim2.new(1, -70, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 247)
openBtn.TextColor3 = Color3.fromRGB(24, 24, 26)
openBtn.Visible = false
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 12
openBtn.BorderSizePixel = 0
openBtn.Active = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

connectHover(installBtn, Color3.fromRGB(245, 245, 247), Color3.fromRGB(255, 255, 255))
connectHover(backBtn, Color3.fromRGB(44, 44, 48), Color3.fromRGB(54, 54, 58))
connectHover(openBtn, Color3.fromRGB(245, 245, 247), Color3.fromRGB(255, 255, 255))

openBtn.MouseButton1Click:Connect(function()
    openBtn.Visible = false
    playAnim(window, true)
end)

local function parseIso(iso)
    if not iso then return 0 end
    local y, m, d, h, mi, s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if not y then return 0 end
    return y * 31536000 + m * 2592000 + d * 86400 + h * 3600 + mi * 60 + s
end

local function downloadPlugin(p, btn)
    task.spawn(function()
        btn.Text = "..."
        local saved = {}
        for _, f in pairs(p.files or {}) do
            if f.filename:lower():match("%.iy$") then
                local ok, content = pcall(function()
                    return game:HttpGet(API .. "/plugins/" .. p.id .. "/" .. f.filename)
                end)
                if ok and content then
                    pcall(function()
                        writefile(f.filename, content)
                    end)
                    table.insert(saved, f.filename)
                end
            end
        end
        if #saved > 0 then
            btn.Text = "GOT"
            task.wait(0.2)
            for _, name in pairs(saved) do
                pcall(function()
                    local add = addPlugin or (shared and shared.addPlugin)
                    if add then add(name) end
                end)
            end
            task.wait(0.3)
            refreshStates()
        else
            btn.Text = "ERR"
        end
    end)
end

local function remPlugin(p)
    if not delfile then return end
    for _, f in pairs(p.files or {}) do
        if f.filename:lower():match("%.iy$") then
            pcall(function()
                local del = deletePlugin or (shared and shared.deletePlugin)
                if del then del(f.filename) end
            end)
            pcall(function()
                delfile(f.filename)
            end)
        end
    end
    task.wait(0.2)
    refreshStates()
end

local function showInfo(p)
    cur = p
    updateDownBtn()
    for _, item in pairs(dScrl:GetChildren()) do
        if not item:IsA("UIListLayout") then
            item:Destroy()
        end
    end
    dTitle.Text = getTitle(p)
    playAnim(details, true)
    local desc = md(p.description)
    if desc ~= "" then
        local t = Instance.new("TextLabel", dScrl)
        t.Text = desc
        t.Size = UDim2.new(1, 0, 0, 0)
        t.AutomaticSize = Enum.AutomaticSize.Y
        t.ZIndex = 16
        t.RichText = true
        t.TextWrapped = true
        t.TextColor3 = Color3.fromRGB(158, 158, 162)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.Gotham
        t.TextSize = 13
        t.TextXAlignment = Enum.TextXAlignment.Left
    end
    if p.embeds then
        for _, em in pairs(p.embeds) do
            if em.title or (em.video and em.video.url) or (em.thumbnail and em.thumbnail.url) or (em.image and em.image.url) then
                local f = Instance.new("Frame", dScrl)
                f.Size = UDim2.new(1, 0, 0, 0)
                f.AutomaticSize = Enum.AutomaticSize.Y
                f.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
                f.BorderSizePixel = 0
                f.ZIndex = 16

                Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
                Instance.new("UIStroke", f).Color = Color3.fromRGB(48, 48, 52)
                Instance.new("UIListLayout", f).Padding = UDim.new(0, 6)

                local pad = Instance.new("UIPadding", f)
                pad.PaddingTop = UDim.new(0, 8)
                pad.PaddingBottom = UDim.new(0, 8)
                pad.PaddingLeft = UDim.new(0, 8)
                pad.PaddingRight = UDim.new(0, 8)

                if em.title then
                    local tLabel = Instance.new("TextLabel", f)
                    tLabel.Text = em.title
                    tLabel.Size = UDim2.new(1, 0, 0, 22)
                    tLabel.TextColor3 = Color3.fromRGB(245, 245, 247)
                    tLabel.BackgroundTransparency = 1
                    tLabel.Font = Enum.Font.GothamBold
                    tLabel.TextSize = 13
                    tLabel.ZIndex = 17
                    tLabel.TextXAlignment = Enum.TextXAlignment.Left
                end
                local dText = md(em.description)
                if dText ~= "" then
                    local dLabel = Instance.new("TextLabel", f)
                    dLabel.Text = dText
                    dLabel.Size = UDim2.new(1, 0, 0, 0)
                    dLabel.AutomaticSize = Enum.AutomaticSize.Y
                    dLabel.TextColor3 = Color3.fromRGB(158, 158, 162)
                    dLabel.BackgroundTransparency = 1
                    dLabel.ZIndex = 17
                    dLabel.Font = Enum.Font.Gotham
                    dLabel.TextSize = 12
                    dLabel.TextXAlignment = Enum.TextXAlignment.Left
                    dLabel.TextWrapped = true
                    dLabel.RichText = true
                end
                local imgUrl = (em.image and em.image.url) or (em.thumbnail and em.thumbnail.url)
                if imgUrl then
                    local imgLabel = Instance.new("ImageLabel", f)
                    imgLabel.Size = UDim2.new(1, 0, 0, 160)
                    imgLabel.ZIndex = 17
                    imgLabel.ClipsDescendants = true
                    imgLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
                    imgLabel.ScaleType = Enum.ScaleType.Fit
                    Instance.new("UICorner", imgLabel).CornerRadius = UDim.new(0, 4)
                    applyImage(imgUrl, imgLabel)
                end
            end
        end
    end
end

local drawTicket = 0
local function drawList(list)
    drawTicket = drawTicket + 1
    local ticket = drawTicket
    for _, item in pairs(scrl:GetChildren()) do
        if item:IsA("TextButton") then
            item:Destroy()
        end
    end
    task.spawn(function()
        task.wait(0.05)
        for i, p in ipairs(list) do
            if drawTicket ~= ticket then return end
            if i % 4 == 0 then task.wait() end

            local got = isGot(p)
            local card = Instance.new("TextButton", scrl)
            card.Name = "PluginCard"
            card.Text = ""
            card.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
            card.BorderSizePixel = 0

            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", card).Color = Color3.fromRGB(48, 48, 52)

            local name = Instance.new("TextLabel", card)
            name.Name = "PluginName"
            name.Text = getTitle(p)
            name.Size = UDim2.new(1, -94, 0, 18)
            name.Position = UDim2.new(0, 10, 0, 8)
            name.TextColor3 = Color3.fromRGB(245, 245, 247)
            name.Font = Enum.Font.GothamBold
            name.TextSize = 13
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.BackgroundTransparency = 1

            local author = Instance.new("TextLabel", card)
            author.Name = "PluginMeta"
            author.Text = (p.author and p.author.name or "Unknown") .. " • " .. (p.date and p.date:sub(1, 10) or "N/A")
            author.Size = UDim2.new(1, -94, 0, 16)
            author.Position = UDim2.new(0, 10, 0, 28)
            author.TextColor3 = Color3.fromRGB(158, 158, 162)
            author.Font = Enum.Font.Gotham
            author.TextSize = 11
            author.TextXAlignment = Enum.TextXAlignment.Left
            author.BackgroundTransparency = 1

            local gb = Instance.new("TextButton", card)
            gb.Name = "gb"
            gb.Size = UDim2.new(0, 42, 0, 24)
            gb.Position = UDim2.new(1, -48, 0.5, -12)
            gb.BackgroundColor3 = got and Color3.fromRGB(44, 44, 48) or Color3.fromRGB(245, 245, 247)
            gb.Text = got and "GOT" or "GET"
            gb.TextColor3 = got and Color3.fromRGB(158, 158, 162) or Color3.fromRGB(24, 24, 26)
            gb.Font = Enum.Font.GothamBold
            gb.TextSize = 10
            gb.BorderSizePixel = 0
            gb.Active = true
            Instance.new("UICorner", gb).CornerRadius = UDim.new(0, 4)

            local db = Instance.new("TextButton", card)
            db.Name = "db"
            db.Size = UDim2.new(0, 24, 0, 24)
            db.Position = UDim2.new(1, -78, 0.5, -12)
            db.BackgroundColor3 = Color3.fromRGB(44, 44, 48)
            db.Text = "×"
            db.TextColor3 = Color3.fromRGB(158, 158, 162)
            db.Font = Enum.Font.GothamBold
            db.TextSize = 16
            db.BorderSizePixel = 0
            db.Visible = got
            db.Active = true
            Instance.new("UICorner", db).CornerRadius = UDim.new(0, 4)

            card.MouseButton1Click:Connect(function() showInfo(p) end)
            gb.MouseButton1Click:Connect(function()
                if gb.Text == "GET" then downloadPlugin(p, gb) end
            end)
            db.MouseButton1Click:Connect(function() remPlugin(p) end)

            card:SetAttribute("p_id", p.id)

            connectHover(card, Color3.fromRGB(32, 32, 36), Color3.fromRGB(38, 38, 42))
            if got then
                connectHover(gb, Color3.fromRGB(44, 44, 48), Color3.fromRGB(54, 54, 58))
            else
                connectHover(gb, Color3.fromRGB(245, 245, 247), Color3.fromRGB(255, 255, 255))
            end
            connectHover(db, Color3.fromRGB(44, 44, 48), Color3.fromRGB(64, 44, 44))
        end
    end)
end

task.spawn(function()
    TS:Create(fill, TweenInfo.new(5, Enum.EasingStyle.Linear), { Size = UDim2.new(0.8, 0, 1, 0) }):Play()
    local ok, raw = false, ""
    local done = false
    task.spawn(function()
        ok, raw = pcall(function() return game:HttpGet(API .. "/data/plugins.json") end)
        done = true
    end)
    local start = tick()
    repeat task.wait(0.1) until (typeof(googIY) ~= "nil" or typeof(addPlugin) == "function" or (shared and shared.addPlugin) or (tick() - start > 15)) and done
    if ok and raw ~= "" then
        local data = HS:JSONDecode(raw)
        all = data.plugins or {}
        for _, p in ipairs(all) do
            p._ts = parseIso(p.date)
            pluginMap[p.id] = p
        end
        table.sort(all, function(x, y) return x._ts > y._ts end)
        TS:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { Size = UDim2.new(1, 0, 1, 0) }):Play()
        task.wait(0.3)
        local fade = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
        TS:Create(splash, fade, { BackgroundTransparency = 1 }):Play()
        task.wait(0.2)
        splash:Destroy()
        playAnim(window, true)
        drawList(all)
    else
        splashStatus.Text = "Synchronization failed."
    end
end)

close.MouseButton1Click:Connect(function()
    playAnim(window, false, function() gui:Destroy() end)
end)

min.MouseButton1Click:Connect(function()
    playAnim(window, false, function() openBtn.Visible = true end)
end)

installBtn.MouseButton1Click:Connect(function()
    if cur then downloadPlugin(cur, installBtn) end
end)

backBtn.MouseButton1Click:Connect(function()
    playAnim(details, false)
end)

box:GetPropertyChangedSignal("Text"):Connect(function()
    local query = box.Text:lower()
    if query == "" then
        drawList(all)
        return
    end
    local matched = {}
    for _, p in pairs(all) do
        for _, f in pairs(p.files or {}) do
            if f.filename:lower():find(query, 1, true) then
                table.insert(matched, p)
                break
            end
        end
    end
    drawList(matched)
end)
