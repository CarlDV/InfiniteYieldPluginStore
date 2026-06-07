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
        local o, c = pcall(function() return game:HttpGet(url) end)
        if o and c and writefile and getcustomasset then
            local t = "iy_tmp_" .. tostring(math.random(1000, 9999)) .. ".png"
            pcall(function()
                writefile(t, c); img.Image = getcustomasset(t)
            end)
        end
    end)
end

local API = "https://raw.githubusercontent.com/CarlDV/InfiniteYieldPluginStore/main"

local existing = (CORE:FindFirstChild("IYStoreUI") or PLR.PlayerGui:FindFirstChild("IYStoreUI"))
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "IYStoreUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CORE end)
if not gui.Parent then gui.Parent = PLR:WaitForChild("PlayerGui") end

local splash = Instance.new("Frame")
splash.Size = UDim2.new(0, 280, 0, 130)
splash.Position = UDim2.new(0.5, 0, 0.5, 0)
splash.AnchorPoint = Vector2.new(0.5, 0.5)
splash.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
splash.BorderSizePixel = 0
splash.Parent = gui
Instance.new("UICorner", splash).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", splash).Color = Color3.fromRGB(7, 8, 7)

local slog = Instance.new("ImageLabel", splash)
slog.Size = UDim2.new(0, 36, 0, 36)
slog.Position = UDim2.new(0.5, -18, 0, 15)
slog.BackgroundTransparency = 1
slog.ScaleType = Enum.ScaleType.Fit
applyImage("https://raw.githubusercontent.com/CarlDV/InfiniteYieldPluginStore/main/assets/Logo_Small.png", slog)

local stitle = Instance.new("TextLabel")
stitle.Text = "Plugin Store"; stitle.Size = UDim2.new(1, 0, 0, 32); stitle.Position = UDim2.new(0, 0, 0, 52)
stitle.TextColor3 = Color3.fromRGB(234, 234, 234); stitle.Font = Enum.Font.GothamBold; stitle.TextSize = 16
stitle.BackgroundTransparency = 1; stitle.Parent = splash

local ssub = Instance.new("TextLabel")
ssub.Text = "Initializing..."; ssub.Size = UDim2.new(1, 0, 0, 16); ssub.Position = UDim2.new(0, 0, 0, 76)
ssub.TextColor3 = Color3.fromRGB(160, 160, 160); ssub.Font = Enum.Font.Gotham; ssub.TextSize = 11
ssub.BackgroundTransparency = 1; ssub.Parent = splash

local bar_bg = Instance.new("Frame")
bar_bg.Size = UDim2.new(0.7, 0, 0, 2); bar_bg.Position = UDim2.new(0.15, 0, 0.85, 0)
bar_bg.BackgroundColor3 = Color3.fromRGB(42, 42, 42); bar_bg.BorderSizePixel = 0; bar_bg.Parent = splash
local bar_fill = Instance.new("Frame")
bar_fill.Size = UDim2.new(0, 0, 1, 0); bar_fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); bar_fill.BorderSizePixel = 0; bar_fill.Parent =
bar_bg
local all = {}
local plugin_map = {}
local cur = nil
local winPos = UDim2.new(0.5, 0, 0.5, 0)
local win, info, downbtn, scrl

local TIOpen = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local TIClose = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function playAnim(tgt, open, cb)
    local tPos = (tgt == win) and winPos or UDim2.new(0.5, 0, 0.5, 0)
    local sc = tgt:FindFirstChildOfClass("UIScale")
    if open then
        tgt.Visible = true; tgt.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset, tPos.Y.Scale, tPos.Y.Offset + 15)
        if sc then
            sc.Scale = 0.9; TS:Create(sc, TIOpen, { Scale = 1 }):Play()
        end
        TS:Create(tgt, TIOpen, { Position = tPos }):Play()
    else
        local t = TS:Create(tgt, TIClose,
            { Position = UDim2.new(tPos.X.Scale, tPos.X.Offset, tPos.Y.Scale, tPos.Y.Offset + 15) })
        t:Play(); t.Completed:Connect(function()
            tgt.Visible = false; if cb then cb() end
        end)
    end
end

local function is_got(p)
    if not isfile then return false end
    for _, f in pairs(p.files or {}) do if f.filename:lower():match("%.iy$") and isfile(f.filename) then return true end end
    return false
end

local function getTitle(p)
    for _, f in pairs(p.files or {}) do if f.filename:lower():match("%.iy$") then return f.filename:gsub("%.iy$", "") end end
    return p.name or "nan"
end

local function dragGUI(obj)
    local d, ds, dp = false, nil, nil
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; dp = obj.Position
        end end)
    UIS.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local dt = i.Position - ds; obj.Position = UDim2.new(dp.X.Scale, dp.X.Offset + dt.X, dp.Y.Scale,
                dp.Y.Offset + dt.Y)
        end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = false; if obj == win then winPos = obj.Position end
        end end)
end
local function update_downbtn()
    if cur then
        local gt = is_got(cur)
        downbtn.Text = gt and "Installed" or "Install"
        downbtn.BackgroundColor3 = gt and Color3.fromRGB(51, 51, 51) or Color3.fromRGB(255, 255, 255)
        downbtn.TextColor3 = gt and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(30, 30, 30)
    end
end

local function refresh_states()
    task.spawn(function()
        for i, card in ipairs(scrl:GetChildren()) do
            if card:IsA("TextButton") and card:GetAttribute("p_id") then
                local p_id = card:GetAttribute("p_id")
                local p_obj = plugin_map[p_id]
                if p_obj then
                    local gt = is_got(p_obj)
                    local gb = card:FindFirstChild("gb")
                    local db = card:FindFirstChild("db")
                    if gb then
                        gb.Text = gt and "GOT" or "GET"
                        gb.BackgroundColor3 = gt and Color3.fromRGB(51, 51, 51) or Color3.fromRGB(255, 255, 255)
                        gb.TextColor3 = gt and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(30, 30, 30)
                    end
                    if db then db.Visible = gt end
                end
            end
            if i % 10 == 0 then task.wait() end
        end
        update_downbtn()
    end)
end

local function md(s)
    if type(s) ~= "string" or s == "" then return "" end
    s = s:gsub("<@!?%d+>", "@user"):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    s = s:gsub("%*%*(.-)%*%*", "<b>%1</b>"):gsub("%*(.-)%*", "<i>%1</i>")
    s = s:gsub("__(.-)__", "<u>%1</u>"):gsub("~~(.-)~~", "<s>%1</s>")
    s = s:gsub("```%w*\n?(.-)```", "<font color='#A0A0A0'>%1</font>")
    s = s .. "\n"
    s = s:gsub("&gt; (.-)\n", "<font color='#808080'><i>%1</i></font>\n")
    s = s:gsub("%-# (.-)\n", "<font size='10' color='#707070'>%1</font>\n")
    s = s:gsub("### (.-)\n", "<font size='15'><b>%1</b></font>\n")
    s = s:gsub("## (.-)\n", "<font size='17'><b>%1</b></font>\n")
    s = s:gsub("# (.-)\n", "<font size='21'><b>%1</b></font>\n")
    return s:sub(1, -2)
end


win = Instance.new("Frame")
win.Size = UDim2.new(0.9, 0, 0.85, 0); win.Position = winPos; win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = Color3.fromRGB(30, 30, 30); win.BorderSizePixel = 0; win.ClipsDescendants = true; win.Visible = false; win.Parent =
gui
Instance.new("UISizeConstraint", win).MaxSize = Vector2.new(460, 500)
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", win).Color = Color3.fromRGB(7, 8, 7)
Instance.new("UIScale", win)
dragGUI(win)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 40); top.BackgroundColor3 = Color3.fromRGB(42, 42, 42); top.BorderSizePixel = 0; top.Parent =
win
local logo = Instance.new("ImageLabel", top); logo.Size = UDim2.new(0, 24, 0, 24); logo.Position = UDim2.new(0, 12, 0, 8); logo.BackgroundTransparency = 1; logo.ScaleType = Enum.ScaleType.Fit
applyImage("https://raw.githubusercontent.com/CarlDV/InfiniteYieldPluginStore/main/Logo_Small.png", logo)
Instance.new("TextLabel", top).Text = "Plugin Store"; top.TextLabel.TextColor3 = Color3.fromRGB(234, 234, 234); top.TextLabel.BackgroundTransparency = 1; top.TextLabel.Size =
UDim2.new(1, -120, 1, 0); top.TextLabel.Position = UDim2.new(0, 44, 0, 0); top.TextLabel.TextXAlignment = Enum
.TextXAlignment.Left; top.TextLabel.Font = Enum.Font.GothamMedium; top.TextLabel.TextSize = 14
local close = Instance.new("TextButton", top); close.Text = "X"; close.Size = UDim2.new(0, 40, 1, 0); close.Position =
UDim2.new(1, -40, 0, 0); close.BackgroundColor3 = Color3.fromRGB(42, 42, 42); close.TextColor3 = Color3.fromRGB(160, 160,
    160); close.Font = Enum.Font.GothamMedium; close.TextSize = 14; close.BorderSizePixel = 0
local min = Instance.new("TextButton", top); min.Text = "-"; min.Size = UDim2.new(0, 40, 1, 0); min.Position = UDim2.new(
1, -80, 0, 0); min.BackgroundColor3 = Color3.fromRGB(42, 42, 42); min.TextColor3 = Color3.fromRGB(160, 160, 160); min.Font =
Enum.Font.GothamMedium; min.TextSize = 16; min.BorderSizePixel = 0

local box = Instance.new("TextBox", win); box.PlaceholderText = " Search directory..."; box.Text = ""; box.Size = UDim2
.new(1, -24, 0, 32); box.Position = UDim2.new(0, 12, 0, 52); box.BackgroundColor3 = Color3.fromRGB(51, 51, 51); box.TextColor3 =
Color3.fromRGB(234, 234, 234); box.PlaceholderColor3 = Color3.fromRGB(160, 160, 160); box.BorderSizePixel = 0; box.Font =
Enum.Font.Gotham; box.TextSize = 13; box.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", box).Color = Color3.fromRGB(7, 8,
    7); Instance.new("UIPadding", box).PaddingLeft = UDim.new(0, 10)

scrl = Instance.new("ScrollingFrame", win); scrl.Size = UDim2.new(1, -20, 1, -100); scrl.Position = UDim2.new(0, 10, 0,
    94); scrl.BackgroundColor3 = Color3.fromRGB(30, 30, 30); scrl.BorderSizePixel = 0; scrl.ScrollBarThickness = 2; scrl.ScrollBarImageColor3 =
Color3.fromRGB(51, 51, 51); scrl.CanvasSize = UDim2.new(0, 0, 0, 0); scrl.AutomaticCanvasSize = Enum.AutomaticSize.Y
local gl = Instance.new("UIGridLayout", scrl); gl.CellPadding = UDim2.new(0, 8, 0, 8); gl.CellSize = UDim2.new(0.5, -4, 0,
    52); gl.HorizontalAlignment = Enum.HorizontalAlignment.Center

info = Instance.new("Frame", gui); info.Size = UDim2.new(0.95, 0, 0.9, 0); info.Position = UDim2.new(0.5, 0, 0.5, 0); info.AnchorPoint =
Vector2.new(0.5, 0.5); info.BackgroundColor3 = Color3.fromRGB(30, 30, 30); info.BorderSizePixel = 0; info.ZIndex = 15; info.Visible = false
Instance.new("UISizeConstraint", info).MaxSize = Vector2.new(420, 400); Instance.new("UICorner", info).CornerRadius =
UDim.new(0, 5); Instance.new("UIStroke", info).Color = Color3.fromRGB(7, 8, 7); Instance.new("UIScale", info)

local ititle = Instance.new("TextLabel", info); ititle.Size = UDim2.new(1, -24, 0, 36); ititle.Position = UDim2.new(0, 12,
    0, 8); ititle.BackgroundTransparency = 1; ititle.TextColor3 = Color3.fromRGB(234, 234, 234); ititle.Font = Enum.Font
.GothamBold; ititle.TextSize = 18; ititle.ZIndex = 16; ititle.TextXAlignment = Enum.TextXAlignment.Left

local iscroll = Instance.new("ScrollingFrame", info); iscroll.Size = UDim2.new(1, -24, 1, -100); iscroll.Position = UDim2
.new(0, 12, 0, 52); iscroll.BackgroundTransparency = 1; iscroll.CanvasSize = UDim2.new(0, 0, 0, 0); iscroll.AutomaticCanvasSize =
Enum.AutomaticSize.Y; iscroll.ScrollBarThickness = 2; iscroll.ZIndex = 16; iscroll.ScrollBarImageColor3 = Color3.fromRGB(
51, 51, 51)
Instance.new("UIListLayout", iscroll).Padding = UDim.new(0, 8)

downbtn = Instance.new("TextButton", info); downbtn.Text = "Install"; downbtn.Size = UDim2.new(0.5, -16, 0, 36); downbtn.Position =
UDim2.new(0, 12, 1, -42); downbtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); downbtn.TextColor3 = Color3.fromRGB(
30, 30, 30); downbtn.Font = Enum.Font.GothamMedium; downbtn.TextSize = 14; downbtn.ZIndex = 16; downbtn.BorderSizePixel = 0; Instance.new("UICorner", downbtn).CornerRadius =
UDim.new(0, 4)

local bckbtn = Instance.new("TextButton", info); bckbtn.Text = "Close"; bckbtn.Size = UDim2.new(0.5, -16, 0, 36); bckbtn.Position =
UDim2.new(0.5, 4, 1, -42); bckbtn.BackgroundColor3 = Color3.fromRGB(51, 51, 51); bckbtn.TextColor3 = Color3.fromRGB(234,
    234, 234); bckbtn.BorderSizePixel = 0; bckbtn.ZIndex = 16; bckbtn.Font = Enum.Font.GothamMedium; bckbtn.TextSize = 14; Instance.new("UICorner", bckbtn).CornerRadius =
UDim.new(0, 4)
local fbtn = Instance.new("TextButton", gui); fbtn.Text = "Store"; fbtn.Size = UDim2.new(0, 60, 0, 30); fbtn.Position =
UDim2.new(1, -70, 0, 10); fbtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); fbtn.TextColor3 = Color3.fromRGB(30, 30,
    30); fbtn.Visible = false; fbtn.Font = Enum.Font.GothamBold; fbtn.TextSize = 12; fbtn.BorderSizePixel = 0; Instance.new("UICorner", fbtn).CornerRadius =
UDim.new(0, 4)
fbtn.MouseButton1Click:Connect(function()
    fbtn.Visible = false; playAnim(win, true)
end)
local function get_iso_time(iso)
    if not iso then return 0 end; local y, m, d, h, mi, s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"); if not y then return 0 end; return
    y * 31536000 + m * 2592000 + d * 86400 + h * 3600 + mi * 60 + s
end
local function dl_plugin(p, b)
    task.spawn(function()
        b.Text = "..."; local s = {}
        for _, f in pairs(p.files or {}) do
            if f.filename:lower():match("%.iy$") then
                local o, c = pcall(function() return game:HttpGet(API .. "/plugins/" .. p.id .. "/" .. f.filename) end)
                if o and c then
                    pcall(function() writefile(f.filename, c) end); table.insert(s, f.filename)
                end
            end
        end
        if #s > 0 then
            b.Text = "GOT"; task.wait(0.2)
            for _, n in pairs(s) do pcall(function()
                    local f = addPlugin or (shared and shared.addPlugin); if f then f(n) end
                end) end
            task.wait(0.3); refresh_states()
        else
            b.Text = "ERR"
        end
    end)
end
local function rem_plugin(p)
    if not delfile then return end
    for _, f in pairs(p.files or {}) do
        if f.filename:lower():match("%.iy$") then
            pcall(function()
                local del = deletePlugin or (shared and shared.deletePlugin); if del then del(f.filename) end
            end)
            pcall(function() delfile(f.filename) end)
        end
    end
    task.wait(0.2); refresh_states()
end
local function showInfo(p)
    cur = p; update_downbtn(); for _, x in pairs(iscroll:GetChildren()) do if not x:IsA("UIListLayout") then x:Destroy() end end
    ititle.Text = getTitle(p); playAnim(info, true)
    local txt = md(p.description); if txt ~= "" then
        local t = Instance.new("TextLabel", iscroll); t.Text = txt; t.Size = UDim2.new(1, 0, 0, 0); t.AutomaticSize =
        Enum.AutomaticSize.Y; t.ZIndex = 16; t.RichText = true; t.TextWrapped = true; t.TextColor3 = Color3.fromRGB(160,
            160, 160); t.BackgroundTransparency = 1; t.Font = Enum.Font.Gotham; t.TextSize = 13; t.TextXAlignment = Enum
        .TextXAlignment.Left
    end
    if p.embeds then
        for _, em in pairs(p.embeds) do
            if em.title or (em.video and em.video.url) or (em.thumbnail and em.thumbnail.url) or (em.image and em.image.url) then
                local f = Instance.new("Frame", iscroll); f.Size = UDim2.new(1, 0, 0, 0); f.AutomaticSize = Enum
                .AutomaticSize.Y; f.BackgroundColor3 = Color3.fromRGB(42, 42, 42); f.BorderSizePixel = 0; f.ZIndex = 16; Instance.new("UICorner", f).CornerRadius =
                UDim.new(0, 4); Instance.new("UIListLayout", f).Padding = UDim.new(0, 6)
                if em.title then
                    local tt = Instance.new("TextLabel", f); tt.Text = em.title; tt.Size = UDim2.new(1, -12, 0, 22); tt.TextColor3 =
                    Color3.fromRGB(255, 255, 255); tt.BackgroundTransparency = 1; tt.Font = Enum.Font.GothamMedium; tt.TextSize = 12; tt.ZIndex = 17; tt.TextXAlignment =
                    Enum.TextXAlignment.Left
                end
                local d = md(em.description); if d ~= "" then
                    local dt = Instance.new("TextLabel", f); dt.Text = d; dt.Size = UDim2.new(1, -12, 0, 0); dt.AutomaticSize =
                    Enum.AutomaticSize.Y; dt.TextColor3 = Color3.fromRGB(160, 160, 160); dt.BackgroundTransparency = 1; dt.ZIndex = 17; dt.Font =
                    Enum.Font.Gotham; dt.TextSize = 12; dt.TextXAlignment = Enum.TextXAlignment.Left; dt.TextWrapped = true; dt.RichText = true
                end
                local iu = (em.image and em.image.url) or (em.thumbnail and em.thumbnail.url); if iu then
                    local ii = Instance.new("ImageLabel", f); ii.Size = UDim2.new(1, 0, 0, 160); ii.ZIndex = 17; ii.ClipsDescendants = true; ii.BackgroundColor3 =
                    Color3.fromRGB(30, 30, 30); ii.ScaleType = Enum.ScaleType.Fit; Instance.new("UICorner", ii).CornerRadius =
                    UDim.new(0, 4); applyImage(iu, ii)
                end
                Instance.new("UIPadding", f).PaddingTop = UDim.new(0, 6)
            end
        end
    end
end
local draw_ticket = 0
local function draw_list(ls)
    draw_ticket = draw_ticket + 1
    local current_ticket = draw_ticket
    for _, c in pairs(scrl:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    task.spawn(function()
        task.wait(0.05)
        for i, p in ipairs(ls) do
            if draw_ticket ~= current_ticket then return end
            if i % 4 == 0 then task.wait() end
            local gt = is_got(p); local c = Instance.new("TextButton", scrl); c.Text = ""; c.BackgroundColor3 = Color3
            .fromRGB(42, 42, 42); c.BorderSizePixel = 0; c.MouseButton1Click:Connect(function() showInfo(p) end)
            c:SetAttribute("p_id", p.id); Instance.new("UICorner", c).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", c).Color =
            Color3.fromRGB(7, 8, 7)
            local n = Instance.new("TextLabel", c); n.Text = getTitle(p); n.Size = UDim2.new(1, -52, 0, 18); n.Position =
            UDim2.new(0, 8, 0, 6); n.TextColor3 = Color3.fromRGB(234, 234, 234); n.Font = Enum.Font.GothamBold; n.TextSize = 13; n.TextXAlignment =
            Enum.TextXAlignment.Left; n.BackgroundTransparency = 1
            local a = Instance.new("TextLabel", c); a.Text = (p.author and p.author.name or "Unknown") ..
            " • " .. (p.date and p.date:sub(1, 10) or "N/A"); a.Size = UDim2.new(1, -52, 0, 16); a.Position = UDim2.new(0, 8,
                0, 26); a.TextColor3 = Color3.fromRGB(160, 160, 160); a.Font = Enum.Font.Gotham; a.TextSize = 11; a.TextXAlignment =
            Enum.TextXAlignment.Left; a.BackgroundTransparency = 1
            local gb = Instance.new("TextButton", c); gb.Name = "gb"; gb.Size = UDim2.new(0, 40, 0, 24); gb.Position = UDim2
            .new(1, -46, 0.5, -12); gb.BackgroundColor3 = gt and Color3.fromRGB(51, 51, 51) or Color3.fromRGB(255, 255, 255); gb.Text =
            gt and "GOT" or "GET"; gb.TextColor3 = gt and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(30, 30, 30); gb.Font =
            Enum.Font.GothamBold; gb.TextSize = 10; gb.BorderSizePixel = 0; Instance.new("UICorner", gb).CornerRadius = UDim
            .new(0, 4)
            local db = Instance.new("TextButton", c); db.Name = "db"; db.Size = UDim2.new(0, 24, 0, 24); db.Position = UDim2
            .new(1, -74, 0.5, -12); db.BackgroundColor3 = Color3.fromRGB(51, 51, 51); db.Text = "×"; db.TextColor3 = Color3
            .fromRGB(160, 160, 160); db.Font = Enum.Font.GothamBold; db.TextSize = 16; db.BorderSizePixel = 0; db.Visible =
            gt; Instance.new("UICorner", db).CornerRadius = UDim.new(0, 4)
            gb.MouseButton1Click:Connect(function() if gb.Text == "GET" then dl_plugin(p, gb) end end)
            db.MouseButton1Click:Connect(function() rem_plugin(p) end)
        end
    end)
end
task.spawn(function()
    TS:Create(bar_fill, TweenInfo.new(5, Enum.EasingStyle.Linear), { Size = UDim2.new(0.8, 0, 1, 0) }):Play()
    local success, raw = false, ""
    local api_done = false
    task.spawn(function()
        success, raw = pcall(function() return game:HttpGet(API .. "/data/plugins.json") end)
        api_done = true
    end)
    local start = tick()
    repeat task.wait(0.1) until (typeof(googIY) ~= "nil" or typeof(addPlugin) == "function" or (shared and shared.addPlugin) or (tick() - start > 15)) and api_done
    if success and raw ~= "" then
        local dat = HS:JSONDecode(raw); all = dat.plugins or {}; for _, p in ipairs(all) do p._ts = get_iso_time(p.date); plugin_map[p.id] = p end; table
            .sort(all, function(x, y) return x._ts > y._ts end)
        TS:Create(bar_fill, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { Size = UDim2.new(1, 0, 1, 0) }):Play(); task.wait(0.3)
        local fade = TweenInfo.new(0.2, Enum.EasingStyle.Sine)
        TS:Create(splash, fade, { BackgroundTransparency = 1 }):Play(); 
        if splash:FindFirstChild("UIStroke") then TS:Create(splash.UIStroke, fade, { Transparency = 1 }):Play() end
        if slog then TS:Create(slog, fade, { ImageTransparency = 1 }):Play() end
        TS:Create(stitle, fade, { TextTransparency = 1 }):Play(); TS:Create(ssub, fade, { TextTransparency = 1 }):Play()
        TS:Create(bar_bg, fade, { BackgroundTransparency = 1 }):Play(); TS:Create(bar_fill, fade, { BackgroundTransparency = 1 }):Play()
        task.wait(0.2); splash:Destroy(); playAnim(win, true); draw_list(all)
    else
        ssub.Text = "Synchronization failed."
    end
end)
close.MouseButton1Click:Connect(function() playAnim(win, false, function() gui:Destroy() end) end)
min.MouseButton1Click:Connect(function() playAnim(win, false, function() fbtn.Visible = true end) end)
downbtn.MouseButton1Click:Connect(function() if cur then dl_plugin(cur, downbtn) end end)
bckbtn.MouseButton1Click:Connect(function() playAnim(info, false) end)
box:GetPropertyChangedSignal("Text"):Connect(function()
    local q = box.Text:lower(); if q == "" then
        draw_list(all)
        return
    end; local r = {}; for _, p in pairs(all) do for _, f in pairs(p.files or {}) do if f.filename:lower():find(q, 1, true) then
                table.insert(r, p); break
            end end end; draw_list(r)
end)
