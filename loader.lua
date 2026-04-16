-- IY plugin store 

local HS = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CORE = game:GetService("CoreGui")
local PLR = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local TIOpen = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TIClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

task.spawn(function()
    pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)
end)

repeat task.wait(0.5) until typeof(googIY) ~= "nil" or typeof(addPlugin) == "function" or (shared and shared.addPlugin)

local API = "https://iyplugins.pages.dev"
local all = {}
local cur = nil

local winPos = UDim2.new(0.5, 0, 0.5, 0)
local win

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

local function is_got(p)
	if not isfile then return false end
	for _,f in pairs(p.files or {}) do
		if f.filename:lower():match("%.iy$") and isfile(f.filename) then return true end
	end
	return false
end

local function getTitle(p)
	for _,f in pairs(p.files or {}) do
		if f.filename:lower():match("%.iy$") then return f.filename:gsub("%.iy$","") end
	end
	return p.name or "nan"
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

local existing = (CORE:FindFirstChild("IYStoreUI") or PLR.PlayerGui:FindFirstChild("IYStoreUI"))
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "IYStoreUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CORE end)
if not gui.Parent then gui.Parent = PLR:WaitForChild("PlayerGui") end

-- main ui
win = Instance.new("Frame")
win.Size = UDim2.new(0.9, 0, 0.85, 0)
win.Position = winPos
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.BackgroundColor3 = Color3.fromRGB(15,15,17)
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Visible = false

local max_s = Instance.new("UISizeConstraint")
max_s.MaxSize = Vector2.new(460, 500)
max_s.Parent = win

local w_crn = Instance.new("UICorner")
w_crn.CornerRadius = UDim.new(0, 4)
w_crn.Parent = win

local stroke = Instance.new("UIStroke") 
stroke.Color = Color3.fromRGB(40,40,45)
stroke.Parent = win

local ws = Instance.new("UIScale")
ws.Parent = win

dragGUI(win)

local top = Instance.new("Frame")
top.Size=UDim2.new(1,0,0,40)
top.BackgroundColor3=Color3.fromRGB(20,20,23)
top.BorderSizePixel=0
top.Parent = win

local top_bline = Instance.new("Frame")
top_bline.Size = UDim2.new(1,0,0,1)
top_bline.Position = UDim2.new(0,0,1,0)
top_bline.BackgroundColor3=Color3.fromRGB(35,35,40)
top_bline.BorderSizePixel=0
top_bline.Parent = top

local txt = Instance.new("TextLabel")
txt.Text = "Plugin Store" 
txt.TextColor3 = Color3.fromRGB(240,240,240)
txt.BackgroundTransparency = 1 
txt.Size = UDim2.new(1,-60,1,0)
txt.Position = UDim2.new(0,14,0,0)
txt.TextXAlignment = Enum.TextXAlignment.Left 
txt.Font = Enum.Font.GothamMedium
txt.TextSize = 14 
txt.Parent = top

local close = Instance.new("TextButton")
close.Text="X"
close.Size=UDim2.new(0,40,1,0)
close.Position=UDim2.new(1,-40,0,0)
close.BackgroundColor3=Color3.fromRGB(20,20,23)
close.TextColor3=Color3.fromRGB(220,90,90)
close.Font=Enum.Font.GothamMedium
close.TextSize=14
close.BorderSizePixel=0
close.AutoButtonColor = true
close.Parent = top

local min = Instance.new("TextButton")
min.Text="-" 
min.Size=UDim2.new(0,40,1,0)
min.Position=UDim2.new(1,-80,0,0)
min.BackgroundColor3=Color3.fromRGB(20,20,23)
min.TextColor3=Color3.fromRGB(160,160,160)
min.Font=Enum.Font.GothamMedium
min.TextSize=16
min.BorderSizePixel=0
min.AutoButtonColor = true
min.Parent = top

local box = Instance.new("TextBox")
box.PlaceholderText = " Search exact filenames (e.g. kill.iy)" 
box.Text = ""
box.Size = UDim2.new(1,-24,0,32)
box.Position = UDim2.new(0,12,0,52)
box.BackgroundColor3 = Color3.fromRGB(22,22,26)
box.TextColor3 = Color3.fromRGB(240,240,240)
box.PlaceholderColor3 = Color3.fromRGB(110,110,110)
box.BorderSizePixel = 0
box.Font = Enum.Font.Gotham
box.TextSize = 13
box.TextXAlignment = Enum.TextXAlignment.Left

local bx_p = Instance.new("UIPadding")
bx_p.PaddingLeft = UDim.new(0, 10)
bx_p.Parent = box

local bx_crn = Instance.new("UICorner")
bx_crn.CornerRadius = UDim.new(0, 4)
bx_crn.Parent = box

local bx_st = Instance.new("UIStroke")
bx_st.Color = Color3.fromRGB(45,45,50)
bx_st.Parent = box

box.Parent = win

local scrl = Instance.new("ScrollingFrame")
scrl.Size = UDim2.new(1,-20,1,-100)
scrl.Position = UDim2.new(0,10,0,94)
scrl.BackgroundColor3 = Color3.fromRGB(15,15,17)
scrl.BorderSizePixel = 0
scrl.ScrollBarThickness = 2
scrl.ScrollBarImageColor3 = Color3.fromRGB(70,70,75)
scrl.CanvasSize = UDim2.new(0,0,0,0)
scrl.AutomaticCanvasSize = Enum.AutomaticSize.Y

local gl = Instance.new("UIGridLayout")
gl.CellPadding = UDim2.new(0,8,0,8)
gl.CellSize = UDim2.new(0.5,-4,0,52)
gl.HorizontalAlignment = Enum.HorizontalAlignment.Center
gl.Parent = scrl

scrl.Parent = win

-- info popup
local info = Instance.new("Frame")
info.Size=UDim2.new(0.95, 0, 0.9, 0)
info.Position=UDim2.new(0.5, 0, 0.5, 0)
info.AnchorPoint=Vector2.new(0.5, 0.5)
info.BackgroundColor3=Color3.fromRGB(18,18,22)
info.BorderSizePixel=0 
info.ZIndex=15
info.Visible=false 

local i_max = Instance.new("UISizeConstraint")
i_max.MaxSize = Vector2.new(420, 400)
i_max.Parent = info

local i_crn = Instance.new("UICorner")
i_crn.CornerRadius = UDim.new(0, 5)
i_crn.Parent = info

local strk2 = Instance.new("UIStroke") 
strk2.Color=Color3.fromRGB(50,50,55) 
strk2.Parent=info

local is = Instance.new("UIScale")
is.Parent = info

local ititle = Instance.new("TextLabel")
ititle.Size=UDim2.new(1,-24,0,36)
ititle.Position=UDim2.new(0,12,0,8)
ititle.BackgroundTransparency=1
ititle.TextColor3=Color3.fromRGB(240,240,240)
ititle.Font=Enum.Font.GothamBold
ititle.TextSize=18
ititle.ZIndex=16
ititle.TextXAlignment=Enum.TextXAlignment.Left
ititle.Parent = info

local ititle_bl = Instance.new("Frame")
ititle_bl.Size = UDim2.new(1,-24,0,1)
ititle_bl.Position = UDim2.new(0,12,0,44)
ititle_bl.BackgroundColor3=Color3.fromRGB(35,35,40)
ititle_bl.BorderSizePixel=0
ititle_bl.ZIndex=16
ititle_bl.Parent = info

local iscroll = Instance.new("ScrollingFrame")
iscroll.Size=UDim2.new(1,-24,1,-100)
iscroll.Position=UDim2.new(0,12,0,52)
iscroll.BackgroundTransparency=1
iscroll.CanvasSize=UDim2.new(0,0,0,0)
iscroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
iscroll.ScrollBarThickness=2
iscroll.ZIndex=16
iscroll.ScrollBarImageColor3=Color3.fromRGB(70,70,75)

local uill = Instance.new("UIListLayout") 
uill.Padding=UDim.new(0,8)
uill.Parent = iscroll
iscroll.Parent = info

local downbtn = Instance.new("TextButton")
downbtn.Text="Install"
downbtn.Size=UDim2.new(0.5,-16,0,36)
downbtn.Position=UDim2.new(0,12,1,-42)
downbtn.BackgroundColor3=Color3.fromRGB(0,140,255)
downbtn.TextColor3=Color3.fromRGB(255,255,255)
downbtn.Font=Enum.Font.GothamMedium
downbtn.TextSize=14
downbtn.ZIndex=16
downbtn.BorderSizePixel=0
local dn_crn = Instance.new("UICorner") 
dn_crn.CornerRadius=UDim.new(0,4)
dn_crn.Parent=downbtn
downbtn.Parent = info

local bckbtn = Instance.new("TextButton")
bckbtn.Text="Close"
bckbtn.Size=UDim2.new(0.5,-16,0,36)
bckbtn.Position=UDim2.new(0.5,4,1,-42)
bckbtn.BackgroundColor3=Color3.fromRGB(35,35,40)
bckbtn.TextColor3=Color3.fromRGB(220,220,220)
bckbtn.BorderSizePixel=0
bckbtn.ZIndex=16
bckbtn.Font=Enum.Font.GothamMedium
bckbtn.TextSize=14
local bk_crn = Instance.new("UICorner") 
bk_crn.CornerRadius=UDim.new(0,4)
bk_crn.Parent=bckbtn
bckbtn.Parent=info

info.Parent = gui
win.Parent = gui

-- floaty button for minimized
local fbtn = Instance.new("TextButton")
fbtn.Text="Store"
fbtn.Size=UDim2.new(0,60,0,30)
fbtn.Position=UDim2.new(1,-70,0,10)
fbtn.BackgroundColor3=Color3.fromRGB(0,140,255)
fbtn.TextColor3=Color3.fromRGB(255,255,255)
fbtn.Visible=true
fbtn.Font=Enum.Font.GothamBold
fbtn.TextSize=12
fbtn.BorderSizePixel=0
local crn = Instance.new("UICorner") 
crn.CornerRadius=UDim.new(0,4) 
crn.Parent=fbtn

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

local function gettime(iso) -- sort dates
	if not iso then return 0 end
	local y,m,d,h,mi,s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
	if not y then return 0 end
	return y*31536000+m*2592000+d*86400+h*3600+mi*60+s
end

local function dl_plugin(p, b)
	task.spawn(function()
		if b then b.Text = "..." end
		local s = {}
		for _,f in pairs(p.files or {}) do
			if f.filename:lower():match("%.iy$") then
				local targetUrl = HS:UrlEncode(API.."/"..f.url)
				local trackerUrl = "https://iy-analytics.renern.workers.dev/load/"..p.id.."?url="..targetUrl
				local o,c = pcall(function() return game:HttpGet(trackerUrl) end)
				if o and c then
					pcall(function() writefile(f.filename, c) end)
					table.insert(s, f.filename)
				end
			end
		end
		if #s > 0 then
			if b then 
                b.Text = "GOT"
                b.TextColor3 = Color3.fromRGB(150,255,150)
                b.BackgroundColor3 = Color3.fromRGB(40,40,45)
            end
			task.wait(0.2)
			for _,n in pairs(s) do
				pcall(function() 
					local func = addPlugin or (shared and shared.addPlugin)
					if func then func(n) end 
				end)
			end
		else
			if b then 
                b.Text = "ERR"
                b.TextColor3 = Color3.fromRGB(255,80,80)
            end
		end
	end)
end

local function rem_plugin(p, gb, db)
	if not delfile then return end
	for _,f in pairs(p.files or {}) do
		if f.filename:lower():match("%.iy$") then
			pcall(function()
				local del = deletePlugin or (shared and shared.deletePlugin)
				if del then del(f.filename) end
			end)
			pcall(function() delfile(f.filename) end)
		end
	end
	if gb then
        gb.Text = "GET"
        gb.TextColor3 = Color3.fromRGB(255,255,255)
        gb.BackgroundColor3 = Color3.fromRGB(0,140,255)
    end
	if db then db.Visible=false end
end

local function md(s)
	if type(s) ~= "string" or s=="" then return "" end
	s = s:gsub("<@!?%d+>","@user")
	s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
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

local function applyImage(url, img)
	task.spawn(function()
		local o,c = pcall(function() return game:HttpGet(url) end)
		if o and c and writefile and getcustomasset then
			local t = "iy_tmp_"..tostring(math.random(1000,9999))..".png"
			pcall(function() writefile(t, c); img.Image = getcustomasset(t) end)
		end
	end)
end

local function showInfo(p)
	local gt = is_got(p)
	cur = p
	for _,x in pairs(iscroll:GetChildren()) do if not x:IsA("UIListLayout") then x:Destroy() end end
	ititle.Text = getTitle(p)
	
	playAnim(info, true)

	local txt = md(p.description)
	if txt ~= "" then
		local t = Instance.new("TextLabel")
		t.Text = txt; t.Size = UDim2.new(1,0,0,0); t.AutomaticSize = Enum.AutomaticSize.Y
		t.ZIndex = 16; t.RichText = true
		t.TextWrapped = true; t.TextColor3 = Color3.fromRGB(180,180,180)
		t.BackgroundTransparency = 1; t.Font = Enum.Font.Gotham; t.TextSize = 13
		t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = iscroll
	end

	if p.embeds then
		for _,em in pairs(p.embeds) do
			if em.title or (em.video and em.video.url) or (em.thumbnail and em.thumbnail.url) or (em.image and em.image.url) then
				local f = Instance.new("Frame")
				f.Size=UDim2.new(1,0,0,0); f.AutomaticSize=Enum.AutomaticSize.Y
				f.BackgroundColor3=Color3.fromRGB(24,24,28); f.BorderSizePixel=0; f.ZIndex=16
				local e_crn = Instance.new("UICorner"); e_crn.CornerRadius = UDim.new(0, 4); e_crn.Parent = f
				local lay = Instance.new("UIListLayout"); lay.Padding=UDim.new(0,6); lay.Parent = f
				
				if em.title then
					local tt = Instance.new("TextLabel")
					tt.Text = em.title; tt.Size = UDim2.new(1,-12,0,22); tt.Position=UDim2.new(0,6,0,0); tt.ZIndex=17
					tt.TextColor3 = Color3.fromRGB(0,140,255); tt.BackgroundTransparency = 1
					tt.Font = Enum.Font.GothamMedium; tt.TextSize = 12; tt.TextXAlignment = Enum.TextXAlignment.Left
					tt.Parent = f
				end
				local d = md(em.description)
				if d ~= "" then
					local dt = Instance.new("TextLabel")
					dt.Text = d; dt.Size = UDim2.new(1,-12,0,0); dt.Position=UDim2.new(0,6,0,0); dt.AutomaticSize = Enum.AutomaticSize.Y
					dt.TextColor3 = Color3.fromRGB(140,140,140); dt.BackgroundTransparency = 1
					dt.ZIndex=17; dt.Font = Enum.Font.Gotham; dt.TextSize = 12; dt.TextXAlignment = Enum.TextXAlignment.Left
					dt.TextWrapped = true; dt.RichText = true; dt.Parent = f
				end
				local iu = (em.image and em.image.url) or (em.thumbnail and em.thumbnail.url)
				if iu then
					local ii = Instance.new("ImageLabel")
					ii.Size = UDim2.new(1,0,0,160); ii.ZIndex=17; ii.ClipsDescendants=true
					ii.BackgroundColor3=Color3.fromRGB(15,15,18); ii.ScaleType = Enum.ScaleType.Fit; ii.Parent = f
					local icrn = Instance.new("UICorner"); icrn.CornerRadius = UDim.new(0,4); icrn.Parent = ii
					applyImage(iu, ii)
				end
				if em.video and em.video.url then
					local vb = Instance.new("TextButton")
					vb.Text = "▶ Copy Video URL"; vb.Size = UDim2.new(1,0,0,26); vb.ZIndex=17
					vb.BackgroundColor3 = Color3.fromRGB(35,35,40)
					vb.TextColor3 = Color3.fromRGB(240,240,240)
					vb.Font = Enum.Font.GothamMedium; vb.TextSize = 12
					local vb_crn = Instance.new("UICorner"); vb_crn.CornerRadius = UDim.new(0,4); vb_crn.Parent = vb
					vb.MouseButton1Click:Connect(function() if setclipboard then setclipboard(em.video.url) end end)
					vb.Parent = f
				end
				local p_pad = Instance.new("UIPadding")
				p_pad.PaddingTop=UDim.new(0,6); p_pad.PaddingBottom=UDim.new(0,6)
				p_pad.PaddingLeft=UDim.new(0,6); p_pad.PaddingRight=UDim.new(0,6); p_pad.Parent = f
				f.Parent = iscroll
			end
		end
	end

	downbtn.Text = gt and "Installed" or "Install"
	downbtn.TextColor3 = gt and Color3.fromRGB(150,255,150) or Color3.fromRGB(255,255,255)
	downbtn.BackgroundColor3 = gt and Color3.fromRGB(35,35,40) or Color3.fromRGB(0,140,255)
end

downbtn.MouseButton1Click:Connect(function()
	if not cur then return end
	if is_got(cur) then return end
	dl_plugin(cur, downbtn)
end)
bckbtn.MouseButton1Click:Connect(function() 
	playAnim(info, false)
	cur = nil 
end)

local function draw_list(ls)
	for _,c in pairs(scrl:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	for _,p in pairs(ls) do
		local gt = is_got(p)
		local c = Instance.new("TextButton")
		c.Text=""
		c.BackgroundColor3=Color3.fromRGB(22,22,25); c.BorderSizePixel=0
        c.AutoButtonColor = true
		c.MouseButton1Click:Connect(function() showInfo(p) end)
		
        local c_crn = Instance.new("UICorner")
        c_crn.CornerRadius = UDim.new(0, 4)
        c_crn.Parent = c

        local c_st = Instance.new("UIStroke")
        c_st.Color = Color3.fromRGB(45,45,50)
        c_st.Parent = c

		local n = Instance.new("TextLabel")
		n.Text = getTitle(p)
		n.Size = UDim2.new(1,-52,0,18); n.Position = UDim2.new(0,8,0,6)
		n.TextColor3 = Color3.fromRGB(240,240,240); n.Font = Enum.Font.GothamBold; n.TextSize = 13
		n.TextXAlignment = Enum.TextXAlignment.Left; n.BackgroundTransparency = 1; n.TextTruncate = Enum.TextTruncate.AtEnd
		n.Parent = c

		local a = Instance.new("TextLabel")
		local dstr = p.date and p.date:sub(1,10) or "N/A"
		a.Text = (p.author and p.author.name or "Unknown") .. " • " .. dstr
		a.Size = UDim2.new(1,-52,0,16); a.Position = UDim2.new(0,8,0,26)
		a.TextColor3 = Color3.fromRGB(120,120,120); a.Font = Enum.Font.Gotham; a.TextSize = 11
		a.TextXAlignment = Enum.TextXAlignment.Left; a.BackgroundTransparency = 1; a.TextTruncate = Enum.TextTruncate.AtEnd
		a.Parent = c

		local gb = Instance.new("TextButton")
		gb.Size=UDim2.new(0,40,0,24); gb.Position=UDim2.new(1,-46,0.5,-12)
		gb.BackgroundColor3=gt and Color3.fromRGB(35,35,40) or Color3.fromRGB(0,140,255)
        gb.Font=Enum.Font.GothamBold; gb.TextSize=10; gb.BorderSizePixel=0
        gb.AutoButtonColor=true
		gb.Text = gt and "GOT" or "GET"
		gb.TextColor3 = gt and Color3.fromRGB(150,255,150) or Color3.fromRGB(255,255,255)
		local g_crn = Instance.new("UICorner") g_crn.CornerRadius=UDim.new(0,4); g_crn.Parent=gb
        gb.Parent = c

		local db = Instance.new("TextButton")
		db.Size=UDim2.new(0,24,0,24); db.Position=UDim2.new(1,-74,0.5,-12)
		db.BackgroundColor3=Color3.fromRGB(35,35,40); db.Text="×"; db.TextColor3=Color3.fromRGB(255,100,100)
		db.Font=Enum.Font.GothamBold; db.TextSize=16; db.BorderSizePixel=0
		db.Visible = gt; db.AutoButtonColor=true
		local d_crn = Instance.new("UICorner") d_crn.CornerRadius=UDim.new(0,4); d_crn.Parent=db
        db.Parent = c

		gb.MouseButton1Click:Connect(function()
			if gb.Text ~= "GET" then return end
			dl_plugin(p, gb)
			task.delay(1.5, function() db.Visible = is_got(p) end)
		end)
		db.MouseButton1Click:Connect(function() rem_plugin(p, gb, db) end)
		
		c.Parent = scrl
	end
end

box:GetPropertyChangedSignal("Text"):Connect(function()
	local q = box.Text:lower()
	if q == "" then draw_list(all) return end
	local r = {}
	for _,p in pairs(all) do
		for _,f in pairs(p.files or {}) do
			if f.filename:lower():find(q,1,true) then
				table.insert(r, p)
				break
			end
		end
	end
	draw_list(r)
end)

close.MouseButton1Click:Connect(function() 
	playAnim(win, false, function() gui:Destroy() end)
end)
min.MouseButton1Click:Connect(function() 
	playAnim(win, false, function() fbtn.Visible = true end)
end)

-- load data
pcall(function()
	local raw = game:HttpGet(API.."/data/plugins.json")
	local dat = HS:JSONDecode(raw)
	all = dat.plugins or {}
	for _, p in ipairs(all) do p._ts = gettime(p.date) end
	table.sort(all, function(x,y) return x._ts > y._ts end)
	fbtn.Visible = false
	playAnim(win, true)
	draw_list(all)
end)

-- keepalive
while gui and gui.Parent do task.wait(5) end
