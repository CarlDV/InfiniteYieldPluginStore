local Plugin = {
    PluginName = "ESCMDS",
    PluginDescription = "Commands by Raptor537 for the game 'Electric State DarkRp'",
    Commands = {
        NoNLR = {
            ListName = "NoNLR",
            Description = "Disables NLR, or New Life Rule.",
            Aliases = {},
            Function = function(args,speaker)
                notify("NoNLR", "Enabled NoNLR, no more of that annoying red circle!")
                while wait(5) do
                    for i, v in pairs(game.Workspace:GetChildren()) do
                        if v.Name == "NL" then
                            v:Destroy()
                        end
                    end
                end
            end
        },
        Aimlock = {
            ListName = "Aimlock",
            Description = "An aimlock script made partially by Raptor537.",
            Aliases = {},
            Function = function(args,speaker)
                local LockOnKey = "c"
                local SelectKey = "z"
                local sgui = game.StarterGui
                local function CreateInstance(cls,props)
                    local inst = Instance.new(cls)
                    for i,v in pairs(props) do
    	                inst[i] = v
                    end 
                    return inst
                end
                local ScreenGui = CreateInstance('ScreenGui',{DisplayOrder=0,Enabled=true,ResetOnSpawn=true,Name='ScreenGui', Parent=game.CoreGui})
                local Frame = CreateInstance('Frame',{Style=Enum.FrameStyle.Custom,Active=false,AnchorPoint=Vector2.new(0, 0),BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0,BorderColor3=Color3.new(0.105882, 0.164706, 0.207843),BorderSizePixel=1,ClipsDescendants=false,Draggable=false,Position=UDim2.new(0, 0, 0.433753937, 0),Rotation=0,Selectable=false,Size=UDim2.new(0, 123, 0, 114),SizeConstraint=Enum.SizeConstraint.RelativeXY,Visible=true,ZIndex=1,Name = 'Frame',Parent = ScreenGui})
                local TextLabel = CreateInstance('TextLabel',{Font=Enum.Font.SourceSans,FontSize=Enum.FontSize.Size14,Text='Script Modified By Raptor537',TextColor3=Color3.new(0, 0, 0),TextScaled=false,TextSize=14,TextStrokeColor3=Color3.new(0, 0, 0),TextStrokeTransparency=1,TextTransparency=0,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,Active=false,AnchorPoint=Vector2.new(0, 0),BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0,BorderColor3=Color3.new(0.105882, 0.164706, 0.207843),BorderSizePixel=1,ClipsDescendants=false,Draggable=false,Position=UDim2.new(0, 0, 0, 0),Rotation=0,Selectable=false,Size=UDim2.new(0, 123, 0, 38),SizeConstraint=Enum.SizeConstraint.RelativeXY,Visible=true,ZIndex=1,Name='TextLabel',Parent = Frame})
                local TextButton = CreateInstance('TextButton',{Font=Enum.Font.SourceSans,FontSize=Enum.FontSize.Size14,Text='Toggle LockOn',TextColor3=Color3.new(0, 0, 0),TextScaled=false,TextSize=14,TextStrokeColor3=Color3.new(0, 0, 0),TextStrokeTransparency=1,TextTransparency=0,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,AutoButtonColor=true,Modal=false,Selected=false,Style=Enum.ButtonStyle.Custom,Active=true,AnchorPoint=Vector2.new(0, 0),BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0,BorderColor3=Color3.new(0.105882, 0.164706, 0.207843),BorderSizePixel=1,ClipsDescendants=false,Draggable=false,Position=UDim2.new(0.478455257, 0, 0.675438583, 0),Rotation=0,Selectable=true,Size=UDim2.new(0, 58, 0, 37),SizeConstraint=Enum.SizeConstraint.RelativeXY,Visible=true,ZIndex=1,Name='TextButton',Parent = Frame})
                local TextBox = CreateInstance('TextBox',{ClearTextOnFocus=true,Font=Enum.Font.SourceSans,FontSize=Enum.FontSize.Size14,MultiLine=false,Text='Player *AutoFills*',TextColor3=Color3.new(0, 0, 0), PlaceholderText='', PlaceholderColor3=Color3.new(0.7, 0.7, 0.7),TextScaled=false,TextSize=14,TextStrokeColor3=Color3.new(0, 0, 0),TextStrokeTransparency=1,TextTransparency=0,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,Active=true,AnchorPoint=Vector2.new(0, 0),BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0,BorderColor3=Color3.new(0.105882, 0.164706, 0.207843),BorderSizePixel=1,ClipsDescendants=false,Draggable=false,Position=UDim2.new(0.08130081, 0, 0.350877196, 0),Rotation=0,Selectable=true,Size=UDim2.new(0, 102, 0, 34),SizeConstraint=Enum.SizeConstraint.RelativeXY,Visible=true,ZIndex=1,Name='TextBox',Parent = Frame})
                local TextButton2 = CreateInstance('TextButton',{Font=Enum.Font.SourceSans,FontSize=Enum.FontSize.Size14,Text='Close',TextColor3=Color3.new(0, 0, 0),TextScaled=false,TextSize=14,TextStrokeColor3=Color3.new(0, 0, 0),TextStrokeTransparency=1,TextTransparency=0,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Center,AutoButtonColor=true,Modal=false,Selected=false,Style=Enum.ButtonStyle.Custom,Active=true,AnchorPoint=Vector2.new(0, 0),BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0,BorderColor3=Color3.new(0.105882, 0.164706, 0.207843),BorderSizePixel=1,ClipsDescendants=false,Draggable=false,Position=UDim2.new(0, 0, 0.675438583, 0),Rotation=0,Selectable=true,Size=UDim2.new(0, 58, 0, 37),SizeConstraint=Enum.SizeConstraint.RelativeXY,Visible=true,ZIndex=1,Name='TextButton',Parent = Frame})
                local function DragScript()
                    local UserInputService = game:GetService("UserInputService")
                    local gui = Frame
                    local dragging
                    local dragInput
                    local dragStart
                    local startPos
                    local function update(input)
	                    local delta = input.Position - dragStart
	                    gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                    gui.InputBegan:Connect(function(input)
	                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		                    dragging = true
		                    dragStart = input.Position
		                    startPos = gui.Position
		                    input.Changed:Connect(function()
			                    if input.UserInputState == Enum.UserInputState.End then
				                    dragging = false
			                    end
		                    end)
	                    end
                    end)
                    gui.InputChanged:Connect(function(input)
	                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		                    dragInput = input
	                    end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
	                    if input == dragInput and dragging then
	    	                update(input)
	                    end
                    end)
                end
                DragScript()
                TextBox.FocusLost:connect(function()
                    for i,v in pairs(game.Players:GetChildren()) do
                        if (string.sub(string.lower(v.Name),1,string.len(TextBox.Text))) == string.lower(TextBox.Text) then
                            TextBox.Text = v.Name
                        end
                    end
                end)
                local function LockOn()
                    _G.on = true
                    local name = TextBox.Text
                    local plr = game.Players.LocalPlayer
                    while _G.on == true do
                        for i,v in pairs(game:GetService("Players"):GetChildren()) do
                            if v.Character:FindFirstChild("HumanoidRootPart") and v.Name == name then
                                repeat
                                    local pos = v.Character.HumanoidRootPart.Position
                                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position,pos)
                                    wait()
                                until v.Character.Humanoid.Health < 1 or _G.on == false
                            end
                        end
                    end
                end
                local mouse = game.Players.LocalPlayer:GetMouse()
                mouse.KeyDown:Connect(function(key)
                    if key == SelectKey then
                        for i, v in pairs(game.Players:GetChildren()) do
                            if mouse.Target.Parent.Name == v.Name then
                                TextBox.Text = v.Name
                            end
                        end
                    end
                end)
                TextButton.MouseButton1Down:Connect(function()
                    if not _G.on then
                        LockOn()
                    else
                        _G.on = false
                    end
                end)
                TextButton2.MouseButton1Down:Connect(function()
                    ScreenGui:Destroy()
                end)
                mouse.KeyDown:Connect(function(key)
                    if key == LockOnKey then
                        if not _G.on then
                            LockOn()
                        else
                            _G.on = false
                        end
                    end
                end)
                notify("Raptor537's Aimbot", "Press the '" .. SelectKey .. "' key to select a person to lock on to, and press the '" .. LockOnKey .. "' key to toggle the aimbot!")
            end
        }
    }
}

return Plugin