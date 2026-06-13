local Plugin = {
    ["PluginName"] = "Advanced Welder",
    ["PluginDescription"] = "Professional PhysicsRepRootPart welder with 3D preview and hidden velocity support.",
    ["Commands"] = {}
}

local RunService = Services.RunService
local UserInputService = Services.UserInputService
local Players = Services.Players
local LocalPlayer = Players.LocalPlayer

local WelderUI = nil
local MainFrame = nil
local SelectedA, SelectedB = nil, nil
local OffsetX, OffsetY, OffsetZ = 0, 0, 0
local AngleX, AngleY, AngleZ = 0, 0, 0
local AutoRotateEnabled = true
local UseHiddenVelocity = true
local LiveWeldEnabled = false
local WeldConnection = nil
local RotationAngle = 0
local ViewportA, CameraA, ViewportB, CameraB, ViewportCombined, CameraCombined
local PreviewPartA, PreviewPartB
local SelectionBoxA, SelectionBoxB, HoverBox
local HighlightConnection = nil
local IYMouse = LocalPlayer:GetMouse()

local function randomString()
    local length = math.random(10, 20)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(97, 122))
    end
    return table.concat(array)
end

local function CreateLabel(parent, text, yPos)
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, yPos)
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 10
    table.insert(text1, Label)
    Label.Parent = parent
    return Label
end

local function CreateToggle(parent, text, yPos, default, callback)
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, yPos)
    Container.Size = UDim2.new(1, -20, 0, 25)
    Container.ZIndex = 10
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 10
    table.insert(text1, Label)
    Label.Parent = Container
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Position = UDim2.new(1, -50, 0, 2)
    ToggleFrame.Size = UDim2.new(0, 50, 0, 20)
    ToggleFrame.ZIndex = 10
    table.insert(shade2, ToggleFrame)
    ToggleFrame.Parent = Container
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 11
    ToggleBtn.Text = tostring(default)
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.ZIndex = 10
    table.insert(text1, ToggleBtn)
    ToggleBtn.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ToggleBtn
    
    local State = default
    
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ToggleBtn.Text = tostring(State)
        ToggleBtn.BackgroundColor3 = State and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        callback(State)
    end)
    
    return Container
end

local function CreateViewport(parent, yPos, height)
    local Container = Instance.new("Frame")
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 21)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 10, 0, yPos)
    Container.Size = UDim2.new(1, -20, 0, height)
    Container.ZIndex = 10
    table.insert(shade1, Container)
    Container.Parent = parent
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 4)
    ContainerCorner.Parent = Container
    
    local Viewport = Instance.new("ViewportFrame")
    Viewport.BackgroundTransparency = 1
    Viewport.Size = UDim2.new(1, 0, 1, 0)
    Viewport.Ambient = Color3.fromRGB(180, 180, 180)
    Viewport.LightColor = Color3.fromRGB(255, 255, 255)
    Viewport.LightDirection = Vector3.new(-1, -1, -1)
    Viewport.ZIndex = 10
    Viewport.Parent = Container
    
    local Camera = Instance.new("Camera")
    Camera.FieldOfView = 50
    Camera.Parent = Viewport
    Viewport.CurrentCamera = Camera
    
    return Viewport, Camera, Container
end

local function CreateGrid(viewport, size, divisions)
    local GridFolder = Instance.new("Folder")
    GridFolder.Name = "Grid"
    GridFolder.Parent = viewport
    
    local cellSize = size / divisions
    
    for i = -divisions, divisions do
        local LineX = Instance.new("Part")
        LineX.Anchored = true
        LineX.CanCollide = false
        LineX.CanTouch = false
        LineX.CanQuery = false
        LineX.Size = Vector3.new(size * 2, 0.02, 0.02)
        LineX.Position = Vector3.new(0, 0, i * cellSize)
        LineX.Color = Color3.fromRGB(50, 50, 50)
        LineX.Material = Enum.Material.SmoothPlastic
        LineX.Transparency = 0.6
        LineX.Parent = GridFolder
        
        local LineZ = Instance.new("Part")
        LineZ.Anchored = true
        LineZ.CanCollide = false
        LineZ.CanTouch = false
        LineZ.CanQuery = false
        LineZ.Size = Vector3.new(0.02, 0.02, size * 2)
        LineZ.Position = Vector3.new(i * cellSize, 0, 0)
        LineZ.Color = Color3.fromRGB(50, 50, 50)
        LineZ.Material = Enum.Material.SmoothPlastic
        LineZ.Transparency = 0.6
        LineZ.Parent = GridFolder
    end
end

local function CreateAxes(viewport, length)
    local AxesFolder = Instance.new("Folder")
    AxesFolder.Name = "Axes"
    AxesFolder.Parent = viewport
    
    local function CreateAxis(color, size, pos)
        local Axis = Instance.new("Part")
        Axis.Anchored = true
        Axis.CanCollide = false
        Axis.CanTouch = false
        Axis.CanQuery = false
        Axis.Size = size
        Axis.Position = pos
        Axis.Color = color
        Axis.Material = Enum.Material.Neon
        Axis.Transparency = 0.2
        Axis.Parent = AxesFolder
        
        local Arrow = Instance.new("Part")
        Arrow.Anchored = true
        Arrow.CanCollide = false
        Arrow.CanTouch = false
        Arrow.CanQuery = false
        Arrow.Shape = Enum.PartType.Ball
        Arrow.Size = Vector3.new(0.2, 0.2, 0.2)
        Arrow.Position = pos + (size / 2)
        Arrow.Color = color
        Arrow.Material = Enum.Material.Neon
        Arrow.Parent = AxesFolder
    end
    
    CreateAxis(Color3.fromRGB(255, 50, 50), Vector3.new(length, 0.08, 0.08), Vector3.new(length/2, 0, 0))
    CreateAxis(Color3.fromRGB(50, 255, 50), Vector3.new(0.08, length, 0.08), Vector3.new(0, length/2, 0))
    CreateAxis(Color3.fromRGB(50, 50, 255), Vector3.new(0.08, 0.08, length), Vector3.new(0, 0, length/2))
end

local function UpdateViewportSingle(viewport, camera, part, color)
    if not part then return nil end
    
    for _, child in viewport:GetChildren() do
        if child.Name == "PreviewPart" then
            child:Destroy()
        end
    end
    
    local Clone = Instance.new("Part")
    Clone.Name = "PreviewPart"
    Clone.Anchored = true
    Clone.CanCollide = false
    Clone.CanTouch = false
    Clone.CanQuery = false
    Clone.Size = part.Size
    Clone.Color = color or part.Color
    Clone.Material = part.Material
    Clone.Transparency = math.max(part.Transparency, 0.3)
    Clone.CFrame = CFrame.new(0, part.Size.Y / 2, 0)
    Clone.Parent = viewport
    
    local Size = Clone.Size.Magnitude
    camera.CFrame = CFrame.new(Vector3.new(Size * 1.5, Size, Size * 1.5), Clone.Position)
    
    return Clone
end

local function UpdateCombinedViewport()
    for _, child in ViewportCombined:GetChildren() do
        if child.Name == "PreviewPartA" or child.Name == "PreviewPartB" then
            child:Destroy()
        end
    end
    
    if SelectedA then
        PreviewPartA = Instance.new("Part")
        PreviewPartA.Name = "PreviewPartA"
        PreviewPartA.Anchored = true
        PreviewPartA.CanCollide = false
        PreviewPartA.CanTouch = false
        PreviewPartA.CanQuery = false
        PreviewPartA.Size = SelectedA.Size
        PreviewPartA.Color = Color3.fromRGB(255, 100, 100)
        PreviewPartA.Material = Enum.Material.SmoothPlastic
        PreviewPartA.Transparency = 0.3
        PreviewPartA.CFrame = CFrame.new(0, SelectedA.Size.Y / 2, 0)
        PreviewPartA.Parent = ViewportCombined
    end
    
    if SelectedB then
        PreviewPartB = Instance.new("Part")
        PreviewPartB.Name = "PreviewPartB"
        PreviewPartB.Anchored = true
        PreviewPartB.CanCollide = false
        PreviewPartB.CanTouch = false
        PreviewPartB.CanQuery = false
        PreviewPartB.Size = SelectedB.Size
        PreviewPartB.Color = Color3.fromRGB(100, 100, 255)
        PreviewPartB.Material = Enum.Material.SmoothPlastic
        PreviewPartB.Transparency = 0.3
        
        local Offset = CFrame.new(OffsetX, OffsetY, OffsetZ) * CFrame.Angles(math.rad(AngleX), math.rad(AngleY), math.rad(AngleZ))
        PreviewPartB.CFrame = PreviewPartA and (PreviewPartA.CFrame * Offset) or CFrame.new(OffsetX, OffsetY + SelectedB.Size.Y / 2, OffsetZ)
        PreviewPartB.Parent = ViewportCombined
    end
    
    local MaxSize = 5
    if SelectedA then MaxSize = math.max(MaxSize, SelectedA.Size.Magnitude) end
    if SelectedB then MaxSize = math.max(MaxSize, SelectedB.Size.Magnitude) end
    
    CameraCombined.CFrame = CFrame.new(Vector3.new(MaxSize * 2, MaxSize * 1.5, MaxSize * 2), Vector3.new(0, MaxSize / 2, 0))
end

local function GetFullPath(instance)
    local path = instance.Name
    local current = instance.Parent
    
    while current and current ~= game do
        if current == workspace then
            path = "workspace." .. path
            break
        elseif current == game:GetService("ReplicatedStorage") then
            path = 'game:GetService("ReplicatedStorage").' .. path
            break
        else
            path = current.Name .. "." .. path
        end
        current = current.Parent
    end
    
    return path
end

local function CreatePathInput(parent, label, yPos, onSelect, selectionBox)
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, yPos)
    Container.Size = UDim2.new(1, -20, 0, 70)
    Container.ZIndex = 10
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 12
    Label.Text = label
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 10
    table.insert(text1, Label)
    Label.Parent = Container
    
    local PathBox = Instance.new("TextBox")
    PathBox.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    PathBox.BorderSizePixel = 0
    PathBox.Position = UDim2.new(0, 0, 0, 20)
    PathBox.Size = UDim2.new(1, 0, 0, 25)
    PathBox.Font = Enum.Font.SourceSans
    PathBox.TextSize = 11
    PathBox.Text = ""
    PathBox.PlaceholderText = "workspace.PartName or click Select"
    PathBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    PathBox.TextColor3 = Color3.new(1, 1, 1)
    PathBox.TextXAlignment = Enum.TextXAlignment.Left
    PathBox.ClearTextOnFocus = false
    PathBox.ZIndex = 10
    table.insert(shade2, PathBox)
    table.insert(text1, PathBox)
    PathBox.Parent = Container
    
    local PathCorner = Instance.new("UICorner")
    PathCorner.CornerRadius = UDim.new(0, 4)
    PathCorner.Parent = PathBox
    
    local PathPadding = Instance.new("UIPadding")
    PathPadding.PaddingLeft = UDim.new(0, 8)
    PathPadding.Parent = PathBox
    
    local SelectBtn = Instance.new("TextButton")
    SelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 61)
    SelectBtn.BorderSizePixel = 0
    SelectBtn.Position = UDim2.new(0, 0, 0, 48)
    SelectBtn.Size = UDim2.new(0.48, 0, 0, 22)
    SelectBtn.Font = Enum.Font.SourceSans
    SelectBtn.TextSize = 12
    SelectBtn.Text = "Select (Mouse)"
    SelectBtn.TextColor3 = Color3.new(1, 1, 1)
    SelectBtn.ZIndex = 10
    table.insert(shade2, SelectBtn)
    table.insert(text1, SelectBtn)
    SelectBtn.Parent = Container
    
    local SelectCorner = Instance.new("UICorner")
    SelectCorner.CornerRadius = UDim.new(0, 4)
    SelectCorner.Parent = SelectBtn
    
    local ApplyPathBtn = Instance.new("TextButton")
    ApplyPathBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 61)
    ApplyPathBtn.BorderSizePixel = 0
    ApplyPathBtn.Position = UDim2.new(0.52, 0, 0, 48)
    ApplyPathBtn.Size = UDim2.new(0.48, 0, 0, 22)
    ApplyPathBtn.Font = Enum.Font.SourceSans
    ApplyPathBtn.TextSize = 12
    ApplyPathBtn.Text = "Apply Path"
    ApplyPathBtn.TextColor3 = Color3.new(1, 1, 1)
    ApplyPathBtn.ZIndex = 10
    table.insert(shade2, ApplyPathBtn)
    table.insert(text1, ApplyPathBtn)
    ApplyPathBtn.Parent = Container
    
    local ApplyCorner = Instance.new("UICorner")
    ApplyCorner.CornerRadius = UDim.new(0, 4)
    ApplyCorner.Parent = ApplyPathBtn
    
    ApplyPathBtn.MouseButton1Click:Connect(function()
        local Path = PathBox.Text
        if Path == "" then return end
        
        local success, result = pcall(function()
            local func = loadstring("return " .. Path)
            if func then
                return func()
            end
        end)
        
        if success and result and typeof(result) == "Instance" and result:IsA("BasePart") then
            PathBox.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            onSelect(result, PathBox)
            task.delay(0.5, function()
                PathBox.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
            end)
        else
            PathBox.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            task.delay(0.5, function()
                PathBox.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
            end)
        end
    end)
    
    SelectBtn.MouseButton1Click:Connect(function()
        SelectBtn.Text = "Click Part..."
        SelectBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        
        if HighlightConnection then
            HighlightConnection:Disconnect()
        end
        
        HighlightConnection = RunService.RenderStepped:Connect(function()
            local Target = IYMouse.Target
            if Target and Target:IsA("BasePart") then
                local TargetPlayer = Players:GetPlayerFromCharacter(Target:FindFirstAncestorOfClass("Model"))
                if not TargetPlayer then
                    HoverBox.Adornee = Target
                else
                    HoverBox.Adornee = nil
                end
            else
                HoverBox.Adornee = nil
            end
        end)
        
        local ClickConnection
        ClickConnection = IYMouse.Button1Down:Connect(function()
            local Target = IYMouse.Target
            if Target and Target:IsA("BasePart") then
                local TargetPlayer = Players:GetPlayerFromCharacter(Target:FindFirstAncestorOfClass("Model"))
                if not TargetPlayer then
                    onSelect(Target, PathBox)
                    selectionBox.Adornee = Target
                    HoverBox.Adornee = nil
                    SelectBtn.Text = "Select (Mouse)"
                    SelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 61)
                    
                    if HighlightConnection then
                        HighlightConnection:Disconnect()
                        HighlightConnection = nil
                    end
                    ClickConnection:Disconnect()
                end
            end
        end)
    end)
    
    return Container, PathBox, SelectBtn
end

local function CreateSlider(parent, label, min, max, yPos, callback)
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, yPos)
    Container.Size = UDim2.new(1, -20, 0, 35)
    Container.ZIndex = 10
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0, 25, 0, 20)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 12
    Label.Text = label
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.ZIndex = 10
    table.insert(text1, Label)
    Label.Parent = Container
    
    local SliderBG = Instance.new("Frame")
    SliderBG.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    SliderBG.BorderSizePixel = 0
    SliderBG.Position = UDim2.new(0, 30, 0, 8)
    SliderBG.Size = UDim2.new(1, -90, 0, 8)
    SliderBG.ZIndex = 10
    table.insert(shade2, SliderBG)
    SliderBG.Parent = Container
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderBG
    
    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.fromRGB(100, 149, 237)
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.new(0.5, 0, 1, 0)
    Fill.ZIndex = 10
    table.insert(shade3, Fill)
    Fill.Parent = SliderBG
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = Fill
    
    local ValueBox = Instance.new("TextBox")
    ValueBox.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    ValueBox.BorderSizePixel = 0
    ValueBox.Position = UDim2.new(1, -55, 0, 0)
    ValueBox.Size = UDim2.new(0, 55, 0, 22)
    ValueBox.Font = Enum.Font.SourceSans
    ValueBox.TextSize = 12
    ValueBox.Text = "0.00"
    ValueBox.TextColor3 = Color3.new(1, 1, 1)
    ValueBox.ZIndex = 10
    table.insert(shade2, ValueBox)
    table.insert(text1, ValueBox)
    ValueBox.Parent = Container
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 4)
    ValueCorner.Parent = ValueBox
    
    local Dragging = false
    
    local function UpdateFromPercent(percent)
        percent = math.clamp(percent, 0, 1)
        local Value = min + (max - min) * percent
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        ValueBox.Text = string.format("%.2f", Value)
        callback(Value)
        UpdateCombinedViewport()
    end
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            local percent = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            UpdateFromPercent(percent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            UpdateFromPercent(percent)
        end
    end)
    
    ValueBox.FocusLost:Connect(function()
        local Value = tonumber(ValueBox.Text) or 0
        Value = math.clamp(Value, min, max)
        local percent = (Value - min) / (max - min)
        UpdateFromPercent(percent)
    end)
    
    return Container
end

local function InitializeUI()
    SelectionBoxA = Instance.new("SelectionBox")
    SelectionBoxA.Name = randomString()
    SelectionBoxA.Color3 = Color3.fromRGB(255, 100, 100)
    SelectionBoxA.LineThickness = 0.05
    SelectionBoxA.Transparency = 0.3
    SelectionBoxA.Parent = COREGUI
    
    SelectionBoxB = Instance.new("SelectionBox")
    SelectionBoxB.Name = randomString()
    SelectionBoxB.Color3 = Color3.fromRGB(100, 100, 255)
    SelectionBoxB.LineThickness = 0.05
    SelectionBoxB.Transparency = 0.3
    SelectionBoxB.Parent = COREGUI
    
    HoverBox = Instance.new("SelectionBox")
    HoverBox.Name = randomString()
    HoverBox.Color3 = Color3.fromRGB(255, 255, 0)
    HoverBox.LineThickness = 0.03
    HoverBox.Transparency = 0.5
    HoverBox.Parent = COREGUI
    
    WelderUI = Instance.new("Frame")
    WelderUI.Name = randomString()
    WelderUI.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
    WelderUI.BorderSizePixel = 0
    WelderUI.Position = UDim2.new(0.5, -450, 0.5, -325)
    WelderUI.Size = UDim2.new(0, 900, 0, 650)
    WelderUI.Visible = false
    WelderUI.ZIndex = 10
    table.insert(shade1, WelderUI)
    WelderUI.Parent = PARENT
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = WelderUI
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.ZIndex = 10
    table.insert(shade2, TitleBar)
    TitleBar.Parent = WelderUI
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    TitleFix.BorderSizePixel = 0
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.ZIndex = 10
    table.insert(shade2, TitleFix)
    TitleFix.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 16
    Title.Text = "Advanced Welder - PhysicsRepRootPart"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 10
    table.insert(text1, Title)
    Title.Parent = TitleBar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 18
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.ZIndex = 10
    table.insert(text1, CloseBtn)
    CloseBtn.Parent = TitleBar
    
    CloseBtn.MouseButton1Click:Connect(function()
        WelderUI.Visible = false
        if WeldConnection then
            WeldConnection:Disconnect()
            WeldConnection = nil
        end
        if HighlightConnection then
            HighlightConnection:Disconnect()
            HighlightConnection = nil
        end
        SelectionBoxA.Adornee = nil
        SelectionBoxB.Adornee = nil
        HoverBox.Adornee = nil
    end)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 30)
    ContentFrame.Size = UDim2.new(1, 0, 1, -30)
    ContentFrame.ZIndex = 10
    ContentFrame.Parent = WelderUI
    
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftPanel"
    LeftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 31)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Position = UDim2.new(0, 5, 0, 5)
    LeftPanel.Size = UDim2.new(0.33, -7, 1, -10)
    LeftPanel.ZIndex = 10
    table.insert(shade1, LeftPanel)
    LeftPanel.Parent = ContentFrame
    
    local LeftCorner = Instance.new("UICorner")
    LeftCorner.CornerRadius = UDim.new(0, 6)
    LeftCorner.Parent = LeftPanel
    
    local CenterPanel = Instance.new("Frame")
    CenterPanel.Name = "CenterPanel"
    CenterPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 31)
    CenterPanel.BorderSizePixel = 0
    CenterPanel.Position = UDim2.new(0.33, 3, 0, 5)
    CenterPanel.Size = UDim2.new(0.34, -6, 1, -10)
    CenterPanel.ZIndex = 10
    table.insert(shade1, CenterPanel)
    CenterPanel.Parent = ContentFrame
    
    local CenterCorner = Instance.new("UICorner")
    CenterCorner.CornerRadius = UDim.new(0, 6)
    CenterCorner.Parent = CenterPanel
    
    local RightPanel = Instance.new("Frame")
    RightPanel.Name = "RightPanel"
    RightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 31)
    RightPanel.BorderSizePixel = 0
    RightPanel.Position = UDim2.new(0.67, 2, 0, 5)
    RightPanel.Size = UDim2.new(0.33, -7, 1, -10)
    RightPanel.ZIndex = 10
    table.insert(shade1, RightPanel)
    RightPanel.Parent = ContentFrame
    
    local RightCorner = Instance.new("UICorner")
    RightCorner.CornerRadius = UDim.new(0, 6)
    RightCorner.Parent = RightPanel
    
    CreateLabel(LeftPanel, "BasePart A", 5)
    ViewportA, CameraA = CreateViewport(LeftPanel, 25, 180)
    CreateGrid(ViewportA, 20, 5)
    CreateAxes(ViewportA, 8)
    
    CreateLabel(RightPanel, "BasePart B", 5)
    ViewportB, CameraB = CreateViewport(RightPanel, 25, 180)
    CreateGrid(ViewportB, 20, 5)
    CreateAxes(ViewportB, 8)
    
    CreateLabel(CenterPanel, "Combined Preview", 5)
    ViewportCombined, CameraCombined = CreateViewport(CenterPanel, 25, 250)
    CreateGrid(ViewportCombined, 30, 8)
    CreateAxes(ViewportCombined, 10)
    
    CreatePathInput(LeftPanel, "Path / Selection:", 215, function(part, pathBox)
        SelectedA = part
        pathBox.Text = GetFullPath(part)
        SelectionBoxA.Adornee = part
        UpdateViewportSingle(ViewportA, CameraA, part, Color3.fromRGB(255, 100, 100))
        UpdateCombinedViewport()
    end, SelectionBoxA)
    
    CreatePathInput(RightPanel, "Path / Selection:", 215, function(part, pathBox)
        SelectedB = part
        pathBox.Text = GetFullPath(part)
        SelectionBoxB.Adornee = part
        UpdateViewportSingle(ViewportB, CameraB, part, Color3.fromRGB(100, 100, 255))
        UpdateCombinedViewport()
    end, SelectionBoxB)
    
    CreateLabel(CenterPanel, "Viewport Settings", 285)
    CreateToggle(CenterPanel, "Auto Rotate Camera", 305, true, function(state)
        AutoRotateEnabled = state
    end)
    
    CreateLabel(CenterPanel, "Weld Settings", 335)
    CreateToggle(CenterPanel, "Use Hidden Velocity", 355, true, function(state)
        UseHiddenVelocity = state
    end)
    
    CreateLabel(LeftPanel, "Position Offset", 295)
    CreateSlider(LeftPanel, "X:", -20, 20, 315, function(v) OffsetX = v end)
    CreateSlider(LeftPanel, "Y:", -20, 20, 350, function(v) OffsetY = v end)
    CreateSlider(LeftPanel, "Z:", -20, 20, 385, function(v) OffsetZ = v end)
    
    CreateLabel(RightPanel, "Rotation Offset", 295)
    CreateSlider(RightPanel, "RX:", -180, 180, 315, function(v) AngleX = v end)
    CreateSlider(RightPanel, "RY:", -180, 180, 350, function(v) AngleY = v end)
    CreateSlider(RightPanel, "RZ:", -180, 180, 385, function(v) AngleZ = v end)
    
    local ApplyWeldBtn = Instance.new("TextButton")
    ApplyWeldBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    ApplyWeldBtn.BorderSizePixel = 0
    ApplyWeldBtn.Position = UDim2.new(0, 10, 0, 390)
    ApplyWeldBtn.Size = UDim2.new(0.48, -15, 0, 35)
    ApplyWeldBtn.Font = Enum.Font.SourceSansBold
    ApplyWeldBtn.TextSize = 14
    ApplyWeldBtn.Text = "Apply Weld"
    ApplyWeldBtn.TextColor3 = Color3.new(1, 1, 1)
    ApplyWeldBtn.ZIndex = 10
    table.insert(shade3, ApplyWeldBtn)
    table.insert(text1, ApplyWeldBtn)
    ApplyWeldBtn.Parent = CenterPanel
    
    local ApplyCorner = Instance.new("UICorner")
    ApplyCorner.CornerRadius = UDim.new(0, 6)
    ApplyCorner.Parent = ApplyWeldBtn
    
    local StopWeldBtn = Instance.new("TextButton")
    StopWeldBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    StopWeldBtn.BorderSizePixel = 0
    StopWeldBtn.Position = UDim2.new(0.52, 0, 0, 390)
    StopWeldBtn.Size = UDim2.new(0.48, -10, 0, 35)
    StopWeldBtn.Font = Enum.Font.SourceSansBold
    StopWeldBtn.TextSize = 14
    StopWeldBtn.Text = "Stop Weld"
    StopWeldBtn.TextColor3 = Color3.new(1, 1, 1)
    StopWeldBtn.ZIndex = 10
    table.insert(shade3, StopWeldBtn)
    table.insert(text1, StopWeldBtn)
    StopWeldBtn.Parent = CenterPanel
    
    local StopCorner = Instance.new("UICorner")
    StopCorner.CornerRadius = UDim.new(0, 6)
    StopCorner.Parent = StopWeldBtn
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 10, 0, 430)
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextSize = 12
    StatusLabel.Text = "Status: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.ZIndex = 10
    table.insert(text1, StatusLabel)
    StatusLabel.Parent = CenterPanel
    
    ApplyWeldBtn.MouseButton1Click:Connect(function()
        if not SelectedA or not SelectedB then
            StatusLabel.Text = "Status: Select both parts!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        if WeldConnection then
            WeldConnection:Disconnect()
        end
        
        local Offset = CFrame.new(OffsetX, OffsetY, OffsetZ) * CFrame.Angles(math.rad(AngleX), math.rad(AngleY), math.rad(AngleZ))
        
        WeldConnection = RunService.Heartbeat:Connect(function()
            if not SelectedA or not SelectedB then return end
            if not SelectedA.Parent or not SelectedB.Parent then return end
            
            pcall(function()
                sethiddenproperty(SelectedA, "PhysicsRepRootPart", SelectedB)
            end)
            
            SelectedA.CFrame = SelectedB.CFrame * Offset
            SelectedA.AssemblyLinearVelocity = Vector3.zero
            SelectedA.AssemblyAngularVelocity = Vector3.zero
            
            if UseHiddenVelocity then
                pcall(function()
                    sethiddenproperty(SelectedA, "Velocity", SelectedB)
                    sethiddenproperty(SelectedA, "RotVelocity", SelectedB)
                end)
            end
        end)
        
        StatusLabel.Text = "Status: Welding Active"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    StopWeldBtn.MouseButton1Click:Connect(function()
        if WeldConnection then
            WeldConnection:Disconnect()
            WeldConnection = nil
        end
        
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end)
    
    RunService.RenderStepped:Connect(function(dt)
        if AutoRotateEnabled and WelderUI.Visible then
            RotationAngle = RotationAngle + dt * 30
            
            local function RotateCamera(camera, target, distance)
                if not target then return end
                local Center = target.Position or Vector3.zero
                local Offset = CFrame.Angles(0, math.rad(RotationAngle), 0) * Vector3.new(distance, distance * 0.7, distance)
                camera.CFrame = CFrame.new(Center + Offset, Center)
            end
            
            if ViewportA:FindFirstChild("PreviewPart") then
                local Part = ViewportA:FindFirstChild("PreviewPart")
                RotateCamera(CameraA, Part, Part.Size.Magnitude * 1.5)
            end
            
            if ViewportB:FindFirstChild("PreviewPart") then
                local Part = ViewportB:FindFirstChild("PreviewPart")
                RotateCamera(CameraB, Part, Part.Size.Magnitude * 1.5)
            end
            
            local MaxSize = 5
            if SelectedA then MaxSize = math.max(MaxSize, SelectedA.Size.Magnitude) end
            if SelectedB then MaxSize = math.max(MaxSize, SelectedB.Size.Magnitude) end
            
            local Center = Vector3.new(0, MaxSize / 3, 0)
            local Offset = CFrame.Angles(0, math.rad(RotationAngle), 0) * Vector3.new(MaxSize * 2, MaxSize, MaxSize * 2)
            CameraCombined.CFrame = CFrame.new(Center + Offset, Center)
        end
    end)
    
    local Dragging = false
    local DragStart, StartPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = WelderUI.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            WelderUI.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

Plugin.Commands.advwelder = {
    ListName = "advwelder",
    Description = "Open Advanced Welder GUI with PhysicsRepRootPart",
    Aliases = {"awelder", "welder3d"},
    Function = function(args, speaker)
        if not WelderUI then
            InitializeUI()
        end
        WelderUI.Visible = true
    end
}

return Plugin