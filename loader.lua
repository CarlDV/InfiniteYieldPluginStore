local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local BASE = "https://iyplugins.pages.dev"
local API_URL = BASE .. "/data/api.json"
local function fmtBytes(b)
    if not b or b == 0 then return "0 B" end
    local units = {"B", "KB", "MB", "GB"}
    local i = math.floor(math.log(b) / math.log(1024))
    i = math.min(i, #units - 1)
    return string.format("%.1f %s", b / (1024 ^ i), units[i + 1])
end
local function fmtDate(iso)
    if not iso then return "" end
    local y, m, d = iso:match("(%d+)-(%d+)-(%d+)")
    if not y then return "" end
    local months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return string.format("%s %d, %s", months[tonumber(m)] or "???", tonumber(d), y)
end
local function truncate(str, maxLen)
    if not str then return "" end
    if #str <= maxLen then return str end
    return str:sub(1, maxLen - 3) .. "..."
end
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IYPluginStore"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not screenGui.Parent then
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.Parent = screenGui
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = isMobile and UDim2.new(0.95, 0, 0.85, 0) or UDim2.new(0, 520, 0, 480)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = overlay
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 55, 75)
mainStroke.Thickness = 1
mainStroke.Transparency = 1
mainStroke.Parent = mainFrame
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header
local headerFill = Instance.new("Frame")
headerFill.Size = UDim2.new(1, 0, 0, 14)
headerFill.Position = UDim2.new(0, 0, 1, -14)
headerFill.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
headerFill.BorderSizePixel = 0
headerFill.Parent = header
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = "⚡ IY Plugin Store"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = isMobile and 16 or 18
titleLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header
local counterLabel = Instance.new("TextLabel")
counterLabel.Name = "Counter"
counterLabel.Text = "0 downloaded"
counterLabel.Font = Enum.Font.GothamMedium
counterLabel.TextSize = isMobile and 11 or 12
counterLabel.TextColor3 = Color3.fromRGB(130, 200, 130)
counterLabel.BackgroundTransparency = 1
counterLabel.Size = UDim2.new(0.35, 0, 0, 20)
counterLabel.Position = UDim2.new(0.62, 0, 0.5, -10)
counterLabel.TextXAlignment = Enum.TextXAlignment.Right
counterLabel.Parent = header
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -44, 0, 8)
closeBtn.Parent = header
local sep = Instance.new("Frame")
sep.Name = "Sep"
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 0, 56)
sep.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
sep.BorderSizePixel = 0
sep.Parent = mainFrame
local searchFrame = Instance.new("Frame")
searchFrame.Name = "SearchFrame"
searchFrame.Size = UDim2.new(1, -24, 0, 36)
searchFrame.Position = UDim2.new(0, 12, 0, 65)
searchFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame
local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchFrame
local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Color3.fromRGB(50, 50, 65)
searchStroke.Thickness = 1
searchStroke.Parent = searchFrame
local searchIcon = Instance.new("TextLabel")
searchIcon.Text = "🔍"
searchIcon.Font = Enum.Font.Gotham
searchIcon.TextSize = 14
searchIcon.BackgroundTransparency = 1
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.Position = UDim2.new(0, 6, 0, 0)
searchIcon.TextColor3 = Color3.fromRGB(120, 120, 140)
searchIcon.Parent = searchFrame
local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.PlaceholderText = "Search plugins..."
searchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = isMobile and 13 or 14
searchBox.TextColor3 = Color3.fromRGB(210, 210, 220)
searchBox.BackgroundTransparency = 1
searchBox.Size = UDim2.new(1, -42, 1, 0)
searchBox.Position = UDim2.new(0, 38, 0, 0)
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame
local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.Size = UDim2.new(1, -24, 0, 22)
statsBar.Position = UDim2.new(0, 12, 0, 107)
statsBar.BackgroundTransparency = 1
statsBar.Parent = mainFrame
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Text = "Loading plugins..."
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = isMobile and 11 or 12
statsLabel.TextColor3 = Color3.fromRGB(110, 110, 130)
statsLabel.BackgroundTransparency = 1
statsLabel.Size = UDim2.new(0.6, 0, 1, 0)
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = statsBar
local dlAllBtn = Instance.new("TextButton")
dlAllBtn.Name = "DownloadAll"
dlAllBtn.Text = "📥 Download All"
dlAllBtn.Font = Enum.Font.GothamBold
dlAllBtn.TextSize = isMobile and 11 or 12
dlAllBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
dlAllBtn.BackgroundTransparency = 1
dlAllBtn.Size = UDim2.new(0.4, 0, 1, 0)
dlAllBtn.Position = UDim2.new(0.6, 0, 0, 0)
dlAllBtn.TextXAlignment = Enum.TextXAlignment.Right
dlAllBtn.Visible = false
dlAllBtn.Parent = statsBar
local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "PluginList"
listFrame.Size = UDim2.new(1, -24, 1, -140)
listFrame.Position = UDim2.new(0, 12, 0, 133)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = mainFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame
local listPadding = Instance.new("UIPadding")
listPadding.PaddingBottom = UDim.new(0, 12)
listPadding.Parent = listFrame
local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "Loading"
loadingFrame.Size = UDim2.new(1, 0, 0, 80)
loadingFrame.BackgroundTransparency = 1
loadingFrame.Parent = listFrame
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Text = "⏳ Fetching plugin store..."
loadingLabel.Font = Enum.Font.GothamMedium
loadingLabel.TextSize = 14
loadingLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Size = UDim2.new(1, 0, 1, 0)
loadingLabel.Parent = loadingFrame
local progressFrame = Instance.new("Frame")
progressFrame.Name = "ProgressFrame"
progressFrame.Size = UDim2.new(1, -24, 0, 32)
progressFrame.Position = UDim2.new(0, 12, 1, -44)
progressFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
progressFrame.BorderSizePixel = 0
progressFrame.Visible = false
progressFrame.Parent = mainFrame
local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 8)
progressCorner.Parent = progressFrame
local progressBg = Instance.new("Frame")
progressBg.Name = "BarBg"
progressBg.Size = UDim2.new(1, -12, 0, 6)
progressBg.Position = UDim2.new(0, 6, 1, -14)
progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
progressBg.BorderSizePixel = 0
progressBg.Parent = progressFrame
local progressBgCorner = Instance.new("UICorner")
progressBgCorner.CornerRadius = UDim.new(0, 3)
progressBgCorner.Parent = progressBg
local progressBar = Instance.new("Frame")
progressBar.Name = "Bar"
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBg
local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(0, 3)
progressBarCorner.Parent = progressBar
local progressLabel = Instance.new("TextLabel")
progressLabel.Name = "Label"
progressLabel.Text = "Downloading..."
progressLabel.Font = Enum.Font.GothamMedium
progressLabel.TextSize = 11
progressLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
progressLabel.BackgroundTransparency = 1
progressLabel.Size = UDim2.new(1, -12, 0, 18)
progressLabel.Position = UDim2.new(0, 6, 0, 2)
progressLabel.TextXAlignment = Enum.TextXAlignment.Left
progressLabel.Parent = progressFrame
local function createPluginCard(plugin, index)
    local card = Instance.new("Frame")
    card.Name = "Card_" .. (plugin.name or index)
    card.Size = UDim2.new(1, 0, 0, isMobile and 72 or 68)
    card.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    card.BorderSizePixel = 0
    card.LayoutOrder = index
    card.Parent = listFrame
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(40, 40, 55)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.3
    cardStroke.Parent = card
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Text = truncate(plugin.name or "Untitled", 30)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = isMobile and 13 or 14
    nameLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0.65, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 14, 0, 10)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Name = "Author"
    authorLabel.Text = "by " .. (plugin.author or "Unknown")
    authorLabel.Font = Enum.Font.Gotham
    authorLabel.TextSize = isMobile and 10 or 11
    authorLabel.TextColor3 = Color3.fromRGB(120, 120, 150)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Size = UDim2.new(0.6, 0, 0, 16)
    authorLabel.Position = UDim2.new(0, 14, 0, 30)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.TextTruncate = Enum.TextTruncate.AtEnd
    authorLabel.Parent = card
    local fileCount = plugin.files and #plugin.files or 0
    local totalSize = 0
    if plugin.files then
        for _, f in ipairs(plugin.files) do
            totalSize = totalSize + (f.size or 0)
        end
    end
    local infoText = fileCount .. " file" .. (fileCount ~= 1 and "s" or "") .. " • " .. fmtBytes(totalSize)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Text = infoText
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = isMobile and 9 or 10
    infoLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Size = UDim2.new(0.5, 0, 0, 14)
    infoLabel.Position = UDim2.new(0, 14, 0, 47)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = card
    local dateLabel = Instance.new("TextLabel")
    dateLabel.Name = "Date"
    dateLabel.Text = fmtDate(plugin.date)
    dateLabel.Font = Enum.Font.Gotham
    dateLabel.TextSize = isMobile and 9 or 10
    dateLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
    dateLabel.BackgroundTransparency = 1
    dateLabel.Size = UDim2.new(0.3, -14, 0, 14)
    dateLabel.Position = UDim2.new(0.7, 0, 0, 10)
    dateLabel.TextXAlignment = Enum.TextXAlignment.Right
    dateLabel.Parent = card
    local dlBtn = Instance.new("TextButton")
    dlBtn.Name = "Download"
    dlBtn.Text = "📥"
    dlBtn.Font = Enum.Font.GothamBold
    dlBtn.TextSize = isMobile and 16 or 18
    dlBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
    dlBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    dlBtn.BackgroundTransparency = 0.3
    dlBtn.Size = UDim2.new(0, isMobile and 38 or 36, 0, isMobile and 38 or 36)
    dlBtn.Position = UDim2.new(1, isMobile and -50 or -48, 0.5, isMobile and -19 or -18)
    dlBtn.Parent = card
    local dlBtnCorner = Instance.new("UICorner")
    dlBtnCorner.CornerRadius = UDim.new(0, 8)
    dlBtnCorner.Parent = dlBtn
    dlBtn.MouseEnter:Connect(function()
        TweenService:Create(dlBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    dlBtn.MouseLeave:Connect(function()
        TweenService:Create(dlBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
    end)
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 44)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 36)}):Play()
    end)
    return card, dlBtn
end
local function fadeIn()
    TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
    TweenService:Create(mainStroke, TweenInfo.new(0.35), {Transparency = 0}):Play()
end
local function fadeOut(callback)
    TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(mainFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(mainStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
    task.delay(0.3, function()
        screenGui:Destroy()
        if callback then callback() end
    end)
end
local allPlugins = {}
local filteredPlugins = {}
local downloadedCount = 0
local cards = {} 
local function updateCounter()
    counterLabel.Text = downloadedCount .. " downloaded"
end
local function downloadPlugin(plugin, dlBtn)
    if not writefile then
        dlBtn.Text = "❌"
        return
    end
    dlBtn.Text = "⏳"
    dlBtn.TextColor3 = Color3.fromRGB(200, 180, 80)
    local success = true
    for _, file in ipairs(plugin.files or {}) do
        local ok, content = pcall(function()
            return game:HttpGet(BASE .. "/" .. file.url)
        end)
        if ok then
            pcall(function()
                writefile(file.filename, content)
            end)
        else
            success = false
            warn("[IY Store] Failed: " .. file.filename)
        end
    end
    if success then
        downloadedCount = downloadedCount + 1
        updateCounter()
        dlBtn.Text = "✅"
        dlBtn.TextColor3 = Color3.fromRGB(100, 200, 120)
    else
        dlBtn.Text = "⚠️"
        dlBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
    end
end
local function renderList(pluginList)
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("^Card_") then
            child:Destroy()
        end
    end
    cards = {}
    if #pluginList == 0 then
        local empty = Instance.new("Frame")
        empty.Name = "Card_Empty"
        empty.Size = UDim2.new(1, 0, 0, 60)
        empty.BackgroundTransparency = 1
        empty.LayoutOrder = 1
        empty.Parent = listFrame
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Text = "No plugins found."
        emptyLabel.Font = Enum.Font.GothamMedium
        emptyLabel.TextSize = 14
        emptyLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Size = UDim2.new(1, 0, 1, 0)
        emptyLabel.Parent = empty
        return
    end
    for i, plugin in ipairs(pluginList) do
        local card, dlBtn = createPluginCard(plugin, i)
        cards[plugin.id] = {card = card, dlBtn = dlBtn}
        dlBtn.MouseButton1Click:Connect(function()
            if dlBtn.Text == "✅" or dlBtn.Text == "⏳" then return end
            task.spawn(function()
                downloadPlugin(plugin, dlBtn)
            end)
        end)
    end
end
local function filterPlugins(query)
    if not query or query == "" then
        filteredPlugins = allPlugins
    else
        local q = query:lower()
        filteredPlugins = {}
        for _, p in ipairs(allPlugins) do
            local name = (p.name or ""):lower()
            local author = (p.author or ""):lower()
            if name:find(q, 1, true) or author:find(q, 1, true) then
                table.insert(filteredPlugins, p)
            end
        end
    end
    renderList(filteredPlugins)
end
local function downloadAll()
    if not writefile then
        progressLabel.Text = "writefile not supported!"
        return
    end
    local plugins = filteredPlugins
    local total = #plugins
    if total == 0 then return end
    dlAllBtn.Visible = false
    progressFrame.Visible = true
    listFrame.Size = UDim2.new(1, -24, 1, -180)
    for i, plugin in ipairs(plugins) do
        progressLabel.Text = string.format("Downloading %d/%d: %s", i, total, plugin.name or "?")
        local ratio = i / total
        TweenService:Create(progressBar, TweenInfo.new(0.2), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
        for _, file in ipairs(plugin.files or {}) do
            local ok, content = pcall(function()
                return game:HttpGet(BASE .. "/" .. file.url)
            end)
            if ok then
                pcall(function()
                    writefile(file.filename, content)
                end)
            else
                warn("[IY Store] Failed: " .. file.filename)
            end
        end
        downloadedCount = downloadedCount + 1
        updateCounter()
        if cards[plugin.id] then
            local btn = cards[plugin.id].dlBtn
            btn.Text = "✅"
            btn.TextColor3 = Color3.fromRGB(100, 200, 120)
        end
        task.wait()
    end
    progressLabel.Text = string.format("✅ Done! %d plugins downloaded", total)
    TweenService:Create(progressBar, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 200, 120)}):Play()
    task.delay(2, function()
        progressFrame.Visible = false
        listFrame.Size = UDim2.new(1, -24, 1, -140)
        dlAllBtn.Visible = true
    end)
end
local function autoLoadPlugins()
    if not listfiles or not isfolder then
        warn("[IY Store] Cannot auto-load: exploit missing listfiles/isfolder")
        return
    end
    for _, filePath in ipairs(listfiles("")) do
        local fileName = filePath:match("([^/\\]+%.iy)$")
        if fileName and
            fileName:lower() ~= "iy_fe.iy" and
            not isfolder(fileName) and
            (not PluginsTable or not table.find(PluginsTable, fileName))
        then
            pcall(function()
                if addPlugin then
                    addPlugin(fileName)
                end
            end)
        end
    end
end
fadeIn()
task.spawn(function()
    local ok, response = pcall(function()
        return game:HttpGet(API_URL)
    end)
    if not ok then
        loadingLabel.Text = "❌ Failed to fetch plugin store."
        return
    end
    local data = HttpService:JSONDecode(response)
    allPlugins = data.plugins or {}
    loadingFrame:Destroy()
    local authors = {}
    for _, p in ipairs(allPlugins) do
        if p.author then
            authors[p.author] = true
        end
    end
    local authorCount = 0
    for _ in pairs(authors) do authorCount = authorCount + 1 end
    statsLabel.Text = string.format("%d plugins • %d authors", #allPlugins, authorCount)
    dlAllBtn.Visible = true
    filteredPlugins = allPlugins
    renderList(allPlugins)
end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterPlugins(searchBox.Text)
end)
dlAllBtn.MouseButton1Click:Connect(function()
    task.spawn(downloadAll)
end)
closeBtn.MouseButton1Click:Connect(function()
    fadeOut(function()
        task.spawn(autoLoadPlugins)
        task.spawn(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
    end)
end)