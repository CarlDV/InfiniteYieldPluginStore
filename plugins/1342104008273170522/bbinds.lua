local config = {
    BUTTON_SIZE = 100,   -- change button size in pixels
    TEXT_SIZE = 'SCALED' -- set the text size, 'SCALED' or a number
}

local players = game:GetService('Players')
local runService = game:GetService('RunService')
local httpService = game:GetService('HttpService')

local player = players.LocalPlayer
local mouse = player:GetMouse()

local function randomString()
    local str = ''
    for _ = 1, math.random(5, 10) do
        str ..= string.char(math.random(33, 126))
    end

    return str
end

local editing = false
local gui = Instance.new('ScreenGui', PARENT)
gui.Name = randomString()

local function load()
    if not isfile then
        return {}
    end

    if isfile('IY_BBINDS') then
        local data = readfile('IY_BBINDS')
        local buttons = {}
        local success, _ = pcall(function()
            data = httpService:JSONDecode(data)
            for _, button in pairs(data) do
                assert(button.text)
                assert(button.cmd)
                assert(button.pos and button.pos[1] and button.pos[2])

                buttons[#buttons+1] = {text = button.text, cmd = button.cmd, cmd2 = button.cmd2, pos = button.pos}
            end
        end)

        if not success then
            notify('BBinds', 'Failed to load binds properly')
        else
            return buttons
        end
    end

    return {}
end

local buttons = {}
local function save()
    if not writefile then
        return
    end

    local data = httpService:JSONEncode(buttons)
    local success, _ = pcall(function()
        writefile('IY_BBINDS', data)
    end)

    if not success then
        notify('BBinds', 'Failed to save binds properly')
    end
end

SettingsHolder.CanvasSize = UDim2.fromOffset(0, 265)
local bbinds = makeSettingsButton("Edit BBinds","rbxassetid://129697930")
bbinds.Position = UDim2.new(0, 5, 0, 235)
bbinds.Size = UDim2.new(1, -10, 0, 25)
bbinds.Name = "BBinds"
bbinds.Parent = SettingsHolder
bbinds.BackgroundColor3 = currentShade2
bbinds.ButtonLabel.TextColor3 = currentText1

local BBindsFrame = Instance.new('Frame')
BBindsFrame.Name = "BBindsFrame"
BBindsFrame.Parent = Settings
BBindsFrame.Active = true
BBindsFrame.BackgroundColor3 = currentShade1
BBindsFrame.BorderSizePixel = 0
BBindsFrame.Position = UDim2.new(0, 0, 0, 175)
BBindsFrame.Size = UDim2.new(0, 250, 0, 175)
BBindsFrame.ZIndex = 10
table.insert(shade1,BBindsFrame)

local Close = Instance.new('TextButton')
Close.Name = "Close"
Close.Parent = BBindsFrame
Close.BackgroundColor3 = currentShade2
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 205, 0, 150)
Close.Size = UDim2.new(0, 40, 0, 20)
Close.Font = Enum.Font.SourceSans
Close.TextSize = 14
Close.Text = "Close"
Close.TextColor3 = currentText1
Close.ZIndex = 10
table.insert(shade2,Close)
table.insert(text1,Close)

local Add = Instance.new('TextButton')
Add.Name = "Add"
Add.Parent = BBindsFrame
Add.BackgroundColor3 = currentShade2
Add.BorderSizePixel = 0
Add.Position = UDim2.new(0, 5, 0, 150)
Add.Size = UDim2.new(0, 40, 0, 20)
Add.Font = Enum.Font.SourceSans
Add.TextSize = 14
Add.Text = "Add"
Add.TextColor3 = currentText1
Add.ZIndex = 10
table.insert(shade2,Add)
table.insert(text1,Add)

local EditMode = Instance.new('TextButton')
EditMode.Name = "Edit"
EditMode.Parent = BBindsFrame
EditMode.BackgroundColor3 = currentShade2
EditMode.BorderSizePixel = 0
EditMode.Position = UDim2.new(0, 95, 0, 150)
EditMode.Size = UDim2.new(0, 70, 0, 20)
EditMode.Font = Enum.Font.SourceSans
EditMode.TextSize = 14
EditMode.Text = "Edit mode"
EditMode.TextColor3 = currentText1
EditMode.ZIndex = 10
table.insert(shade2,EditMode)
table.insert(text1,EditMode)

local Delete = Instance.new('TextButton')
Delete.Name = "Delete"
Delete.Parent = BBindsFrame
Delete.BackgroundColor3 = currentShade2
Delete.BorderSizePixel = 0
Delete.Position = UDim2.new(0, 50, 0, 150)
Delete.Size = UDim2.new(0, 40, 0, 20)
Delete.Font = Enum.Font.SourceSans
Delete.TextSize = 14
Delete.Text = "Clear"
Delete.TextColor3 = currentText1
Delete.ZIndex = 10
table.insert(shade2,Delete)
table.insert(text1,Delete)

local Holder_2 = Instance.new('ScrollingFrame')
Holder_2.Name = "Holder"
Holder_2.Parent = BBindsFrame
Holder_2.BackgroundTransparency = 1
Holder_2.BorderSizePixel = 0
Holder_2.Position = UDim2.new(0, 0, 0, 0)
Holder_2.Size = UDim2.new(0, 250, 0, 145)
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.ScrollBarThickness = 0
Holder_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.VerticalScrollBarInset = 'Always'
Holder_2.ZIndex = 10

local Example_2 = Instance.new('Frame')
Example_2.Name = "Example"
Example_2.Parent = BBindsFrame
Example_2.BackgroundColor3 = currentShade2
Example_2.BorderSizePixel = 0
Example_2.Size = UDim2.new(0, 10, 0, 20)
Example_2.Visible = false
Example_2.ZIndex = 10
table.insert(shade2,Example_2)

local Text_3 = Instance.new('TextLabel')
Text_3.Name = "Text"
Text_3.Parent = Example_2
Text_3.BackgroundColor3 = currentShade2
Text_3.BorderSizePixel = 0
Text_3.Position = UDim2.new(0, 10, 0, 0)
Text_3.Size = UDim2.new(0, 240, 0, 20)
Text_3.Font = Enum.Font.SourceSans
Text_3.TextSize = 14
Text_3.Text = "nom"
Text_3.TextColor3 = currentText1
Text_3.TextXAlignment = Enum.TextXAlignment.Left
Text_3.ZIndex = 10
table.insert(shade2,Text_3)
table.insert(text1,Text_3)

local Delete_2 = Instance.new('TextButton')
Delete_2.Name = "Delete"
Delete_2.Parent = Text_3
Delete_2.BackgroundColor3 = currentShade3
Delete_2.BorderSizePixel = 0
Delete_2.Position = UDim2.new(0, 200, 0, 0)
Delete_2.Size = UDim2.new(0, 40, 0, 20)
Delete_2.Font = Enum.Font.SourceSans
Delete_2.TextSize = 14
Delete_2.Text = "Delete"
Delete_2.TextColor3 = currentText2
Delete_2.ZIndex = 10
table.insert(shade3,Delete_2)
table.insert(text2,Delete_2)

local BBindsGui = Instance.new("Frame")
local background = Instance.new("Frame")
local Add_1 = Instance.new("TextButton")
local CreateToggle = Instance.new("TextLabel")
local Button = Instance.new("Frame")
local On = Instance.new("TextButton")
local Cmdbar_2 = Instance.new("Frame")
local Input = Instance.new("TextBox")
local Cmdbar_3 = Instance.new("Frame")
local Input_2 = Instance.new("TextBox")
local Text = Instance.new("Frame")
local Input_3 = Instance.new("TextBox")
local shadow = Instance.new("Frame")
local PopupText_2 = Instance.new("TextLabel")
local Exit_2 = Instance.new("TextButton")
local ImageLabel = Instance.new("ImageLabel")

BBindsGui.Name = "BBindsGeui"
BBindsGui.Parent = PARENT
BBindsGui.Active = true
BBindsGui.BackgroundTransparency = 1.000
BBindsGui.Position = UDim2.new(0.5, -110, 0, -500)
BBindsGui.Size = UDim2.new(0, 220, 0, 20)
BBindsGui.ZIndex = 10
dragGUI(BBindsGui)

background.Name = "background"
background.Parent = BBindsGui
background.Active = true
background.BackgroundColor3 = currentShade1
background.BorderSizePixel = 0
background.Position = UDim2.new(0, 0, 0, 20)
background.Size = UDim2.new(0, 220, 0, 125)
background.ZIndex = 10
table.insert(shade1, background)

Add_1.Name = "Add"
Add_1.Parent = background
Add_1.BackgroundColor3 = currentShade2
Add_1.BorderSizePixel = 0
Add_1.Position = UDim2.new(0, 168, 0, 70)
Add_1.Size = UDim2.new(0, 40, 0, 20)
Add_1.ZIndex = 10
Add_1.Font = Enum.Font.SourceSans
Add_1.Text = "Add"
Add_1.TextColor3 = currentText1
Add_1.TextSize = 14.000
table.insert(shade2,Add_1)
table.insert(text1,Add_1)

CreateToggle.Name = "CreateToggle"
CreateToggle.Parent = background
CreateToggle.BackgroundTransparency = 1.000
CreateToggle.BorderSizePixel = 0
CreateToggle.Position = UDim2.new(0, 10, 0, 45)
CreateToggle.Size = UDim2.new(0, 198, 0, 20)
CreateToggle.ZIndex = 10
CreateToggle.Font = Enum.Font.SourceSans
CreateToggle.Text = "Create Toggle"
CreateToggle.TextColor3 = currentText1
CreateToggle.TextSize = 14.000
CreateToggle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,CreateToggle)

Button.Name = "Button"
Button.Parent = CreateToggle
Button.BackgroundColor3 = currentShade3
Button.BorderSizePixel = 0
Button.Position = UDim2.new(1, -20, 0, 0)
Button.Size = UDim2.new(0, 20, 0, 20)
Button.ZIndex = 10
table.insert(shade3,Button)

On.Name = "On"
On.Parent = Button
On.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On.BackgroundTransparency = 1.000
On.BorderSizePixel = 0
On.Position = UDim2.new(0, 2, 0, 2)
On.Size = UDim2.new(0, 16, 0, 16)
On.ZIndex = 10
On.Font = Enum.Font.SourceSans
On.Text = ""
On.TextColor3 = Color3.fromRGB(0, 0, 0)
On.TextSize = 14.000

Cmdbar_2.Name = "Cmdbar_2"
Cmdbar_2.Parent = background
Cmdbar_2.BackgroundColor3 = currentShade2
Cmdbar_2.BorderSizePixel = 0
Cmdbar_2.ClipsDescendants = true
Cmdbar_2.Position = UDim2.new(0, 10, 0, 70)
Cmdbar_2.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_2.ZIndex = 10
table.insert(shade2, Cmdbar_2)

Input.Name = "Input"
Input.Parent = Cmdbar_2
Input.BackgroundTransparency = 1.000
Input.BorderSizePixel = 0
Input.Position = UDim2.new(0, 2, 0, 0)
Input.Size = UDim2.new(1, -8, 1, 0)
Input.ZIndex = 10
Input.Font = Enum.Font.SourceSans
Input.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
Input.PlaceholderText = "Command"
Input.Text = ""
Input.TextColor3 = currentText1
Input.TextSize = 14.000
Input.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1, Input)

Cmdbar_3.Name = "Cmdbar_3"
Cmdbar_3.Parent = background
Cmdbar_3.BackgroundColor3 = currentShade2
Cmdbar_3.BorderSizePixel = 0
Cmdbar_3.ClipsDescendants = true
Cmdbar_3.Position = UDim2.new(0, 10, 0, 95)
Cmdbar_3.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_3.Visible = false
Cmdbar_3.ZIndex = 10
table.insert(shade2, Cmdbar_3)

Input_2.Name = "Input"
Input_2.Parent = Cmdbar_3
Input_2.BackgroundTransparency = 1.000
Input_2.BorderSizePixel = 0
Input_2.Position = UDim2.new(0, 2, 0, 0)
Input_2.Size = UDim2.new(1, -8, 1, 0)
Input_2.ZIndex = 10
Input_2.Font = Enum.Font.SourceSans
Input_2.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
Input_2.PlaceholderText = "Command 2"
Input_2.Text = ""
Input_2.TextColor3 = currentText1
Input_2.TextSize = 14.000
Input_2.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1, Input_2)

Text.Name = "Text"
Text.Parent = background
Text.BackgroundColor3 = currentShade2
Text.BorderSizePixel = 0
Text.ClipsDescendants = true
Text.Position = UDim2.new(0, 10, 0, 10)
Text.Size = UDim2.new(0, 200, 0, 20)
Text.ZIndex = 10
table.insert(shade2, Text)

Input_3.Name = "Input"
Input_3.Parent = Text
Input_3.BackgroundTransparency = 1.000
Input_3.BorderSizePixel = 0
Input_3.Position = UDim2.new(0, 2, 0, 0)
Input_3.Size = UDim2.new(1, -8, 1, 0)
Input_3.ZIndex = 10
Input_3.Font = Enum.Font.SourceSans
Input_3.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
Input_3.PlaceholderText = "Text"
Input_3.Text = ""
Input_3.TextColor3 = currentText1
Input_3.TextSize = 14.000
Input_3.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1, Input_3)

shadow.Name = "shadow"
shadow.Parent = BBindsGui
shadow.BackgroundColor3 = currentShade2
shadow.BorderSizePixel = 0
shadow.Size = UDim2.new(0, 220, 0, 20)
shadow.ZIndex = 10
table.insert(shade2,shadow)

PopupText_2.Name = "PopupText_2"
PopupText_2.Parent = shadow
PopupText_2.BackgroundTransparency = 1.000
PopupText_2.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText_2.ZIndex = 10
PopupText_2.Font = Enum.Font.SourceSans
PopupText_2.Text = "Set BBinds"
PopupText_2.TextColor3 = currentText1
PopupText_2.TextSize = 14.000
PopupText_2.TextWrapped = true
table.insert(text1,PopupText_2)

Exit_2.Name = "Exit_2"
Exit_2.Parent = shadow
Exit_2.BackgroundTransparency = 1.000
Exit_2.Position = UDim2.new(1, -20, 0, 0)
Exit_2.Size = UDim2.new(0, 20, 0, 20)
Exit_2.ZIndex = 10
Exit_2.Text = ""

ImageLabel.Parent = Exit_2
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.Position = UDim2.new(0, 5, 0, 5)
ImageLabel.Size = UDim2.new(0, 10, 0, 10)
ImageLabel.ZIndex = 10
ImageLabel.Image = "rbxassetid://5054663650"

local function removeButton(index)
    local button = buttons[index]
    button.label:Destroy()
    button.gui:Destroy()

    notify('BBinds', `The BBind {button.text} has been removed`)
    save()

    table.remove(buttons, index)
end

local function refreshButtons()
    Holder_2:ClearAllChildren()
    Holder_2.CanvasSize = UDim2.fromOffset(0, 10)
    for index, button in ipairs(buttons) do
        local position = ((index-1) * 25)
        Holder_2.CanvasSize = UDim2.new(0,0,0, position + 30)

        local label = Example_2:Clone()
        label.Parent = Holder_2
        label.Position = UDim2.fromOffset(0, position + 5)
        label.Visible = true
        table.insert(shade2, label)

        label.Text.Text = `{button.text} > {button.cmd}{(button.cmd2 and ' / '..button.cmd2) or ''}`
        table.insert(shade2, label.Text)
        table.insert(text1, label.Text)

        label.Text.Delete.MouseButton1Click:Connect(function()
            removeButton(index)
            refreshButtons()
        end)
        table.insert(shade3, label.Text.Delete)
        table.insert(text2, label.Text.Delete)

        button.label = label
    end
end

local function createButton(options)
    local button = Instance.new('TextButton', gui)
    button.BackgroundColor3 = currentShade1
    button.TextColor3 = currentText1
    button.BorderSizePixel = 0
    button.Size = UDim2.fromOffset(config.BUTTON_SIZE, config.BUTTON_SIZE)
    button.Text = options.text

    button.Position = UDim2.fromScale(options.pos[1], options.pos[2])
    if config.TEXT_SIZE == 'SCALED' then
        button.TextScaled = true
    end
    button.TextSize = (typeof(config.TEXT_SIZE) == 'number' and config.TEXT_SIZE) or 50

    local index = #buttons + 1
    local toggle = false
    button.MouseButton1Down:Connect(function()
        if editing then
            button.AutoButtonColor = false
            local offset = button.AbsolutePosition - Vector2.new(mouse.X, mouse.Y)
            local update = runService.RenderStepped:Connect(function()
                local position = offset + Vector2.new(mouse.X, mouse.Y)
                button.Position = UDim2.fromScale(position.X / gui.AbsoluteSize.X, position.Y / gui.AbsoluteSize.Y)
            end)
            
            button.MouseButton1Up:Wait()
            update:Disconnect()

            buttons[index].pos = {button.Position.X.Scale, button.Position.Y.Scale}
            save()

            button.AutoButtonColor = true
            return
        end

        toggle = not toggle
        execCmd((toggle and options.cmd) or (options.cmd2 or options.cmd))
    end)

    options.gui = button

    buttons[index] = options
    table.insert(shade1, button)
    table.insert(text1, button)

    refreshButtons()
end

local data = load()
for _, button in pairs(data) do
    createButton(button)
end

bbinds.MouseButton1Down:Connect(function()
    BBindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
    task.wait(0.5)
    SettingsHolder.Visible = false
end)

Close.MouseButton1Down:Connect(function()
	SettingsHolder.Visible = true
	BBindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Add.MouseButton1Down:Connect(function()
    BBindsGui:TweenPosition(UDim2.new(0.5, -110, 0, 100), "InOut", "Quart", 0.5, true, nil)
end)

EditMode.MouseButton1Down:Connect(function()
    if editing then
        editing = false
        notify('BBinds', 'Editing mode has been disabled')
    else
        editing = true
        notify('BBinds', 'Editing mode has been enabled')
    end
end)

Exit_2.MouseButton1Down:Connect(function()
	Input.Text = ''
	Input_2.Text = ''
    Input_3.Text = ''
	BBindsGui:TweenPosition(UDim2.new(0.5, -110, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

Delete.MouseButton1Down:Connect(function()
    gui:ClearAllChildren()

    buttons = {}
    refreshButtons()
    save()
end)

local newToggle = false
On.MouseButton1Down:Connect(function()
    if newToggle then
        newToggle = false
        On.BackgroundTransparency = 1
        Cmdbar_3.Visible = false
    else
        newToggle = true
        On.BackgroundTransparency = 0
        Cmdbar_3.Visible = true
    end
end)

Add_1.MouseButton1Down:Connect(function()
    if Input == '' then
        notify('The command must not be empty')
        return
    end

    if Input_2 == '' and newToggle then
        notify('The second command must not be empty')
        return
    end

    if Input_3 == '' then
        notify('The text must not be empty')
    end

    createButton { text = Input_3.Text, cmd = Input.Text, cmd2 = (newToggle and Input_2.Text) or nil, pos = {20 / gui.AbsoluteSize.X, 20 / gui.AbsoluteSize.Y} }
    notify('BBinds', `The BBind {Input_3.Text} has been binded`)
    save()
end)

return {
    ["PluginName"] = "BBinds",
    ["PluginDescription"] = "Adds button binds to the infinity yield",
    ["Commands"] = {}
}