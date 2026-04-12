local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local BASE = "https://iyplugins.pages.dev"
local API_URL = BASE .. "/data/plugins.json"
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
end)
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
local function parseDate(iso)
    if not iso then return 0 end
    local y, m, d, h, mi, s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if not y then return 0 end
    return tonumber(y) * 31536000 + tonumber(m) * 2592000 + tonumber(d) * 86400 + tonumber(h) * 3600 + tonumber(mi) * 60 + tonumber(s)
end
local function cleanDesc(s)
    if not s or s == "" then return "" end
    s = s:gsub("<@!?%d+>", "@user")
    s = s:gsub("<#%d+>", "#channel")
    s = s:gsub("<:.+:%d+>", "")
    s = s:gsub("```%w*\n?", ""):gsub("```", "")
    s = s:gsub("%*%*(.-)%*%*", "%1")
    s = s:gsub("__(.-)__", "%1")
    s = s:gsub("~~(.-)~~", "%1")
    return s
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IYPluginStore"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
if not screenGui.Parent then
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = isMobile and UDim2.new(0.96, 0, 0.88, 0) or UDim2.new(0, 580, 0, 500)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(42, 42, 42)
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 34)
topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = mainFrame
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar
local topBarFiller = Instance.new("Frame")
topBarFiller.Name = "Filler"
topBarFiller.Size = UDim2.new(1, 0, 0, 18)
topBarFiller.Position = UDim2.new(0, 0, 1, -18)
topBarFiller.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
topBarFiller.BorderSizePixel = 0
topBarFiller.ZIndex = 1
topBarFiller.Parent = topBar
local topSep = Instance.new("Frame")
topSep.Size = UDim2.new(1, 0, 0, 1)
topSep.Position = UDim2.new(0, 0, 1, -1)
topSep.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
topSep.BorderSizePixel = 0
topSep.ZIndex = 3
topSep.Parent = topBar
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Plugins"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = isMobile and 13 or 14
titleLabel.TextColor3 = Color3.fromRGB(229, 229, 229)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(0, 60, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar
local statLabel = Instance.new("TextLabel")
statLabel.Name = "Stats"
statLabel.Text = ""
statLabel.Font = Enum.Font.Gotham
statLabel.TextSize = 10
statLabel.TextColor3 = Color3.fromRGB(102, 102, 102)
statLabel.BackgroundTransparency = 1
statLabel.Size = UDim2.new(0, 150, 1, 0)
statLabel.Position = UDim2.new(0, 80, 0, 0)
statLabel.TextXAlignment = Enum.TextXAlignment.Left
statLabel.Parent = topBar
local dlAllBtn = Instance.new("TextButton")
dlAllBtn.Name = "DlAll"
dlAllBtn.Text = "Get All"
dlAllBtn.Font = Enum.Font.GothamMedium
dlAllBtn.TextSize = 10
dlAllBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
dlAllBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dlAllBtn.Size = UDim2.new(0, 56, 0, 22)
dlAllBtn.Position = UDim2.new(1, -130, 0.5, -11)
dlAllBtn.Visible = false
dlAllBtn.Parent = topBar
Instance.new("UICorner", dlAllBtn).CornerRadius = UDim.new(0, 6)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "Minimize"
minimizeBtn.Text = "—"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 15
minimizeBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(1, -64, 0, 4)
minimizeBtn.Parent = topBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
closeBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -30, 0, 4)
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
local dragging = false
local dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -32, 0, 32)
searchFrame.Position = UDim2.new(0, 16, 0, 48)
searchFrame.BackgroundColor3 = Color3.fromRGB(2, 0, 0)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = mainFrame
Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 8)
local searchS = Instance.new("UIStroke")
searchS.Color = Color3.fromRGB(42, 42, 42)
searchS.Thickness = 1
searchS.Parent = searchFrame
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Search plugins..."
searchBox.PlaceholderColor3 = Color3.fromRGB(102, 102, 102)
searchBox.Text = ""
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = isMobile and 12 or 13
searchBox.TextColor3 = Color3.fromRGB(229, 229, 229)
searchBox.BackgroundTransparency = 1
searchBox.Size = UDim2.new(1, -16, 1, 0)
searchBox.Position = UDim2.new(0, 14, 0, 0)
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame
local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "PluginList"
listFrame.Size = UDim2.new(1, -32, 1, -100)
listFrame.Position = UDim2.new(0, 16, 0, 88)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(51, 51, 51)
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = mainFrame
local listLayout = Instance.new("UIGridLayout")
listLayout.CellPadding = UDim2.new(0, 8, 0, 8)
listLayout.CellSize = UDim2.new(0.5, -4, 0, 68)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listFrame
Instance.new("UIPadding", listFrame).PaddingBottom = UDim.new(0, 16)
local loadingLabel = Instance.new("TextLabel")
loadingLabel.Name = "Loading"
loadingLabel.Text = "Loading plugins..."
loadingLabel.Font = Enum.Font.Gotham
loadingLabel.TextSize = 13
loadingLabel.TextColor3 = Color3.fromRGB(102, 102, 102)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Size = UDim2.new(1, 0, 0, 60)
loadingLabel.Parent = listFrame
local progressFrame = Instance.new("Frame")
progressFrame.Size = UDim2.new(1, -32, 0, 36)
progressFrame.Position = UDim2.new(0, 16, 1, -48)
progressFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
progressFrame.BorderSizePixel = 0
progressFrame.Visible = false
progressFrame.Parent = mainFrame
Instance.new("UICorner", progressFrame).CornerRadius = UDim.new(0, 8)
local progS = Instance.new("UIStroke")
progS.Color = Color3.fromRGB(42, 42, 42)
progS.Thickness = 1
progS.Parent = progressFrame
local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(1, -16, 0, 4)
progressBg.Position = UDim2.new(0, 8, 1, -10)
progressBg.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
progressBg.BorderSizePixel = 0
progressBg.Parent = progressFrame
Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 2)
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(229, 229, 229)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBg
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 2)
local progressLabel = Instance.new("TextLabel")
progressLabel.Text = ""
progressLabel.Font = Enum.Font.GothamMedium
progressLabel.TextSize = 11
progressLabel.TextColor3 = Color3.fromRGB(153, 153, 153)
progressLabel.BackgroundTransparency = 1
progressLabel.Size = UDim2.new(1, -16, 0, 22)
progressLabel.Position = UDim2.new(0, 8, 0, 2)
progressLabel.TextXAlignment = Enum.TextXAlignment.Left
progressLabel.Parent = progressFrame
local detailOverlay = Instance.new("Frame")
detailOverlay.Name = "DetailOverlay"
detailOverlay.Size = UDim2.new(1, 0, 1, 0)
detailOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
detailOverlay.BackgroundTransparency = 0.15
detailOverlay.BorderSizePixel = 0
detailOverlay.Visible = false
detailOverlay.ZIndex = 10
detailOverlay.Parent = mainFrame
local detailPanel = Instance.new("Frame")
detailPanel.Name = "DetailPanel"
detailPanel.AnchorPoint = Vector2.new(0.5, 0.5)
detailPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
detailPanel.Size = UDim2.new(1, -24, 1, -24)
detailPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
detailPanel.BorderSizePixel = 0
detailPanel.ClipsDescendants = true
detailPanel.ZIndex = 11
detailPanel.Parent = detailOverlay
Instance.new("UICorner", detailPanel).CornerRadius = UDim.new(0, 12)
local detailS = Instance.new("UIStroke")
detailS.Color = Color3.fromRGB(42, 42, 42)
detailS.Thickness = 1
detailS.Parent = detailPanel
local detailTopBar = Instance.new("Frame")
detailTopBar.Size = UDim2.new(1, 0, 0, 80)
detailTopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
detailTopBar.BorderSizePixel = 0
detailTopBar.ZIndex = 12
detailTopBar.Parent = detailPanel
local detailTopSep = Instance.new("Frame")
detailTopSep.Size = UDim2.new(1, 0, 0, 1)
detailTopSep.Position = UDim2.new(0, 0, 1, -1)
detailTopSep.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
detailTopSep.BorderSizePixel = 0
detailTopSep.ZIndex = 12
detailTopSep.Parent = detailTopBar
local detailAvatar = Instance.new("Frame")
detailAvatar.Size = UDim2.new(0, 44, 0, 44)
detailAvatar.Position = UDim2.new(0, 20, 0, 18)
detailAvatar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
detailAvatar.BorderSizePixel = 0
detailAvatar.ZIndex = 13
detailAvatar.Parent = detailTopBar
Instance.new("UICorner", detailAvatar).CornerRadius = UDim.new(1, 0)
local detailAvatarLbl = Instance.new("TextLabel")
detailAvatarLbl.Text = ""
detailAvatarLbl.Font = Enum.Font.GothamBold
detailAvatarLbl.TextSize = 16
detailAvatarLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
detailAvatarLbl.BackgroundTransparency = 1
detailAvatarLbl.Size = UDim2.new(1, 0, 1, 0)
detailAvatarLbl.ZIndex = 14
detailAvatarLbl.Parent = detailAvatar
local detailTitle = Instance.new("TextLabel")
detailTitle.Text = ""
detailTitle.Font = Enum.Font.GothamBold
detailTitle.TextSize = isMobile and 15 or 17
detailTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
detailTitle.BackgroundTransparency = 1
detailTitle.Size = UDim2.new(0.65, -80, 0, 22)
detailTitle.Position = UDim2.new(0, 76, 0, 16)
detailTitle.TextXAlignment = Enum.TextXAlignment.Left
detailTitle.TextTruncate = Enum.TextTruncate.AtEnd
detailTitle.ZIndex = 13
detailTitle.Parent = detailTopBar
local detailMeta = Instance.new("TextLabel")
detailMeta.Text = ""
detailMeta.Font = Enum.Font.Gotham
detailMeta.TextSize = isMobile and 10 or 11
detailMeta.TextColor3 = Color3.fromRGB(102, 102, 102)
detailMeta.BackgroundTransparency = 1
detailMeta.Size = UDim2.new(0.7, -80, 0, 16)
detailMeta.Position = UDim2.new(0, 76, 0, 40)
detailMeta.TextXAlignment = Enum.TextXAlignment.Left
detailMeta.ZIndex = 13
detailMeta.Parent = detailTopBar
local detailDateLbl = Instance.new("TextLabel")
detailDateLbl.Text = ""
detailDateLbl.Font = Enum.Font.Gotham
detailDateLbl.TextSize = 10
detailDateLbl.TextColor3 = Color3.fromRGB(102, 102, 102)
detailDateLbl.BackgroundTransparency = 1
detailDateLbl.Size = UDim2.new(0.7, -80, 0, 14)
detailDateLbl.Position = UDim2.new(0, 76, 0, 58)
detailDateLbl.TextXAlignment = Enum.TextXAlignment.Left
detailDateLbl.ZIndex = 13
detailDateLbl.Parent = detailTopBar
local detailCloseBtn = Instance.new("TextButton")
detailCloseBtn.Text = "×"
detailCloseBtn.Font = Enum.Font.GothamBold
detailCloseBtn.TextSize = 22
detailCloseBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
detailCloseBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
detailCloseBtn.BackgroundTransparency = 1
detailCloseBtn.Size = UDim2.new(0, 36, 0, 36)
detailCloseBtn.Position = UDim2.new(1, -48, 0, 22)
detailCloseBtn.ZIndex = 13
detailCloseBtn.Parent = detailTopBar
Instance.new("UICorner", detailCloseBtn).CornerRadius = UDim.new(0, 6)
local detailDlBtn = Instance.new("TextButton")
detailDlBtn.Text = "Get"
detailDlBtn.Font = Enum.Font.GothamMedium
detailDlBtn.TextSize = 12
detailDlBtn.TextColor3 = Color3.fromRGB(229, 229, 229)
detailDlBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
detailDlBtn.Size = UDim2.new(0, 56, 0, 28)
detailDlBtn.Position = UDim2.new(1, -110, 0, 26)
detailDlBtn.ZIndex = 13
detailDlBtn.Parent = detailTopBar
Instance.new("UICorner", detailDlBtn).CornerRadius = UDim.new(0, 6)
local detailScroll = Instance.new("ScrollingFrame")
detailScroll.Size = UDim2.new(1, 0, 1, -80)
detailScroll.Position = UDim2.new(0, 0, 0, 80)
detailScroll.BackgroundTransparency = 1
detailScroll.BorderSizePixel = 0
detailScroll.ScrollBarThickness = 4
detailScroll.ScrollBarImageColor3 = Color3.fromRGB(51, 51, 51)
detailScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
detailScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
detailScroll.ZIndex = 12
detailScroll.Parent = detailPanel
local detailLayout = Instance.new("UIListLayout")
detailLayout.Padding = UDim.new(0, 0)
detailLayout.SortOrder = Enum.SortOrder.LayoutOrder
detailLayout.Parent = detailScroll
local detailPad = Instance.new("UIPadding")
detailPad.PaddingTop = UDim.new(0, 16)
detailPad.PaddingBottom = UDim.new(0, 16)
detailPad.PaddingLeft = UDim.new(0, 20)
detailPad.PaddingRight = UDim.new(0, 20)
detailPad.Parent = detailScroll
local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MiniRestore"
miniBtn.Text = "IY Plugins"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 12
miniBtn.TextColor3 = Color3.fromRGB(229, 229, 229)
miniBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniBtn.Size = UDim2.new(0, 100, 0, 30)
miniBtn.Position = UDim2.new(1, -116, 0.05, 0)
miniBtn.Visible = true
miniBtn.Parent = screenGui
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)
local miniS = Instance.new("UIStroke")
miniS.Color = Color3.fromRGB(42, 42, 42)
miniS.Thickness = 1
miniS.Parent = miniBtn
local miniDragging = false
local miniDragStart, miniStartPos
miniBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniDragStart = input.Position
        miniStartPos = miniBtn.Position
    end
end)
miniBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - miniDragStart
        miniBtn.Position = UDim2.new(miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X, miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y)
    end
end)
local allPlugins = {}
local filteredPlugins = {}
local downloadedCount = 0
local downloadedPlugins = {}
local cards = {}
local currentDetailPlugin = nil
local CONFIG_FILE = "iy_store_plugins.json"
local function loadConfig()
    if readfile and isfile and isfile(CONFIG_FILE) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if type(data) == "table" then
                downloadedPlugins = data
                for _ in pairs(downloadedPlugins) do downloadedCount = downloadedCount + 1 end
            end
        end)
    end
end
local function saveConfig()
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(downloadedPlugins))
        end)
    end
end
local function updateCounter()
end
local function clearDetailBody()
    for _, child in ipairs(detailScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end
local function addSection(labelText, order)
    local lbl = Instance.new("TextLabel")
    lbl.Text = string.upper(labelText)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = Color3.fromRGB(102, 102, 102)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.ZIndex = 12
    lbl.Parent = detailScroll
    return lbl
end
local function addTextBlock(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(153, 153, 153)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.LayoutOrder = order
    lbl.ZIndex = 12
    lbl.Parent = detailScroll
    return lbl
end
local function addEmbedRow(embed, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.ZIndex = 12
    row.Parent = detailScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(42, 42, 42)
    rs.Thickness = 1
    rs.Parent = row
    local pad = Instance.new("UIPadding", row)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    local list = Instance.new("UIListLayout", row)
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    if embed.title then
        local t = Instance.new("TextLabel")
        t.Text = embed.title
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextColor3 = Color3.fromRGB(59, 130, 246)
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, 0, 0, 0)
        t.AutomaticSize = Enum.AutomaticSize.Y
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextWrapped = true
        t.LayoutOrder = 1
        t.Parent = row
    end
    if embed.description then
        local d = Instance.new("TextLabel")
        d.Text = cleanDesc(embed.description)
        d.Font = Enum.Font.Gotham
        d.TextSize = 11
        d.TextColor3 = Color3.fromRGB(209, 213, 219)
        d.BackgroundTransparency = 1
        d.Size = UDim2.new(1, 0, 0, 0)
        d.AutomaticSize = Enum.AutomaticSize.Y
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextWrapped = true
        d.LayoutOrder = 2
        d.Parent = row
    end
    if embed.video and embed.video.url then
        local v = Instance.new("TextLabel")
        v.Text = "Video: " .. embed.video.url
        v.Font = Enum.Font.GothamMedium
        v.TextSize = 10
        v.TextColor3 = Color3.fromRGB(156, 163, 175)
        v.BackgroundTransparency = 1
        v.Size = UDim2.new(1, 0, 0, 0)
        v.AutomaticSize = Enum.AutomaticSize.Y
        v.TextXAlignment = Enum.TextXAlignment.Left
        v.TextWrapped = true
        v.LayoutOrder = 3
        v.Parent = row
    elseif embed.image and embed.image.url then
        local i = Instance.new("TextLabel")
        i.Text = "Image: " .. embed.image.url
        i.Font = Enum.Font.GothamMedium
        i.TextSize = 10
        i.TextColor3 = Color3.fromRGB(156, 163, 175)
        i.BackgroundTransparency = 1
        i.Size = UDim2.new(1, 0, 0, 0)
        i.AutomaticSize = Enum.AutomaticSize.Y
        i.TextXAlignment = Enum.TextXAlignment.Left
        i.TextWrapped = true
        i.LayoutOrder = 3
        i.Parent = row
    end
    return row
end
local function addSpacer(h, order)
    local sp = Instance.new("Frame")
    sp.Size = UDim2.new(1, 0, 0, h)
    sp.BackgroundTransparency = 1
    sp.LayoutOrder = order
    sp.ZIndex = 12
    sp.Parent = detailScroll
end
local function showDetail(plugin)
    currentDetailPlugin = plugin
    clearDetailBody()

    local authorName = plugin.author and plugin.author.name or "Unknown"
    local initial = string.upper(string.sub(authorName, 1, 1))
    detailAvatarLbl.Text = initial
    detailTitle.Text = plugin.name or "Untitled"

    local pluginFiles = {}
    for _, f in ipairs(plugin.files or {}) do
        if f.filename:lower():match("%.iy$") then
            table.insert(pluginFiles, f)
        end
    end
    detailMeta.Text = authorName .. "  ·  " .. #pluginFiles .. " plugin file" .. (#pluginFiles ~= 1 and "s" or "")
    detailDateLbl.Text = fmtDate(plugin.date)

    if downloadedPlugins[plugin.id] then
        detailDlBtn.Text = "Done"
        detailDlBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
    else
        detailDlBtn.Text = "Get"
        detailDlBtn.TextColor3 = Color3.fromRGB(229, 229, 229)
    end
    local order = 1
    local desc = cleanDesc(plugin.description or "")
    if desc ~= "" then
        addSection("Description", order)
        order = order + 1
        addTextBlock(desc, order)
        order = order + 1
        addSpacer(12, order)
        order = order + 1
    end

    if #pluginFiles > 0 then
        addSection("Files", order)
        order = order + 1
        for _, file in ipairs(pluginFiles) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            row.BorderSizePixel = 0
            row.LayoutOrder = order
            row.ZIndex = 12
            row.Parent = detailScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
            local rs = Instance.new("UIStroke")
            rs.Color = Color3.fromRGB(42, 42, 42)
            rs.Thickness = 1
            rs.Parent = row
            local fname = Instance.new("TextLabel")
            fname.Text = file.filename or "?"
            fname.Font = Enum.Font.GothamMedium
            fname.TextSize = 11
            fname.TextColor3 = Color3.fromRGB(229, 229, 229)
            fname.BackgroundTransparency = 1
            fname.Size = UDim2.new(0.6, 0, 1, 0)
            fname.Position = UDim2.new(0, 12, 0, 0)
            fname.TextXAlignment = Enum.TextXAlignment.Left
            fname.TextTruncate = Enum.TextTruncate.AtEnd
            fname.ZIndex = 13
            fname.Parent = row
            local fsize = Instance.new("TextLabel")
            fsize.Text = fmtBytes(file.size or 0)
            fsize.Font = Enum.Font.Gotham
            fsize.TextSize = 10
            fsize.TextColor3 = Color3.fromRGB(102, 102, 102)
            fsize.BackgroundTransparency = 1
            fsize.Size = UDim2.new(0.3, -12, 1, 0)
            fsize.Position = UDim2.new(0.6, 0, 0, 0)
            fsize.TextXAlignment = Enum.TextXAlignment.Right
            fsize.ZIndex = 13
            fsize.Parent = row
            order = order + 1
            addSpacer(4, order)
            order = order + 1
        end
        addSpacer(8, order)
        order = order + 1
    end

    if plugin.embeds and #plugin.embeds > 0 then
        addSection("Embeds", order)
        order = order + 1
        for _, emb in ipairs(plugin.embeds) do
            addEmbedRow(emb, order)
            order = order + 1
            addSpacer(8, order)
            order = order + 1
        end
    end

    if plugin.loadstring_urls and #plugin.loadstring_urls > 0 then
        addSection("Loadstring URLs", order)
        order = order + 1
        for _, url in ipairs(plugin.loadstring_urls) do
            local u = addTextBlock(url, order)
            u.TextColor3 = Color3.fromRGB(251, 191, 36)
            u.TextSize = 11
            order = order + 1
            addSpacer(4, order)
            order = order + 1
        end
    end

    detailOverlay.Visible = true
end
local function hideDetail()
    detailOverlay.Visible = false
    currentDetailPlugin = nil
end
detailCloseBtn.MouseButton1Click:Connect(hideDetail)
detailCloseBtn.MouseEnter:Connect(function()
    TweenService:Create(detailCloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
end)
detailCloseBtn.MouseLeave:Connect(function()
    TweenService:Create(detailCloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
end)
detailDlBtn.MouseButton1Click:Connect(function()
    if not currentDetailPlugin or not writefile then
        detailDlBtn.Text = "N/A"
        detailDlBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
        return
    end
    if detailDlBtn.Text == "Done" or detailDlBtn.Text == "..." then return end
    detailDlBtn.Text = "..."
    detailDlBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
    task.spawn(function()
        local plugin = currentDetailPlugin
        local success = true
        local filesToDownload = {}
        for _, file in ipairs(plugin.files or {}) do
            if file.filename:lower():match("%.iy$") then
                table.insert(filesToDownload, file)
            end
        end
        if #filesToDownload == 0 then
            detailDlBtn.Text = "No .iy"
            detailDlBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
            return
        end
        for _, file in ipairs(filesToDownload) do
            local ok, content = pcall(function() return game:HttpGet(BASE .. "/" .. file.url) end)
            if ok then
                pcall(function() writefile(file.filename, content) end)
            else
                success = false
            end
        end
        if success then
            if not downloadedPlugins[plugin.id] then
                downloadedPlugins[plugin.id] = true
                downloadedCount = downloadedCount + 1
                saveConfig()
            end
            detailDlBtn.Text = "Installed"
            detailDlBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
            if cards[plugin.id] then
                cards[plugin.id].dlBtn.Text = "Installed"
                cards[plugin.id].dlBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
                if cards[plugin.id].unBtn then cards[plugin.id].unBtn.Visible = true end
            end
            for _, file in ipairs(filesToDownload) do
                pcall(function() if addPlugin then addPlugin(file.filename) end end)
            end
        else
            detailDlBtn.Text = "Fail"
            detailDlBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
        end
    end)
end)
detailDlBtn.MouseEnter:Connect(function()
    TweenService:Create(detailDlBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(51, 51, 51)}):Play()
end)
detailDlBtn.MouseLeave:Connect(function()
    TweenService:Create(detailDlBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 42)}):Play()
end)
local function uninstallPlugin(plugin, dlBtn, unBtn)
    if not (delfile and isfile) then return end
    for _, file in ipairs(plugin.files or {}) do
        if file.filename:lower():match("%.iy$") then
            pcall(function() delfile(file.filename) end)
        end
    end
    downloadedPlugins[plugin.id] = nil
    downloadedCount = downloadedCount - 1
    saveConfig()
    dlBtn.Text = "Get"
    dlBtn.TextColor3 = Color3.fromRGB(229, 229, 229)
    unBtn.Visible = false   
end
local function createPluginCard(plugin, index)
    local card = Instance.new("TextButton")
    card.Name = "Card_" .. (plugin.name or tostring(index))
    card.Text = ""
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    card.BorderSizePixel = 0
    card.LayoutOrder = index
    card.AutoButtonColor = false
    card.Parent = listFrame
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(255, 255, 255)
    cardStroke.Transparency = 0.96
    cardStroke.Thickness = 1
    cardStroke.Parent = card
    local authorName = plugin.author and plugin.author.name or "Unknown"
    local initial = string.upper(string.sub(authorName, 1, 1))
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 20, 0, 20)
    avatar.Position = UDim2.new(0, 10, 0, 10)
    avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    avatar.BorderSizePixel = 0
    avatar.Parent = card
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    local avatarLbl = Instance.new("TextLabel")
    avatarLbl.Text = initial
    avatarLbl.Font = Enum.Font.GothamBold
    avatarLbl.TextSize = 9
    avatarLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    avatarLbl.BackgroundTransparency = 1
    avatarLbl.Size = UDim2.new(1, 0, 1, 0)
    avatarLbl.Parent = avatar
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = plugin.name or "Untitled"
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, -40, 0, 14)
    nameLabel.Position = UDim2.new(0, 36, 0, 8)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    local authorLabel = Instance.new("TextLabel")
    authorLabel.Text = authorName
    authorLabel.Font = Enum.Font.Gotham
    authorLabel.TextSize = 9
    authorLabel.TextColor3 = Color3.fromRGB(161, 161, 170)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Size = UDim2.new(1, -40, 0, 12)
    authorLabel.Position = UDim2.new(0, 36, 0, 22)
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.TextTruncate = Enum.TextTruncate.AtEnd
    authorLabel.Parent = card
    local metaLabel = Instance.new("TextLabel")
    metaLabel.Text = fmtDate(plugin.date)
    metaLabel.Font = Enum.Font.Gotham
    metaLabel.TextSize = 8
    metaLabel.TextColor3 = Color3.fromRGB(80, 80, 80)
    metaLabel.BackgroundTransparency = 1
    metaLabel.Size = UDim2.new(0.5, 0, 0, 12)
    metaLabel.Position = UDim2.new(0, 10, 1, -20)
    metaLabel.TextXAlignment = Enum.TextXAlignment.Left
    metaLabel.Parent = card
    local dlBtn = Instance.new("TextButton")
    dlBtn.Name = "DL"
    if downloadedPlugins[plugin.id] then
        dlBtn.Text = "Installed"
        dlBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
    else
        dlBtn.Text = "Get"
        dlBtn.TextColor3 = Color3.fromRGB(229, 229, 229)
    end
    dlBtn.Font = Enum.Font.GothamMedium
    dlBtn.TextSize = 9
    dlBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    dlBtn.Size = UDim2.new(0, 52, 0, 20)
    dlBtn.Position = UDim2.new(1, -58, 1, -26)
    dlBtn.ZIndex = 2
    dlBtn.Parent = card
    Instance.new("UICorner", dlBtn).CornerRadius = UDim.new(0, 5)
    local unBtn = Instance.new("TextButton")
    unBtn.Name = "UN"
    unBtn.Text = "🗑️"
    unBtn.Font = Enum.Font.GothamBold
    unBtn.TextSize = 10
    unBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
    unBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    unBtn.Size = UDim2.new(0, 20, 0, 20)
    unBtn.Position = UDim2.new(1, -82, 1, -26)
    unBtn.ZIndex = 2
    unBtn.Visible = downloadedPlugins[plugin.id] and true or false
    unBtn.Parent = card
    Instance.new("UICorner", unBtn).CornerRadius = UDim.new(0, 5)
    dlBtn.MouseEnter:Connect(function()
        TweenService:Create(dlBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(51, 51, 51)}):Play()
    end)
    dlBtn.MouseLeave:Connect(function()
        TweenService:Create(dlBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}):Play()
    end)
    unBtn.MouseEnter:Connect(function()
        TweenService:Create(unBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(51, 51, 51)}):Play()
    end)
    unBtn.MouseLeave:Connect(function()
        TweenService:Create(unBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}):Play()
    end)
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(17, 18, 22)}):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 0.96}):Play()
    end)
    card.MouseButton1Click:Connect(function()
        showDetail(plugin)
    end)
    return card, dlBtn, unBtn
end

minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(229, 229, 229)}):Play()
end)
minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(153, 153, 153)}):Play()
end)
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(229, 229, 229)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(153, 153, 153)}):Play()
end)
dlAllBtn.MouseEnter:Connect(function()
    TweenService:Create(dlAllBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(229, 229, 229)}):Play()
end)
dlAllBtn.MouseLeave:Connect(function()
    TweenService:Create(dlAllBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(153, 153, 153)}):Play()
end)
local function downloadPlugin(plugin, dlBtn)
    if not writefile then
        dlBtn.Text = "N/A"
        dlBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
        return
    end
    dlBtn.Text = "..."
    dlBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
    local success = true
    local filesToDownload = {}
    for _, file in ipairs(plugin.files or {}) do
        if file.filename:lower():match("%.iy$") then
            table.insert(filesToDownload, file)
        end
    end
    if #filesToDownload == 0 then
        dlBtn.Text = "No .iy"
        dlBtn.TextColor3 = Color3.fromRGB(153, 153, 153)
        return
    end
    for _, file in ipairs(filesToDownload) do
        local ok, content = pcall(function() return game:HttpGet(BASE .. "/" .. file.url) end)
        if ok then
            pcall(function() writefile(file.filename, content) end)
        else success = false end
    end
    if success then
        downloadedCount = downloadedCount + 1
        updateCounter()
        dlBtn.Text = "Done"
        dlBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
    else
        dlBtn.Text = "Fail"
        dlBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
    end
end
local function renderList(pluginList)
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Name:match("^Card_") then child:Destroy() end
    end
    if listFrame:FindFirstChild("Loading") then listFrame.Loading:Destroy() end
    cards = {}
    if #pluginList == 0 then
        local empty = Instance.new("TextButton")
        empty.Name = "Card_Empty"
        empty.Text = ""
        empty.Size = UDim2.new(1, 0, 0, 60)
        empty.BackgroundTransparency = 1
        empty.LayoutOrder = 1
        empty.AutoButtonColor = false
        empty.Parent = listFrame
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Text = "No plugins found."
        emptyLbl.Font = Enum.Font.Gotham
        emptyLbl.TextSize = 13
        emptyLbl.TextColor3 = Color3.fromRGB(102, 102, 102)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.Size = UDim2.new(1, 0, 1, 0)
        emptyLbl.Parent = empty
        return
    end
    for i, plugin in ipairs(pluginList) do
        local card, dlBtn, unBtn = createPluginCard(plugin, i)
        cards[plugin.id] = {card = card, dlBtn = dlBtn, unBtn = unBtn}
        dlBtn.MouseButton1Click:Connect(function()
            if dlBtn.Text == "Installed" or dlBtn.Text == "..." then return end
            task.spawn(function() 
                downloadPlugin(plugin, dlBtn)
                if not downloadedPlugins[plugin.id] then
                    downloadedPlugins[plugin.id] = true
                    downloadedCount = downloadedCount + 1
                    saveConfig()
                end
                if unBtn then unBtn.Visible = true end
                for _, file in ipairs(plugin.files or {}) do
                    if file.filename:lower():match("%.iy$") then
                        pcall(function() if addPlugin then addPlugin(file.filename) end end)
                    end
                end
            end)
        end)
        unBtn.MouseButton1Click:Connect(function()
            uninstallPlugin(plugin, dlBtn, unBtn)
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
            local author = (p.author and p.author.name or ""):lower()
            if name:find(q, 1, true) or author:find(q, 1, true) then
                table.insert(filteredPlugins, p)
            end
        end
    end
    renderList(filteredPlugins)
end
local function downloadAll()
    if not writefile then
        progressLabel.Text = "writefile not supported"
        return
    end
    local plugins = filteredPlugins
    local total = #plugins
    if total == 0 then return end
    dlAllBtn.Visible = false
    progressFrame.Visible = true
    listFrame.Size = UDim2.new(1, -32, 1, -200)
    for i, plugin in ipairs(plugins) do
        progressLabel.Text = string.format("%d/%d  %s", i, total, plugin.name or "?")
        TweenService:Create(progressBar, TweenInfo.new(0.15), {Size = UDim2.new(i / total, 0, 1, 0)}):Play()
        local filesToDownload = {}
        for _, file in ipairs(plugin.files or {}) do
            if file.filename:lower():match("%.iy$") then
                table.insert(filesToDownload, file)
            end
        end
        for _, file in ipairs(filesToDownload) do
            local ok, content = pcall(function() return game:HttpGet(BASE .. "/" .. file.url) end)
            if ok then pcall(function() writefile(file.filename, content) end) end
        end
        if not downloadedPlugins[plugin.id] then
            downloadedPlugins[plugin.id] = true
            downloadedCount = downloadedCount + 1
        end
        updateCounter()
        if cards[plugin.id] then
            cards[plugin.id].dlBtn.Text = "Installed"
            cards[plugin.id].dlBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
            if cards[plugin.id].unBtn then cards[plugin.id].unBtn.Visible = true end
        end
        for _, file in ipairs(plugin.files or {}) do
            if file.filename:lower():match("%.iy$") then
                pcall(function() if addPlugin then addPlugin(file.filename) end end)
            end
        end
        task.wait()
    end
    saveConfig()
    progressLabel.Text = string.format("Done — %d plugins", total)
    TweenService:Create(progressBar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(110, 231, 183)}):Play()
    task.delay(2, function()
        progressFrame.Visible = false
        listFrame.Size = UDim2.new(1, -32, 1, -100)
        dlAllBtn.Visible = true
    end)
end
local function autoLoadPlugins()
    if not listfiles or not isfolder then return end
    for _, filePath in ipairs(listfiles("")) do
        local fileName = filePath:match("([^/\\]+%.iy)$")
        if fileName and fileName:lower() ~= "iy_fe.iy" and not isfolder(fileName) and (not PluginsTable or not table.find(PluginsTable, fileName)) then
            pcall(function() if addPlugin then addPlugin(fileName) end end)
        end
    end
end
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniBtn.Visible = true
end)
miniBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    miniBtn.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniBtn.Visible = false
    task.delay(0.1, function()
        screenGui:Destroy()
    end)
end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterPlugins(searchBox.Text)
end)

dlAllBtn.MouseButton1Click:Connect(function()
    task.spawn(downloadAll)
end)

task.spawn(function()
    loadConfig()
    local ok, response = pcall(function() return game:HttpGet(API_URL) end)
    if not ok then
        loadingLabel.Text = "Failed to load plugins."
        return
    end
    local data = HttpService:JSONDecode(response)
    allPlugins = data.plugins or {}

    table.sort(allPlugins, function(a, b)
        return parseDate(a.date) > parseDate(b.date)
    end)

    local authors = {}
    for _, p in ipairs(allPlugins) do
        local aName = p.author and p.author.name or nil
        if aName then authors[aName] = true end
    end
    local authorCount = 0
    for _ in pairs(authors) do authorCount = authorCount + 1 end
    statLabel.Text = tostring(#allPlugins) .. " plugins · " .. tostring(authorCount) .. " authors"
    dlAllBtn.Visible = true
    filteredPlugins = allPlugins
    renderList(allPlugins)
end)
