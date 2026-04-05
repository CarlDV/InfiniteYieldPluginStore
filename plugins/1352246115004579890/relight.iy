local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain
local DebrisService = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Input = game:GetService("UserInputService")
local FolderPath = "LightingFiles"
local FilePath = FolderPath .. "/"
local ScrollingFrame

local Properties = {
    Lighting = { "Ambient", "Brightness", "ClockTime", "ColorShift_Bottom", "ColorShift_Top", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "ExposureCompensation", "FogColor", "FogEnd", "FogStart", "GeographicLatitude", "GlobalShadows", "OutdoorAmbient", "ShadowSoftness", "TimeOfDay" },
    Atmosphere = { "Color", "Decay", "Density", "Glare", "Haze", "Offset" },
    Sky = { "CelestialBodiesShown", "MoonAngularSize", "MoonTextureId", "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "StarCount", "SunAngularSize", "SunTextureId" },
    ColorCorrectionEffect = { "Brightness", "Contrast", "Saturation", "TintColor", "Enabled" },
    BloomEffect = { "Intensity", "Size", "Threshold", "Enabled" },
    BlurEffect = { "Size", "Enabled" },
    SunRaysEffect = { "Intensity", "Spread", "Enabled" },
    Terrain = { "WaterColor", "WaterReflectance", "WaterTransparency", "WaterWaveSize", "WaterWaveSpeed" },
    Clouds = { "Color", "Cover", "Density", "Enabled" }
}

if not isfolder(FolderPath) then
    makefolder(FolderPath)
end

local function LoadLightingProperties(FileName)
    FileName = FileName:gsub("%.txt$", "")

    if isfile(FilePath .. FileName .. ".txt") then
        local FileContent = readfile(FilePath .. FileName .. ".txt")
        loadstring(FileContent)()
        notify("Success", "Graphics properties loaded from " .. FileName .. ".txt")
    else
        notify("File Not Found", "The file " .. FileName .. " does not exist.")
    end
end

local function AddButton(FilePath)
    if not ScrollingFrame then
        return
    end

    local FileName = FilePath:match("([^/\\]+)%.txt$") or FilePath
    local TextButton = Instance.new("TextButton")
    TextButton.Size = UDim2.new(1, 0, 0, 0)
    TextButton.BackgroundTransparency = 0
    TextButton.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    TextButton.Text = ""
    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.TextSize = 14
    TextButton.BorderSizePixel = 0
    TextButton.Font = Enum.Font.SourceSans
    TextButton.AnchorPoint = Vector2.new(0.5, 0)
    TextButton.Position = UDim2.new(0.5, 0, 0, 0)
    TextButton.Parent = ScrollingFrame

    local ButtonTween = TweenService:Create(
        TextButton,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        { Size = UDim2.new(1, 0, 0, 25) }
    )
    ButtonTween:Play()

    ButtonTween.Completed:Connect(function()
        for Index = 1, #FileName do
            TextButton.Text = FileName:sub(1, Index)
            task.wait(0.05)
        end
    end)

    TextButton.MouseButton1Click:Connect(function()
        LoadLightingProperties(FileName)

        local AnimationFrame = Instance.new("Frame")
        AnimationFrame.Size = UDim2.new(0, 0, 1, 0)
        AnimationFrame.Position = UDim2.new(0.5, 0, 0, 0)
        AnimationFrame.AnchorPoint = Vector2.new(0.5, 0)
        AnimationFrame.BackgroundColor3 = Color3.fromRGB(66, 66, 67)
        AnimationFrame.BackgroundTransparency = 0
        AnimationFrame.BorderSizePixel = 0
        AnimationFrame.Parent = TextButton

        local AnimationTween = TweenService:Create(
            AnimationFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }
        )
        AnimationTween:Play()

        AnimationTween.Completed:Connect(function()
            DebrisService:AddItem(AnimationFrame, 0)
        end)
    end)
end


local function SaveLightingProperties(FileName)
    local FileContent = "local Lighting = game:GetService(\"Lighting\")\nlocal Terrain = workspace.Terrain\n\n"

    FileContent = FileContent .. "for _, Child in pairs(Lighting:GetChildren()) do\n"
    FileContent = FileContent .. "    if Child:IsA(\"Atmosphere\") or Child:IsA(\"Sky\") or Child:IsA(\"ColorCorrectionEffect\") or Child:IsA(\"BloomEffect\") or Child:IsA(\"BlurEffect\") or Child:IsA(\"SunRaysEffect\") then\n"
    FileContent = FileContent .. "        Child:Destroy()\n"
    FileContent = FileContent .. "    end\n"
    FileContent = FileContent .. "end\n\n"

    FileContent = FileContent .. "for _, Child in pairs(Terrain:GetChildren()) do\n"
    FileContent = FileContent .. "    if Child:IsA(\"Clouds\") then\n"
    FileContent = FileContent .. "        Child:Destroy()\n"
    FileContent = FileContent .. "    end\n"
    FileContent = FileContent .. "end\n\n"

    for _, PropertyName in ipairs(Properties.Lighting) do
        local PropertyValue = Lighting[PropertyName]
        if typeof(PropertyValue) == "string" then
            FileContent = FileContent .. string.format("Lighting.%s = \"%s\"\n", PropertyName, PropertyValue)
        elseif typeof(PropertyValue) == "Color3" then
            FileContent = FileContent .. string.format("Lighting.%s = Color3.fromRGB(%g, %g, %g)\n", PropertyName, math.floor(PropertyValue.R * 255), math.floor(PropertyValue.G * 255), math.floor(PropertyValue.B * 255))
        elseif typeof(PropertyValue) == "number" then
            FileContent = FileContent .. string.format("Lighting.%s = %g\n", PropertyName, PropertyValue)
        else
            FileContent = FileContent .. string.format("Lighting.%s = %s\n", PropertyName, tostring(PropertyValue))
        end
    end

    local LightingTechnology = gethiddenproperty(Lighting, "Technology")
    FileContent = FileContent .. string.format("\nsethiddenproperty(Lighting, \"Technology\", %s)\n\n", tostring(LightingTechnology))

    for _, PropertyName in ipairs(Properties.Terrain) do
        local PropertyValue = Terrain[PropertyName]
        if typeof(PropertyValue) == "string" then
            FileContent = FileContent .. string.format("Terrain.%s = \"%s\"\n", PropertyName, PropertyValue)
        elseif typeof(PropertyValue) == "Color3" then
            FileContent = FileContent .. string.format("Terrain.%s = Color3.fromRGB(%g, %g, %g)\n", PropertyName, math.floor(PropertyValue.R * 255), math.floor(PropertyValue.G * 255), math.floor(PropertyValue.B * 255))
        elseif typeof(PropertyValue) == "number" then
            FileContent = FileContent .. string.format("Terrain.%s = %g\n", PropertyName, PropertyValue)
        else
            FileContent = FileContent .. string.format("Terrain.%s = %s\n", PropertyName, tostring(PropertyValue))
        end
    end

    local TerrainDecoration = gethiddenproperty(Terrain, "Decoration")
    FileContent = FileContent .. string.format("\nsethiddenproperty(Terrain, \"Decoration\", %s)\n", tostring(TerrainDecoration))

    local TerrainGrassLength = gethiddenproperty(Terrain, "GrassLength")
    FileContent = FileContent .. string.format("sethiddenproperty(Terrain, \"GrassLength\", %g)\n\n", TerrainGrassLength)

    local Materials = {}
    
    for _, Material in ipairs(Enum.Material:GetEnumItems()) do
        pcall(function()
            local MaterialColor = Terrain:GetMaterialColor(Material)
            if MaterialColor then
                Materials[Material] = MaterialColor
            end
        end)
    end
    
    local InstanceCount = {}
    
    for _, Child in ipairs(Terrain:GetChildren()) do
        local ClassName = Child.ClassName
        if Properties[ClassName] then
            InstanceCount[ClassName] = (InstanceCount[ClassName] or 0) + 1
            local InstanceName = ClassName .. (InstanceCount[ClassName] > 1 and InstanceCount[ClassName] or "")
            FileContent = FileContent .. string.format("\nlocal %s = Instance.new(\"%s\")\n", InstanceName, ClassName)
            for _, PropertyName in ipairs(Properties[ClassName]) do
                local PropertyValue = Child[PropertyName]
                if typeof(PropertyValue) == "string" then
                    FileContent = FileContent .. string.format("%s.%s = \"%s\"\n", InstanceName, PropertyName, PropertyValue)
                elseif typeof(PropertyValue) == "Color3" then
                    FileContent = FileContent .. string.format("%s.%s = Color3.fromRGB(%g, %g, %g)\n", InstanceName, PropertyName, math.floor(PropertyValue.R * 255), math.floor(PropertyValue.G * 255), math.floor(PropertyValue.B * 255))
                elseif typeof(PropertyValue) == "number" then
                    FileContent = FileContent .. string.format("%s.%s = %g\n", InstanceName, PropertyName, PropertyValue)
                else
                    FileContent = FileContent .. string.format("%s.%s = %s\n", InstanceName, PropertyName, tostring(PropertyValue))
                end
            end
            FileContent = FileContent .. string.format("%s.Parent = Terrain\n", InstanceName)
        end
    end

    for _, Child in ipairs(Lighting:GetChildren()) do
        local ClassName = Child.ClassName
        if Properties[ClassName] then
            InstanceCount[ClassName] = (InstanceCount[ClassName] or 0) + 1
            local InstanceName = ClassName .. (InstanceCount[ClassName] > 1 and InstanceCount[ClassName] or "")
            FileContent = FileContent .. string.format("\nlocal %s = Instance.new(\"%s\")\n", InstanceName, ClassName)
            for _, PropertyName in ipairs(Properties[ClassName]) do
                local PropertyValue = Child[PropertyName]
                if typeof(PropertyValue) == "string" then
                    FileContent = FileContent .. string.format("%s.%s = \"%s\"\n", InstanceName, PropertyName, PropertyValue)
                elseif typeof(PropertyValue) == "Color3" then
                    FileContent = FileContent .. string.format("%s.%s = Color3.fromRGB(%g, %g, %g)\n", InstanceName, PropertyName, math.floor(PropertyValue.R * 255), math.floor(PropertyValue.G * 255), math.floor(PropertyValue.B * 255))
                elseif typeof(PropertyValue) == "number" then
                    FileContent = FileContent .. string.format("%s.%s = %g\n", InstanceName, PropertyName, PropertyValue)
                else
                    FileContent = FileContent .. string.format("%s.%s = %s\n", InstanceName, PropertyName, tostring(PropertyValue))
                end
            end
            FileContent = FileContent .. string.format("%s.Parent = Lighting\n", InstanceName)
        end
    end
    
    FileContent = FileContent .. "\n"
    
    for MaterialEnum, MaterialColor in pairs(Materials) do
        FileContent = FileContent .. string.format("Terrain:SetMaterialColor(Enum.Material.%s, Color3.fromRGB(%g, %g, %g))\n", MaterialEnum.Name, math.floor(MaterialColor.R * 255), math.floor(MaterialColor.G * 255), math.floor(MaterialColor.B * 255))
    end
    
    if ScrollingFrame then
        AddButton(FileName .. ".txt")
    end
    
    writefile(FilePath .. FileName .. ".txt", FileContent)
end

local function CreateFileListingGui(Files)
    local ExistingGui = PlayerGui:FindFirstChild("FileListingGui")
    if ExistingGui then
        DebrisService:AddItem(ExistingGui, 0)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FileListingGui"
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
    TopBar.Parent = MainFrame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, 0, 0.5, 0)
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = ""
    CloseButton.Parent = TopBar

    local CloseImage = Instance.new("ImageLabel")
    CloseImage.Parent = CloseButton
    CloseImage.BackgroundColor3 = Color3.new(1, 1, 1)
    CloseImage.BackgroundTransparency = 1
    CloseImage.Position = UDim2.new(0, 5, 0, 5)
    CloseImage.Size = UDim2.new(0, 10, 0, 10)
    CloseImage.Image = "rbxassetid://5054663650"
    CloseImage.ZIndex = 10

    ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -10, 1, -30)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 25)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.ScrollBarThickness = 0
    ScrollingFrame.VerticalScrollBarInset = "Always"
    ScrollingFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollingFrame
    
    local FrameTween = TweenService:Create(
        MainFrame,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(0.4, 0, 0.6, 0) }
    )
    FrameTween:Play()
    task.wait(0.75)

    for _, FilePath in ipairs(Files) do
        if FilePath:match("%.txt$") then
            AddButton(FilePath)
            task.wait(0.1)
        end
    end

    CloseButton.MouseButton1Down:Connect(function()
        DebrisService:AddItem(ScreenGui, 0)
        ScrollingFrame = nil
    end)

    local Dragging = false
    local DragStart = nil
    local StartPos = nil

    local function UpdatePosition(Input)
        local Delta = Input.Position - DragStart
        local TargetPos = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
        MainFrame.Position = TargetPos
    end

    local function BeginDrag(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = MainFrame.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end

    TopBar.InputBegan:Connect(BeginDrag)
    MainFrame.InputBegan:Connect(BeginDrag)

    Input.InputChanged:Connect(function(Input)
        if Dragging then
            UpdatePosition(Input)
        end
    end)
end

local Plugin = {
    ["PluginName"] = "Re:Light",
    ["PluginDescription"] = "The power to save and load graphics.",
    ["Commands"] = {
        ["savegraphics"] = {
            ["ListName"] = "savegraphics / saveg / sg [FileName]",
            ["Description"] = "Saves the lighting, terrain properties, and material colors to a file with the given filename.",
            ["Aliases"] = {"savegraphics", "saveg", "sg"},
            ["Function"] = function(args, speaker)
                local FileName = args[1]
                if FileName then
                    local Success, ErrorMessage = pcall(function()
                        SaveLightingProperties(FileName)
                        notify("Success", "Graphics properties saved to " .. FileName .. ".txt")
                    end)
                    if not Success then
                        notify("Error", ErrorMessage)
                    end
                else
                    notify("Error", "Please provide a file name.")
                end
            end
        },
        ["loadgraphics"] = {
            ["ListName"] = "loadgraphics / loadg / lg [FileName]",
            ["Description"] = "Loads the graphics properties from a saved file.",
            ["Aliases"] = {"loadgraphics", "loadg", "lg"},
            ["Function"] = function(args, speaker)
                local FileName = args[1]
                if FileName then
                    local Success, ErrorMessage = pcall(function()
                        LoadLightingProperties(FileName)
                    end)
                    if not Success then
                        notify("Error", "Failed to load graphics properties: " .. ErrorMessage)
                    end
                else
                    notify("Error", "Please provide a file name.")
                end
            end
        },
        ["listfiles"] = {
            ["ListName"] = "listfiles / lf",
            ["Description"] = "Lists all files in the LightingFiles directory without extensions in a GUI.",
            ["Aliases"] = {"listfiles", "lf"},
            ["Function"] = function(args, speaker)
                local Success, ErrorMessage = pcall(function()
                    local Files = listfiles(FolderPath)
                    if #Files > 0 then
                        CreateFileListingGui(Files)
                        notify("Success", "Files listed from the LightingFiles directory.")
                    else
                        notify("Error", "No files found in the LightingFiles directory.")
                    end
                end)
                if not Success then
                    notify("Error", ErrorMessage)
                end
            end
        }

    }
}

return Plugin


