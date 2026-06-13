local Plugin = {
    ["PluginName"] = "ExecutorGUI",
    ["PluginDescription"] = "Opens an executor GUI and adds a URL loadstring command.",
    ["Commands"] = {}
}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local ENV = (getgenv and getgenv()) or _G

local GUI_NAME = "IY_EXECUTOR_GUI_V6"
local CACHE_KEY = "__IY_EXECUTOR_GUI_LAST_SOURCE_V6"
local PLACEHOLDER = "-- Cached script stored internally.\n-- Press Execute again to run the same full script.\n-- Paste new code here to replace the cached script."

local guiRef = nil
local codeBoxRef = nil
local statusRef = nil

local function trim(text)
    return tostring(text or ""):match("^%s*(.-)%s*$") or ""
end

local function iyNotify(title, text)
    local didNotify = false

    if type(notify) == "function" then
        didNotify = pcall(function()
            notify(tostring(title), tostring(text))
        end)
    end

    if not didNotify then
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = tostring(title),
                Text = tostring(text),
                Duration = 4
            })
        end)
    end
end

local function setStatus(text)
    text = tostring(text or "")
    if statusRef and statusRef.Parent then
        pcall(function()
            statusRef.Text = text
        end)
    end
end

local function getGuiParent()
    local ok = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        test:Destroy()
    end)

    if ok then
        return CoreGui
    end

    return LocalPlayer and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
end

local function closeExecutor()
    local parent = getGuiParent()
    local old = parent:FindFirstChild(GUI_NAME)
    if old then
        old:Destroy()
    end
    guiRef = nil
    codeBoxRef = nil
    statusRef = nil
end

local function getCachedSource()
    local cached = ENV[CACHE_KEY]
    if type(cached) == "table" and type(cached.Source) == "string" then
        return cached.Source, cached
    elseif type(cached) == "string" then
        return cached, { Source = cached, Label = "cached", Size = #cached }
    end
    return nil, nil
end

local function setCachedSource(source, label)
    source = tostring(source or "")
    ENV[CACHE_KEY] = {
        Source = source,
        Label = tostring(label or "editor"),
        Size = #source,
        SavedAt = os.time()
    }
end

local function isPlaceholderText(text)
    text = tostring(text or "")
    return text:find("Cached script stored internally", 1, true) ~= nil
        or text:find("Press Execute again to run the same full script", 1, true) ~= nil
end

local function looksLikeCorruptedEditorText(text)
    local clean = trim(text)
    if clean == "" then
        return false
    end

    return clean:match("^Current%s+autoload%s+config%s*:") ~= nil
        or clean:match("^Current%s+auto%-load%s+config%s*:") ~= nil
        or clean:match("^Auto%-load%s*:") ~= nil
end

local function firstLine(text)
    text = tostring(text or "")
    return (text:match("([^\n\r]*)") or "")
end

local function runSource(inputSource, label, forceCached)
    label = tostring(label or "editor")

    local source = tostring(inputSource or "")
    local cachedSource = getCachedSource()

    if forceCached then
        if not cachedSource then
            iyNotify("Executor", "No cached script found.")
            setStatus("No cached script found.")
            return false
        end
        source = cachedSource
        label = "cached"
    elseif isPlaceholderText(source) or looksLikeCorruptedEditorText(source) then
        if cachedSource then
            source = cachedSource
            label = "cached fallback"
        end
    end

    if trim(source) == "" then
        iyNotify("Executor", "No code entered.")
        setStatus("No code entered.")
        return false
    end

    if type(loadstring) ~= "function" then
        iyNotify("Executor", "loadstring is unavailable.")
        warn("ExecutorGUI: loadstring is unavailable in this environment.")
        setStatus("loadstring unavailable.")
        return false
    end

    local fn, compileErr = loadstring(source)

    if not fn and cachedSource and source ~= cachedSource then
        local retryFn, retryErr = loadstring(cachedSource)
        if retryFn then
            source = cachedSource
            label = "cached compile fallback"
            fn = retryFn
            compileErr = nil
        else
            compileErr = compileErr or retryErr
        end
    end

    if not fn then
        iyNotify("Executor", "Compile Error")
        warn(("ExecutorGUI Compile Error [%s, %d chars]: %s"):format(label, #source, tostring(compileErr)))
        warn("ExecutorGUI first 200 chars:", source:sub(1, 200))
        setStatus("Compile error. First line: " .. firstLine(source):sub(1, 90))
        return false
    end

    setCachedSource(source, label)

    if codeBoxRef and codeBoxRef.Parent and #source >= 10000 then
        pcall(function()
            codeBoxRef.Text = PLACEHOLDER
        end)
    end

    setStatus(("Running %s (%d chars)..."):format(label, #source))

    task.spawn(function()
        local ok, runtimeErr = pcall(fn)
        if ok then
            iyNotify("Executor", "Executed.")
            setStatus(("Executed %s (%d chars). Cached internally."):format(label, #source))
        else
            iyNotify("Executor", "Runtime Error")
            warn(("ExecutorGUI Runtime Error [%s, %d chars]: %s"):format(label, #source, tostring(runtimeErr)))
            setStatus("Runtime error: " .. tostring(runtimeErr):sub(1, 120))
        end
    end)

    return true
end

local function normalizeUrl(url)
    url = trim(url)

    if url == "" then
        return ""
    end

    if not url:match("^https?://") then
        url = "https://" .. url
    end

    if url:find("pastebin.com/", 1, true) and not url:find("pastebin.com/raw/", 1, true) then
        local id = url:match("pastebin%.com/([%w%d]+)")
        if id and id ~= "raw" then
            url = "https://pastebin.com/raw/" .. id
        end
    end

    return url
end

local function runUrl(url)
    url = normalizeUrl(url)

    if url == "" then
        iyNotify("Loadstring", "Missing URL.")
        return false
    end

    setStatus("Fetching URL...")

    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        iyNotify("Loadstring", "HttpGet failed.")
        warn("ExecutorGUI HttpGet Error:", result)
        setStatus("HttpGet failed.")
        return false
    end

    return runSource(result, "url")
end

local function openExecutor()
    closeExecutor()

    local parent = getGuiParent()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = GUI_NAME
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent
    guiRef = screenGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 610, 0, 410)
    main.Position = UDim2.new(0.5, -305, 0.5, -205)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    main.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -55, 0, 38)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "IY Executor"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 32)
    closeButton.Position = UDim2.new(1, -46, 0, 4)
    closeButton.BackgroundColor3 = Color3.fromRGB(165, 35, 35)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = main

    local editorFrame = Instance.new("Frame")
    editorFrame.Name = "EditorFrame"
    editorFrame.Size = UDim2.new(1, -24, 1, -122)
    editorFrame.Position = UDim2.new(0, 12, 0, 44)
    editorFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    editorFrame.BorderSizePixel = 0
    editorFrame.ClipsDescendants = true
    editorFrame.Parent = main

    local codeBox = Instance.new("TextBox")
    codeBox.Name = "CodeBox"
    codeBox.Size = UDim2.new(1, -12, 1, -12)
    codeBox.Position = UDim2.new(0, 6, 0, 6)
    codeBox.BackgroundTransparency = 1
    codeBox.Text = ""
    codeBox.PlaceholderText = "Paste Lua code here..."
    codeBox.TextColor3 = Color3.fromRGB(245, 245, 245)
    codeBox.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
    codeBox.TextSize = 15
    codeBox.Font = Enum.Font.Code
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.MultiLine = true
    codeBox.TextWrapped = false
    codeBox.ClipsDescendants = true
    codeBox.Parent = editorFrame
    codeBoxRef = codeBox

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -24, 0, 22)
    status.Position = UDim2.new(0, 12, 1, -74)
    status.BackgroundTransparency = 1
    status.Text = "Ready. Large scripts are cached internally after compile."
    status.TextColor3 = Color3.fromRGB(210, 210, 210)
    status.TextSize = 14
    status.Font = Enum.Font.SourceSans
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd
    status.Parent = main
    statusRef = status

    local executeButton = Instance.new("TextButton")
    executeButton.Name = "ExecuteButton"
    executeButton.Size = UDim2.new(0.5, -18, 0, 42)
    executeButton.Position = UDim2.new(0, 12, 1, -48)
    executeButton.BackgroundColor3 = Color3.fromRGB(35, 105, 55)
    executeButton.BorderSizePixel = 0
    executeButton.Text = "Execute"
    executeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeButton.TextSize = 17
    executeButton.Font = Enum.Font.SourceSansBold
    executeButton.Parent = main

    local clearButton = Instance.new("TextButton")
    clearButton.Name = "ClearButton"
    clearButton.Size = UDim2.new(0.5, -18, 0, 42)
    clearButton.Position = UDim2.new(0.5, 6, 1, -48)
    clearButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    clearButton.BorderSizePixel = 0
    clearButton.Text = "Clear"
    clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearButton.TextSize = 17
    clearButton.Font = Enum.Font.SourceSansBold
    clearButton.Parent = main

    closeButton.MouseButton1Click:Connect(function()
        closeExecutor()
    end)

    executeButton.MouseButton1Click:Connect(function()
        runSource(codeBox.Text, "editor", false)
    end)


    clearButton.MouseButton1Click:Connect(function()
        codeBox.Text = ""
        setStatus("Editor cleared. Cache is still kept internally.")
    end)

    iyNotify("Executor", "GUI opened.")
end

Plugin["Commands"]["executor"] = {
    ["ListName"] = "executor",
    ["Description"] = "Opens the executor GUI.",
    ["Aliases"] = { "execgui", "openexecutor", "opengui" },
    ["Function"] = function(args, speaker)
        openExecutor()
    end
}

Plugin["Commands"]["closeexecutor"] = {
    ["ListName"] = "closeexecutor",
    ["Description"] = "Closes the executor GUI.",
    ["Aliases"] = { "unexecutor", "cexec", "closeexec", "execoff" },
    ["Function"] = function(args, speaker)
        closeExecutor()
        iyNotify("Executor", "GUI closed.")
    end
}

Plugin["Commands"]["loadstring"] = {
    ["ListName"] = "loadstring [url]",
    ["Description"] = "Fetches code from a website URL and executes it.",
    ["Aliases"] = { "lsurl", "runurl", "webexec" },
    ["Function"] = function(args, speaker)
        runUrl(table.concat(args or {}, " "))
    end
}

return Plugin
