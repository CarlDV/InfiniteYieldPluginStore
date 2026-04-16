local HS = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CORE = game:GetService("CoreGui")
local PLR = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")

task.spawn(function()
    if not (addPlugin or (shared and shared.addPlugin)) then
        pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)
    end
end)

repeat task.wait(0.5) until typeof(googIY) ~= "nil" or typeof(addPlugin) == "function" or (shared and shared.addPlugin)

local TIOpen = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TIClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local hasFS = isfile and readfile and writefile and listfiles

local existing = (CORE:FindFirstChild("IYPluginMakerUI") or PLR.PlayerGui:FindFirstChild("IYPluginMakerUI"))
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "IYPluginMakerUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CORE end)
if not gui.Parent then gui.Parent = PLR:WaitForChild("PlayerGui") end

local pluginData = {
	name = "CustomPlugin",
	desc = "Made with Plugin Maker",
	commands = {},
	filename = nil
}

local listContainer, renderList, showEditor
local win, fbtn, iName, iDesc, btnExp, btnImp, btnNew
local promptSave
local winPos = UDim2.new(0.5, 0, 0.5, 0)

local function playAnim(tgt, open, cb)
	local tPos = (tgt == win) and winPos or UDim2.new(0.5, 0, 0.5, 0)
	local sc = tgt:FindFirstChildOfClass("UIScale")
	if open then
		tgt.Visible = true
		tgt.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset, tPos.Y.Scale, tPos.Y.Offset + 15)
		if sc then sc.Scale = 0.9; TS:Create(sc, TIOpen, {Scale = 1}):Play() end
		TS:Create(tgt, TIOpen, {Position = tPos}):Play()
	else
		local t = TS:Create(tgt, TIClose, {Position = UDim2.new(tPos.X.Scale, tPos.X.Offset, tPos.Y.Scale, tPos.Y.Offset + 15)})
		if sc then TS:Create(sc, TIClose, {Scale = 0.9}):Play() end
		t:Play()
		t.Completed:Connect(function() 
			tgt.Visible = false 
			if cb then cb() end 
		end)
	end
end

local function genId() return "c_"..tostring(math.random(1000,9999)) end

local function generateCode()
	local lua = "--------------------------------------------------------------------------------\n"
	lua = lua .. "-- MADE WITH IY PLUGIN MAKER\n"
	lua = lua .. "--------------------------------------------------------------------------------\n\n"
	lua = lua .. "local Plugin = {\n"
	lua = lua .. "\t[\"PluginName\"] = \"" .. (pluginData.name:gsub("\"", "\\\"")) .. "\",\n"
	lua = lua .. "\t[\"PluginDescription\"] = \"" .. (pluginData.desc:gsub("\"", "\\\"")) .. "\",\n"
	lua = lua .. "\t[\"Commands\"] = {\n"

	for i, c in ipairs(pluginData.commands) do
		lua = lua .. "\t\t[\"" .. (c.key:gsub("\"", "\\\"")) .. "\"] = {\n"
		lua = lua .. "\t\t\t[\"ListName\"] = \"" .. (c.listName:gsub("\"", "\\\"")) .. "\",\n"
		lua = lua .. "\t\t\t[\"Description\"] = \"" .. (c.desc:gsub("\"", "\\\"")) .. "\",\n"
		
		local al = {}
		for _, a in ipairs(c.aliases) do table.insert(al, "\"" .. (a:gsub("\"", "\\\"")) .. "\"") end
		lua = lua .. "\t\t\t[\"Aliases\"] = {" .. table.concat(al, ", ") .. "},\n"
		lua = lua .. "\t\t\t[\"Function\"] = function(args, speaker)\n"
		
		local lines = c.code:split("\n")
		for _, l in ipairs(lines) do lua = lua .. "\t\t\t\t" .. l .. "\n" end
		
		lua = lua .. "\t\t\tend\n"
		lua = lua .. "\t\t}" .. (i == #pluginData.commands and "" or ",") .. "\n"
	end

	lua = lua .. "\t}\n}\n\nreturn Plugin"
	return lua
end

local function parseCode(c)
	local pd = {name="Imported", desc="", commands={}}
	local n = c:match("%[\"PluginName\"%]%s*=%s*[\"']([^\"']*)[\"']")
	if n then pd.name = n end
	local d = c:match("%[\"PluginDescription\"%]%s*=%s*[\"']([^\"']*)[\"']")
	if d then pd.desc = d end
	
	local inCmds = c:find("%[\"Commands\"%]")
	if inCmds then
		local rem = c:sub(inCmds)
		for cmdK, block in rem:gmatch("%[\"([^\"]+)\"%]%s*=%s*%{(.-)[\n\r]%s*%}[,\n\r]") do
			local listN = block:match("%[\"ListName\"%]%s*=%s*[\"']([^\"']*)[\"']")
			local cmdD = block:match("%[\"Description\"%]%s*=%s*[\"']([^\"']*)[\"']")
			local als = block:match("%[\"Aliases\"%]%s*=%s*%{([^}]*)%}")
			local aL = {}
			if als then
				for a in als:gmatch("[\"']([^\"']+)[\"']") do table.insert(aL, a) end
			end
			local fnBlock = block:match("%[\"Function\"%]%s*=%s*function%([^)]*%)(.*)end")
			local fnCode = "-- code missing"
			if fnBlock then
				fnCode = fnBlock:gsub("^[\n\r%s]+", ""):gsub("[\n\r%s]+$", "")
			end
			if listN then 
				table.insert(pd.commands, {id = genId(), key = cmdK, listName = listN, desc = cmdD or "", aliases = aL, code = fnCode})
			end
		end
	end
	return pd
end

local function dragGUI(obj)
	local d,ds,dp = false,nil,nil
	local cons = {}
	obj.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true; ds = i.Position; dp = obj.Position
		end
	end)
	table.insert(cons, UIS.InputChanged:Connect(function(i)
		if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local dt = i.Position - ds
			obj.Position = UDim2.new(dp.X.Scale, dp.X.Offset+dt.X, dp.Y.Scale, dp.Y.Offset+dt.Y)
		end
	end))
	table.insert(cons, UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
			d = false
			if obj == win then winPos = obj.Position end
		end
	end))
	local ac; ac = obj.AncestryChanged:Connect(function(_, parent)
		if not parent then
			for _,c in pairs(cons) do c:Disconnect() end
			ac:Disconnect()
		end
	end)
end

local function cr(clr, rad)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, rad or 4); return c
end
local function st(clr)
	local s = Instance.new("UIStroke"); s.Color = clr; return s
end

-- MAIN UI
win = Instance.new("Frame")
win.Size = UDim2.new(0.9, 0, 0.85, 0)
win.Position = winPos
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = Color3.fromRGB(15,15,17)
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Visible = false

local max_s = Instance.new("UISizeConstraint")
max_s.MaxSize = Vector2.new(640, 500)
max_s.Parent = win

cr(4).Parent = win
st(Color3.fromRGB(40,40,45)).Parent = win
local ws = Instance.new("UIScale")
ws.Parent = win
win.Parent = gui

dragGUI(win)

local top = Instance.new("Frame")
top.Size=UDim2.new(1,0,0,40)
top.BackgroundColor3=Color3.fromRGB(20,20,23)
top.BorderSizePixel=0
local top_bline = Instance.new("Frame")
top_bline.Size = UDim2.new(1,0,0,1); top_bline.Position = UDim2.new(0,0,1,0)
top_bline.BackgroundColor3=Color3.fromRGB(35,35,40); top_bline.BorderSizePixel=0; top_bline.Parent = top
local txt = Instance.new("TextLabel")
txt.Text = "Plugin Maker" 
txt.TextColor3 = Color3.fromRGB(240,240,240)
txt.BackgroundTransparency = 1 
txt.Size = UDim2.new(1,-60,1,0); txt.Position = UDim2.new(0,14,0,0)
txt.TextXAlignment = Enum.TextXAlignment.Left 
txt.Font = Enum.Font.GothamMedium; txt.TextSize = 14 
txt.Parent = top
top.Parent = win

local close = Instance.new("TextButton")
close.Text="X"; close.Size=UDim2.new(0,40,1,0); close.Position=UDim2.new(1,-40,0,0)
close.BackgroundColor3=Color3.fromRGB(20,20,23); close.TextColor3=Color3.fromRGB(220,90,90)
close.Font=Enum.Font.GothamMedium; close.TextSize=14; close.BorderSizePixel=0
close.AutoButtonColor = true; close.Parent = top
close.MouseButton1Click:Connect(function() 
	playAnim(win, false, function() gui:Destroy() end)
end)

local min = Instance.new("TextButton")
min.Text="-"; min.Size=UDim2.new(0,40,1,0); min.Position=UDim2.new(1,-80,0,0)
min.BackgroundColor3=Color3.fromRGB(20,20,23); min.TextColor3=Color3.fromRGB(160,160,160)
min.Font=Enum.Font.GothamMedium; min.TextSize=16; min.BorderSizePixel=0
min.AutoButtonColor = true; min.Parent = top
min.MouseButton1Click:Connect(function() 
	playAnim(win, false, function() fbtn.Visible = true end)
end)

btnNew = Instance.new("TextButton")
btnNew.Text="New"; btnNew.Size=UDim2.new(0,45,0,24); btnNew.Position=UDim2.new(1,-130,0,8)
btnNew.BackgroundColor3=Color3.fromRGB(40,40,45); btnNew.TextColor3=Color3.fromRGB(220,220,220); btnNew.Font=Enum.Font.GothamMedium; btnNew.TextSize=10; cr(4).Parent=btnNew
btnNew.Parent = top

btnNew.MouseButton1Click:Connect(function()
	pluginData = {name="", desc="", commands={}, filename=nil}
	iName.Text = ""; iDesc.Text = ""
	renderList()
end)

btnExp = Instance.new("TextButton")
btnExp.Text="Save"; btnExp.Size=UDim2.new(0,45,0,24); btnExp.Position=UDim2.new(1,-180,0,8)
btnExp.BackgroundColor3=Color3.fromRGB(0,140,255); btnExp.TextColor3=Color3.fromRGB(255,255,255); btnExp.Font=Enum.Font.GothamMedium; btnExp.TextSize=10; cr(4).Parent=btnExp
btnExp.Parent = top
btnExp.MouseButton1Click:Connect(function() promptSave() end)

btnImp = Instance.new("TextButton")
btnImp.Text="Import"; btnImp.Size=UDim2.new(0,45,0,24); btnImp.Position=UDim2.new(1,-230,0,8)
btnImp.BackgroundColor3=Color3.fromRGB(35,35,40); btnImp.TextColor3=Color3.fromRGB(220,220,220); btnImp.Font=Enum.Font.GothamMedium; btnImp.TextSize=10; cr(4).Parent=btnImp
btnImp.Parent = top


fbtn = Instance.new("TextButton")
fbtn.Text="Maker"
fbtn.Size=UDim2.new(0,60,0,30)
fbtn.Position=UDim2.new(1,-70,0,50)
fbtn.BackgroundColor3=Color3.fromRGB(0,140,255)
fbtn.TextColor3=Color3.fromRGB(255,255,255)
fbtn.Visible=false
fbtn.Font=Enum.Font.GothamBold
fbtn.TextSize=12
fbtn.BorderSizePixel=0
cr(4).Parent=fbtn
fbtn.Parent = gui

local drag_f, org, f_con = false, nil, nil
fbtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag_f = true; org = i.Position
		local sp = fbtn.Position
		if f_con then f_con:Disconnect() end
		f_con = UIS.InputChanged:Connect(function(j)
			if not drag_f then f_con:Disconnect(); f_con = nil; return end
			if j.UserInputType == Enum.UserInputType.MouseMovement or j.UserInputType == Enum.UserInputType.Touch then
				local d = j.Position - org
				fbtn.Position = UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
			end
		end)
	end
end)
fbtn.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		if org and (i.Position - org).Magnitude < 5 then
			fbtn.Visible = false
			playAnim(win, true)
		end
		drag_f = false; org = nil
		if f_con then f_con:Disconnect(); f_con = nil end
	end
end)
fbtn.AncestryChanged:Connect(function(_, parent)
	if not parent and f_con then f_con:Disconnect(); f_con = nil end
end)


local side = Instance.new("Frame")
side.Size=UDim2.new(0.35,0,1,-40); side.Position=UDim2.new(0,0,0,40)
side.BackgroundColor3=Color3.fromRGB(18,18,20); side.BorderSizePixel=0
local sdiv = Instance.new("Frame")
sdiv.Size=UDim2.new(0,1,1,0); sdiv.Position=UDim2.new(1,-1,0,0); sdiv.BackgroundColor3=Color3.fromRGB(35,35,40); sdiv.BorderSizePixel=0; sdiv.Parent=side
side.Parent = win

local mainArea = Instance.new("Frame")
mainArea.Size=UDim2.new(0.65,0,1,-40); mainArea.Position=UDim2.new(0.35,0,0,40)
mainArea.BackgroundTransparency=1
mainArea.Parent = win

local s_pad = Instance.new("UIPadding")
s_pad.PaddingLeft=UDim.new(0,8); s_pad.PaddingRight=UDim.new(0,8); s_pad.Parent=side

local lName = Instance.new("TextLabel")
lName.Text="PLUGIN NAME"; lName.Size=UDim2.new(1,0,0,20); lName.Position=UDim2.new(0,0,0,10)
lName.TextColor3=Color3.fromRGB(120,120,120); lName.BackgroundTransparency=1; lName.Font=Enum.Font.GothamBold; lName.TextSize=10; lName.TextXAlignment=Enum.TextXAlignment.Left; lName.Parent=side

iName = Instance.new("TextBox")
iName.Text=pluginData.name; iName.PlaceholderText="Plugin Name..."
iName.Size=UDim2.new(1,0,0,32); iName.Position=UDim2.new(0,0,0,30)
iName.BackgroundColor3=Color3.fromRGB(25,25,28); iName.TextColor3=Color3.fromRGB(240,240,240)
iName.Font=Enum.Font.Gotham; iName.TextSize=12; iName.TextXAlignment=Enum.TextXAlignment.Left; iName.ClearTextOnFocus=false
local p1=Instance.new("UIPadding"); p1.PaddingLeft=UDim.new(0,8); p1.Parent=iName; cr(4).Parent=iName; st(Color3.fromRGB(45,45,50)).Parent=iName
iName.Parent=side
iName:GetPropertyChangedSignal("Text"):Connect(function() pluginData.name=iName.Text end)

local lDesc = Instance.new("TextLabel")
lDesc.Text="DESCRIPTION"; lDesc.Size=UDim2.new(1,0,0,20); lDesc.Position=UDim2.new(0,0,0,72)
lDesc.TextColor3=Color3.fromRGB(120,120,120); lDesc.BackgroundTransparency=1; lDesc.Font=Enum.Font.GothamBold; lDesc.TextSize=10; lDesc.TextXAlignment=Enum.TextXAlignment.Left; lDesc.Parent=side

iDesc = Instance.new("TextBox")
iDesc.Text=pluginData.desc; iDesc.PlaceholderText="Plugin Description..."
iDesc.Size=UDim2.new(1,0,0,60); iDesc.Position=UDim2.new(0,0,0,92)
iDesc.BackgroundColor3=Color3.fromRGB(25,25,28); iDesc.TextColor3=Color3.fromRGB(240,240,240)
iDesc.Font=Enum.Font.Gotham; iDesc.TextSize=12; iDesc.TextXAlignment=Enum.TextXAlignment.Left; iDesc.TextYAlignment=Enum.TextYAlignment.Top; iDesc.ClearTextOnFocus=false; iDesc.TextWrapped=true
local p2=Instance.new("UIPadding"); p2.PaddingLeft=UDim.new(0,8); p2.PaddingTop=UDim.new(0,8); p2.Parent=iDesc; cr(4).Parent=iDesc; st(Color3.fromRGB(45,45,50)).Parent=iDesc
iDesc.Parent=side
iDesc:GetPropertyChangedSignal("Text"):Connect(function() pluginData.desc=iDesc.Text end)


local viewList = Instance.new("Frame")
viewList.Size=UDim2.new(1,0,1,0); viewList.BackgroundTransparency=1; viewList.Parent=mainArea

local cTop = Instance.new("Frame")
cTop.Size=UDim2.new(1,0,0,40); cTop.BackgroundTransparency=1; cTop.Parent=viewList
local cTitle = Instance.new("TextLabel")
cTitle.Text="Commands"; cTitle.Size=UDim2.new(1,-90,1,0); cTitle.Position=UDim2.new(0,12,0,0)
cTitle.TextColor3=Color3.fromRGB(240,240,240); cTitle.BackgroundTransparency=1; cTitle.Font=Enum.Font.GothamBold; cTitle.TextSize=14; cTitle.TextXAlignment=Enum.TextXAlignment.Left; cTitle.Parent=cTop

local btnAdd = Instance.new("TextButton")
btnAdd.Text="+ Add Cmd"; btnAdd.Size=UDim2.new(0,70,0,24); btnAdd.Position=UDim2.new(1,-82,0,8)
btnAdd.BackgroundColor3=Color3.fromRGB(40,40,45); btnAdd.TextColor3=Color3.fromRGB(255,255,255); btnAdd.Font=Enum.Font.GothamMedium; btnAdd.TextSize=11; cr(4).Parent=btnAdd
btnAdd.Parent=cTop

listContainer = Instance.new("ScrollingFrame")
listContainer.Size=UDim2.new(1,-24,1,-50); listContainer.Position=UDim2.new(0,12,0,40)
listContainer.BackgroundTransparency=1; listContainer.ScrollBarThickness=2; listContainer.ScrollBarImageColor3=Color3.fromRGB(70,70,75)
listContainer.CanvasSize=UDim2.new(0,0,0,0); listContainer.AutomaticCanvasSize=Enum.AutomaticSize.Y
local uill = Instance.new("UIListLayout"); uill.Padding=UDim.new(0,8); uill.Parent=listContainer
listContainer.Parent = viewList

local viewEdit = Instance.new("Frame")
viewEdit.Size=UDim2.new(1,0,1,0); viewEdit.BackgroundTransparency=1; viewEdit.Visible=false; viewEdit.Parent=mainArea

local eTop = Instance.new("Frame")
eTop.Size=UDim2.new(1,0,0,40); eTop.BackgroundTransparency=1; eTop.Parent=viewEdit
local btnBack = Instance.new("TextButton")
btnBack.Text="< Back"; btnBack.Size=UDim2.new(0,50,0,24); btnBack.Position=UDim2.new(0,12,0,8)
btnBack.BackgroundColor3=Color3.fromRGB(40,40,45); btnBack.TextColor3=Color3.fromRGB(220,220,220); btnBack.Font=Enum.Font.GothamMedium; btnBack.TextSize=11; cr(4).Parent=btnBack; btnBack.Parent=eTop
local eTitle = Instance.new("TextLabel")
eTitle.Text="Edit Command"; eTitle.Size=UDim2.new(1,-80,1,0); eTitle.Position=UDim2.new(0,72,0,0)
eTitle.TextColor3=Color3.fromRGB(240,240,240); eTitle.BackgroundTransparency=1; eTitle.Font=Enum.Font.GothamBold; eTitle.TextSize=14; eTitle.TextXAlignment=Enum.TextXAlignment.Left; eTitle.Parent=eTop

local scrE = Instance.new("ScrollingFrame")
scrE.Size=UDim2.new(1,-24,1,-50); scrE.Position=UDim2.new(0,12,0,40)
scrE.BackgroundTransparency=1; scrE.ScrollBarThickness=2; scrE.ScrollBarImageColor3=Color3.fromRGB(70,70,75)
scrE.CanvasSize=UDim2.new(0,0,0,0); scrE.AutomaticCanvasSize=Enum.AutomaticSize.Y
scrE.Parent=viewEdit

local eKeyL = Instance.new("TextLabel"); eKeyL.Text="KEY (e.g. fly)"; eKeyL.Size=UDim2.new(0.5,-4,0,16); eKeyL.Position=UDim2.new(0,0,0,0); eKeyL.TextColor3=Color3.fromRGB(120,120,120); eKeyL.Font=Enum.Font.GothamBold; eKeyL.TextSize=10; eKeyL.BackgroundTransparency=1; eKeyL.TextXAlignment=Enum.TextXAlignment.Left; eKeyL.Parent=scrE
local eKeyI = Instance.new("TextBox"); eKeyI.PlaceholderText="Command Key (e.g. fly)"; eKeyI.Size=UDim2.new(0.5,-4,0,28); eKeyI.Position=UDim2.new(0,0,0,16); eKeyI.BackgroundColor3=Color3.fromRGB(25,25,28); eKeyI.TextColor3=Color3.fromRGB(240,240,240); eKeyI.Font=Enum.Font.Gotham; eKeyI.TextSize=12; eKeyI.ClearTextOnFocus=false; eKeyI.TextXAlignment=Enum.TextXAlignment.Left; local p3=Instance.new("UIPadding"); p3.PaddingLeft=UDim.new(0,8); p3.Parent=eKeyI; cr(4).Parent=eKeyI; st(Color3.fromRGB(45,45,50)).Parent=eKeyI; eKeyI.Parent=scrE

local eNameL = Instance.new("TextLabel"); eNameL.Text="USAGE"; eNameL.Size=UDim2.new(0.5,-4,0,16); eNameL.Position=UDim2.new(0.5,4,0,0); eNameL.TextColor3=Color3.fromRGB(120,120,120); eNameL.Font=Enum.Font.GothamBold; eNameL.TextSize=10; eNameL.BackgroundTransparency=1; eNameL.TextXAlignment=Enum.TextXAlignment.Left; eNameL.Parent=scrE
local eNameI = Instance.new("TextBox"); eNameI.PlaceholderText="Usage (e.g. fly [speed])"; eNameI.Size=UDim2.new(0.5,-4,0,28); eNameI.Position=UDim2.new(0.5,4,0,16); eNameI.BackgroundColor3=Color3.fromRGB(25,25,28); eNameI.TextColor3=Color3.fromRGB(240,240,240); eNameI.Font=Enum.Font.Gotham; eNameI.TextSize=12; eNameI.ClearTextOnFocus=false; eNameI.TextXAlignment=Enum.TextXAlignment.Left; local p4=Instance.new("UIPadding"); p4.PaddingLeft=UDim.new(0,8); p4.Parent=eNameI; cr(4).Parent=eNameI; st(Color3.fromRGB(45,45,50)).Parent=eNameI; eNameI.Parent=scrE

local eDescL = Instance.new("TextLabel"); eDescL.Text="DESCRIPTION"; eDescL.Size=UDim2.new(1,0,0,16); eDescL.Position=UDim2.new(0,0,0,50); eDescL.TextColor3=Color3.fromRGB(120,120,120); eDescL.Font=Enum.Font.GothamBold; eDescL.TextSize=10; eDescL.BackgroundTransparency=1; eDescL.TextXAlignment=Enum.TextXAlignment.Left; eDescL.Parent=scrE
local eDescI = Instance.new("TextBox"); eDescI.PlaceholderText="Command Description..."; eDescI.Size=UDim2.new(1,0,0,28); eDescI.Position=UDim2.new(0,0,0,66); eDescI.BackgroundColor3=Color3.fromRGB(25,25,28); eDescI.TextColor3=Color3.fromRGB(240,240,240); eDescI.Font=Enum.Font.Gotham; eDescI.TextSize=12; eDescI.ClearTextOnFocus=false; eDescI.TextXAlignment=Enum.TextXAlignment.Left; local p5=Instance.new("UIPadding"); p5.PaddingLeft=UDim.new(0,8); p5.Parent=eDescI; cr(4).Parent=eDescI; st(Color3.fromRGB(45,45,50)).Parent=eDescI; eDescI.Parent=scrE

local eAlsL = Instance.new("TextLabel"); eAlsL.Text="ALIASES (Comma separated)"; eAlsL.Size=UDim2.new(1,0,0,16); eAlsL.Position=UDim2.new(0,0,0,100); eAlsL.TextColor3=Color3.fromRGB(120,120,120); eAlsL.Font=Enum.Font.GothamBold; eAlsL.TextSize=10; eAlsL.BackgroundTransparency=1; eAlsL.TextXAlignment=Enum.TextXAlignment.Left; eAlsL.Parent=scrE
local eAlsI = Instance.new("TextBox"); eAlsI.PlaceholderText="Aliases (e.g. f, flying)"; eAlsI.Size=UDim2.new(1,0,0,28); eAlsI.Position=UDim2.new(0,0,0,116); eAlsI.BackgroundColor3=Color3.fromRGB(25,25,28); eAlsI.TextColor3=Color3.fromRGB(240,240,240); eAlsI.Font=Enum.Font.Gotham; eAlsI.TextSize=12; eAlsI.ClearTextOnFocus=false; eAlsI.TextXAlignment=Enum.TextXAlignment.Left; local p6=Instance.new("UIPadding"); p6.PaddingLeft=UDim.new(0,8); p6.Parent=eAlsI; cr(4).Parent=eAlsI; st(Color3.fromRGB(45,45,50)).Parent=eAlsI; eAlsI.Parent=scrE

local eCodeL = Instance.new("TextLabel"); eCodeL.Text="LUA LOGIC"; eCodeL.Size=UDim2.new(1,0,0,16); eCodeL.Position=UDim2.new(0,0,0,150); eCodeL.TextColor3=Color3.fromRGB(120,120,120); eCodeL.Font=Enum.Font.GothamBold; eCodeL.TextSize=10; eCodeL.BackgroundTransparency=1; eCodeL.TextXAlignment=Enum.TextXAlignment.Left; eCodeL.Parent=scrE
local eCodeI = Instance.new("TextBox"); eCodeI.PlaceholderText="-- Write your Lua code here..."; eCodeI.Size=UDim2.new(1,0,0,160); eCodeI.Position=UDim2.new(0,0,0,166); eCodeI.BackgroundColor3=Color3.fromRGB(20,20,24); eCodeI.TextColor3=Color3.fromRGB(200,200,200); eCodeI.Font=Enum.Font.Code; eCodeI.TextSize=11; eCodeI.ClearTextOnFocus=false; eCodeI.TextXAlignment=Enum.TextXAlignment.Left; eCodeI.TextYAlignment=Enum.TextYAlignment.Top; eCodeI.MultiLine=true; local p7=Instance.new("UIPadding"); p7.PaddingLeft=UDim.new(0,8); p7.PaddingTop=UDim.new(0,8); p7.Parent=eCodeI; cr(4).Parent=eCodeI; st(Color3.fromRGB(40,40,40)).Parent=eCodeI; eCodeI.Parent=scrE

local dummySpace = Instance.new("Frame"); dummySpace.Size=UDim2.new(1,0,0,340); dummySpace.BackgroundTransparency=1; dummySpace.Parent=scrE

renderList = function()
	for _, c in pairs(listContainer:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for _, c in ipairs(pluginData.commands) do
		local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,0,46); f.BackgroundColor3=Color3.fromRGB(22,22,26); cr(4).Parent=f; st(Color3.fromRGB(45,45,50)).Parent=f
		local lblN = Instance.new("TextLabel"); lblN.Text=c.listName; lblN.Size=UDim2.new(1,-70,0,18); lblN.Position=UDim2.new(0,8,0,6); lblN.TextColor3=Color3.fromRGB(240,240,240); lblN.BackgroundTransparency=1; lblN.Font=Enum.Font.GothamMedium; lblN.TextSize=12; lblN.TextXAlignment=Enum.TextXAlignment.Left; lblN.TextTruncate=Enum.TextTruncate.AtEnd; lblN.Parent=f
		local lblK = Instance.new("TextLabel"); lblK.Text="Key: " .. c.key; lblK.Size=UDim2.new(1,-70,0,14); lblK.Position=UDim2.new(0,8,0,24); lblK.TextColor3=Color3.fromRGB(120,120,120); lblK.BackgroundTransparency=1; lblK.Font=Enum.Font.Code; lblK.TextSize=10; lblK.TextXAlignment=Enum.TextXAlignment.Left; lblK.Parent=f
		
		local bEdit = Instance.new("TextButton"); bEdit.Text="Edit"; bEdit.Size=UDim2.new(0,34,0,22); bEdit.Position=UDim2.new(1,-72,0.5,-11); bEdit.BackgroundColor3=Color3.fromRGB(40,40,45); bEdit.TextColor3=Color3.fromRGB(220,220,220); bEdit.Font=Enum.Font.GothamMedium; bEdit.TextSize=10; cr(4).Parent=bEdit; bEdit.Parent=f
		bEdit.MouseButton1Click:Connect(function() showEditor(c) end)
		
		local bDel = Instance.new("TextButton"); bDel.Text="×"; bDel.Size=UDim2.new(0,26,0,22); bDel.Position=UDim2.new(1,-34,0.5,-11); bDel.BackgroundColor3=Color3.fromRGB(255,100,100); bDel.TextColor3=Color3.fromRGB(255,255,255); bDel.Font=Enum.Font.GothamBold; bDel.TextSize=14; cr(4).Parent=bDel; bDel.Parent=f
		bDel.MouseButton1Click:Connect(function()
			for i, v in ipairs(pluginData.commands) do if v.id == c.id then table.remove(pluginData.commands, i); break end end
			renderList()
		end)
		f.Parent = listContainer
	end
end

showEditor = function(cmd)
	curEditCmd = cmd
	if cmd then
		eKeyI.Text = cmd.key; eNameI.Text = cmd.listName; eDescI.Text = cmd.desc; eAlsI.Text = table.concat(cmd.aliases, ", "); eCodeI.Text = cmd.code
	else
		eKeyI.Text = ""; eNameI.Text = ""; eDescI.Text = ""; eAlsI.Text = ""; eCodeI.Text = "-- print('hello')"
	end
	viewList.Visible = false; viewEdit.Visible = true
end

btnBack.MouseButton1Click:Connect(function()
	if curEditCmd then
		curEditCmd.key = eKeyI.Text
		curEditCmd.listName = eNameI.Text
		curEditCmd.desc = eDescI.Text
		
		local als = {}
		for a in eAlsI.Text:gmatch("[^,]+") do
			local clean = a:match("^%s*(.-)%s*$")
			if clean ~= "" then table.insert(als, clean) end
		end
		curEditCmd.aliases = als
		curEditCmd.code = eCodeI.Text
	else
		if eKeyI.Text ~= "" or eNameI.Text ~= "" then
			local als = {}
			for a in eAlsI.Text:gmatch("[^,]+") do
				local clean = a:match("^%s*(.-)%s*$")
				if clean ~= "" then table.insert(als, clean) end
			end
			table.insert(pluginData.commands, {
				id = genId(), key = eKeyI.Text, listName = eNameI.Text, desc = eDescI.Text, aliases = als, code = eCodeI.Text
			})
		end
	end
	curEditCmd = nil
	viewList.Visible = true; viewEdit.Visible = false
	renderList()
end)

btnAdd.MouseButton1Click:Connect(function() showEditor(nil) end)
promptSave = function()
	if not writefile then return end
	local fn = pluginData.filename or (pluginData.name:gsub("[^%w_]", "") .. ".iy")
	if fn == ".iy" then fn = "unnamed_plugin.iy" end
	pluginData.filename = fn
	
	writefile(fn, generateCode())
	
	pcall(function()
		local del = deletePlugin or (shared and shared.deletePlugin)
		if del then del(fn) end
		local add = addPlugin or (shared and shared.addPlugin)
		if add then add(fn) end
	end)
	
	btnExp.Text = "Saved!"
	task.delay(1.5, function() btnExp.Text = "Save" end)
end

-- Importing here
local impWin = Instance.new("Frame")
impWin.Size=UDim2.new(1,0,1,0); impWin.BackgroundColor3=Color3.fromRGB(15,15,17, 0.9); impWin.Visible=false; impWin.ZIndex=10; impWin.Parent=win
local impC = Instance.new("Frame")
impC.Size=UDim2.new(0.8,0,0.8,0); impC.Position=UDim2.new(0.5,0,0.5,0); impC.AnchorPoint=Vector2.new(0.5,0.5); impC.BackgroundColor3=Color3.fromRGB(20,20,23); impC.ZIndex=11; cr(6).Parent=impC; st(Color3.fromRGB(45,45,50)).Parent=impC
local i_max = Instance.new("UISizeConstraint"); i_max.MaxSize = Vector2.new(340, 400); i_max.Parent = impC
impC.Parent=impWin

local impTitle = Instance.new("TextLabel"); impTitle.Text="Import Plugin"; impTitle.Size=UDim2.new(1,0,0,40); impTitle.TextColor3=Color3.fromRGB(240,240,240); impTitle.BackgroundTransparency=1; impTitle.Font=Enum.Font.GothamBold; impTitle.TextSize=15; impTitle.ZIndex=12; impTitle.Parent=impC
local btnCImp = Instance.new("TextButton"); btnCImp.Text="Cancel"; btnCImp.Size=UDim2.new(1,-40,0,32); btnCImp.Position=UDim2.new(0,20,1,-42); btnCImp.BackgroundColor3=Color3.fromRGB(35,35,40); btnCImp.TextColor3=Color3.fromRGB(220,220,220); btnCImp.Font=Enum.Font.GothamMedium; btnCImp.TextSize=12; btnCImp.ZIndex=12; cr(4).Parent=btnCImp; btnCImp.Parent=impC
local impList = Instance.new("ScrollingFrame"); impList.Size=UDim2.new(1,-40,1,-92); impList.Position=UDim2.new(0,20,0,40); impList.BackgroundTransparency=1; impList.ScrollBarThickness=2; impList.ZIndex=12; impList.CanvasSize=UDim2.new(0,0,0,0); impList.AutomaticCanvasSize=Enum.AutomaticSize.Y; local ilay = Instance.new("UIListLayout"); ilay.Padding=UDim.new(0,6); ilay.Parent=impList; impList.Parent=impC
btnCImp.MouseButton1Click:Connect(function() impWin.Visible=false end)

btnImp.MouseButton1Click:Connect(function()
	if not hasFS then warn("Executor does not support listfiles"); return end
	for _, c in pairs(impList:GetChildren()) do if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end end
	local fs = listfiles("") or {}
	local ct = 0
	for _, f in pairs(fs) do
		if f:sub(-3) == ".iy" then
			local b = Instance.new("TextButton")
			b.Text = f:match("([^/\\]+)$") or f
			b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3=Color3.fromRGB(30,30,34); b.TextColor3=Color3.fromRGB(200,200,200); b.Font=Enum.Font.Gotham; b.TextSize=12; cr(4).Parent=b; b.ZIndex=12; b.Parent=impList
			b.MouseButton1Click:Connect(function()
				local s, c = pcall(function() return readfile(f) end)
				if s and c then
					pluginData = parseCode(c)
					pluginData.filename = f
					iName.Text = pluginData.name; iDesc.Text = pluginData.desc
					renderList()
					impWin.Visible = false
				end
			end)
			ct = ct + 1
		end
	end
	if ct == 0 then
		local b = Instance.new("TextLabel")
		b.Text = "No .iy files found."; b.Size = UDim2.new(1,0,0,32); b.BackgroundTransparency=1; b.TextColor3=Color3.fromRGB(150,150,150); b.Font=Enum.Font.Gotham; b.TextSize=12; b.ZIndex=12; b.Parent=impList
	end
	impWin.Visible = true
end)

btnExp.MouseButton1Click:Connect(promptSave)

renderList()
playAnim(win, true)
