-- IY plugin store 

local HS = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local CORE = game:GetService("CoreGui")
local PLR = game:GetService("Players").LocalPlayer

task.spawn(function()
    pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end)
end)

local API = "https://iyplugins.pages.dev"
local all = {}
local got_plugs = {}
local cfg = "iy_store_plugins.json"
local cur = nil

if isfile and isfile(cfg) then 
	pcall(function() got_plugs = HS:JSONDecode(readfile(cfg)) end) 
end

local function save()
	if writefile then pcall(function() writefile(cfg, HS:JSONEncode(got_plugs)) end) end
end

local function dragGUI(obj)
	local d,ds,dp = false,nil,nil
	obj.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true; ds = i.Position; dp = obj.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local dt = i.Position - ds
			obj.Position = UDim2.new(dp.X.Scale, dp.X.Offset+dt.X, dp.Y.Scale, dp.Y.Offset+dt.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "IYStoreUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CORE end)
if not gui.Parent then gui.Parent = PLR:WaitForChild("PlayerGui") end

-- main ui
local win = Instance.new("Frame")
win.Size = UDim2.new(0,520,0,420)
win.Position = UDim2.new(0.5,-260,0.5,-210)
win.BackgroundColor3 = Color3.fromRGB(15,15,15)
win.BorderSizePixel = 0
win.Parent = gui
win.Visible = false
local stroke = Instance.new("UIStroke") stroke.Color=Color3.fromRGB(45,45,45); stroke.Parent=win
dragGUI(win)

local top = Instance.new("Frame",win)
top.Size=UDim2.new(1,0,0,30); top.BackgroundColor3=Color3.fromRGB(25,25,25)
top.BorderSizePixel=0

local txt = Instance.new("TextLabel")
txt.Text = "  Plugin" txt.TextColor3 = Color3.fromRGB(255,255,255)
txt.BackgroundTransparency = 1; txt.Size = UDim2.new(1,-60,1,0)
txt.TextXAlignment = Enum.TextXAlignment.Left; txt.Font = Enum.Font.GothamBold
txt.TextSize = 14; txt.Parent = top

local close = Instance.new("TextButton",top)
close.Text="X"; close.Size=UDim2.new(0,30,1,0); close.Position=UDim2.new(1,-30,0,0)
close.BackgroundColor3=Color3.fromRGB(180,50,50); close.TextColor3=Color3.fromRGB(255,255,255)
close.Font=Enum.Font.GothamBold; close.BorderSizePixel=0

local min = Instance.new("TextButton")
min.Text="-" min.Size=UDim2.new(0,30,1,0); min.Position=UDim2.new(1,-60,0,0)
min.BackgroundColor3=Color3.fromRGB(45,45,45); min.TextColor3=Color3.fromRGB(255,255,255)
min.Font=Enum.Font.GothamBold; min.BorderSizePixel=0; min.Parent=top

local box = Instance.new("TextBox")
box.PlaceholderText = " search..." box.Text = ""
box.Size = UDim2.new(1,-16,0,26); box.Position = UDim2.new(0,8,0,36)
box.BackgroundColor3 = Color3.fromRGB(30,30,30); box.TextColor3 = Color3.fromRGB(255,255,255)
box.BorderSizePixel = 0; box.Font = Enum.Font.Gotham; box.TextSize = 13
box.TextXAlignment = Enum.TextXAlignment.Left; box.Parent = win

local scrl = Instance.new("ScrollingFrame",win)
scrl.Size = UDim2.new(1,-16,1,-72); scrl.Position = UDim2.new(0,8,0,68)
scrl.BackgroundColor3 = Color3.fromRGB(12,12,12); scrl.BorderSizePixel = 0
scrl.ScrollBarThickness = 2; scrl.CanvasSize = UDim2.new(0,0,0,0)
scrl.AutomaticCanvasSize = Enum.AutomaticSize.Y

local gl = Instance.new("UIGridLayout")
gl.CellPadding = UDim2.new(0,4,0,4); gl.CellSize = UDim2.new(0.5,-2,0,42); gl.Parent = scrl

-- info popup
local info = Instance.new("Frame")
info.Size=UDim2.new(0,360,0,300); info.Position=UDim2.new(0.5,-180,0.5,-150)
info.BackgroundColor3=Color3.fromRGB(18,18,18); info.BorderSizePixel=0; info.Visible=false 
info.Parent=gui
local strk2 = Instance.new("UIStroke") strk2.Color=Color3.fromRGB(50,50,50) strk2.Parent=info

local ititle = Instance.new("TextLabel",info)
ititle.Size=UDim2.new(1,-16,0,26); ititle.Position=UDim2.new(0,8,0,4)
ititle.BackgroundTransparency=1; ititle.TextColor3=Color3.fromRGB(255,255,255)
ititle.Font=Enum.Font.GothamBold; ititle.TextSize=15; ititle.TextXAlignment=Enum.TextXAlignment.Left

local iscroll = Instance.new("ScrollingFrame",info)
iscroll.Size=UDim2.new(1,-16,1,-96); iscroll.Position=UDim2.new(0,8,0,32)
iscroll.BackgroundTransparency=1; iscroll.CanvasSize=UDim2.new(0,0,0,0)
iscroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; iscroll.ScrollBarThickness=2
local uill = Instance.new("UIListLayout",iscroll) uill.Padding=UDim.new(0,4)

local downbtn = Instance.new("TextButton",info)
downbtn.Text="get"; downbtn.Size=UDim2.new(0.5,-12,0,26); downbtn.Position=UDim2.new(0,8,1,-32)
downbtn.BackgroundColor3=Color3.fromRGB(0,120,0); downbtn.TextColor3=Color3.fromRGB(255,255,255)
downbtn.Font=Enum.Font.GothamBold; downbtn.TextSize=12; downbtn.BorderSizePixel=0

local bckbtn = Instance.new("TextButton")
bckbtn.Text="back"; bckbtn.Size=UDim2.new(0.5,-12,0,26); bckbtn.Position=UDim2.new(0.5,4,1,-32)
bckbtn.BackgroundColor3=Color3.fromRGB(35,35,35); bckbtn.TextColor3=Color3.fromRGB(255,255,255)
bckbtn.BorderSizePixel=0; bckbtn.Font=Enum.Font.Gotham; bckbtn.TextSize=12; bckbtn.Parent=info

-- floaty button for minimized
local fbtn = Instance.new("TextButton",gui)
fbtn.Text="Plugin"; fbtn.Size=UDim2.new(0,80,0,26); fbtn.Position=UDim2.new(1,-90,0,8)
fbtn.BackgroundColor3=Color3.fromRGB(20,20,20); fbtn.TextColor3=Color3.fromRGB(255,255,255)
fbtn.Visible=true; fbtn.Font=Enum.Font.GothamBold; fbtn.TextSize=11
local strk3 = Instance.new("UIStroke") strk3.Color=Color3.fromRGB(50,50,50) strk3.Parent=fbtn
local crn = Instance.new("UICorner") crn.CornerRadius=UDim.new(0,5) crn.Parent=fbtn

local drag_f, org = false, nil
fbtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag_f = true; org = i.Position
		local sp = fbtn.Position
		local c
		c = UIS.InputChanged:Connect(function(j)
			if not drag_f then c:Disconnect() return end
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
			win.Visible = true; fbtn.Visible = false
		end
		drag_f = false; org = nil
	end
end)

local function gettime(iso) -- sort datesx
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
				local o,c = pcall(function() return game:HttpGet(API.."/"..f.url) end)
				if o and c then
					pcall(function() writefile(f.filename, c) end)
					table.insert(s, f.filename)
				end
			end
		end
		if #s > 0 then
			got_plugs[p.id] = true; save()
			if b then b.Text = "got"; b.TextColor3 = Color3.fromRGB(100,255,100) end
			task.wait(0.2)
			for _,n in pairs(s) do
				pcall(function() 
					local func = addPlugin or (shared and shared.addPlugin)
					if func then func(n) end 
				end)
			end
		else
			if b then b.Text = "err"; b.TextColor3 = Color3.fromRGB(255,80,80) end
		end
	end)
end

local function rem_plugin(p, gb, db)
	if not delfile then return end
	for _,f in pairs(p.files or {}) do
		if f.filename:lower():match("%.iy$") then pcall(function() delfile(f.filename) end) end
	end
	got_plugs[p.id] = nil; save()
	if gb then gb.Text="get"; gb.TextColor3=Color3.fromRGB(255,255,255) end
	if db then db.Visible=false end
end

local function fixStr(s) -- clear discord markdow
	if not s or s=="" then return "" end
	return s:gsub("<@!?%d+>","@user"):gsub("```%w*\n?",""):gsub("```",""):gsub("%*%*",""):gsub("__",""):gsub("~~","")
end

local function showInfo(p)
	cur = p
	for _,x in pairs(iscroll:GetChildren()) do if not x:IsA("UIListLayout") then x:Destroy() end end
	ititle.Text = p.name or "idk"
	info.Visible = true

	local txt = fixStr(p.description)
	if txt ~= "" then
		local t = Instance.new("TextLabel")
		t.Text = txt; t.Size = UDim2.new(1,0,0,0); t.AutomaticSize = Enum.AutomaticSize.Y
		t.TextWrapped = true; t.TextColor3 = Color3.fromRGB(180,180,180)
		t.BackgroundTransparency = 1; t.Font = Enum.Font.Gotham; t.TextSize = 12
		t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = iscroll
	end

	if p.embeds then
		for _,em in pairs(p.embeds) do
			if em.title or (em.video and em.video.url) then
				local f = Instance.new("Frame",iscroll); f.Size=UDim2.new(1,0,0,0)
				f.AutomaticSize=Enum.AutomaticSize.Y; f.BackgroundColor3=Color3.fromRGB(28,28,28); f.BorderSizePixel=0
				local lay = Instance.new("UIListLayout",f) lay.Padding=UDim.new(0,2)
				if em.title then
					local tt = Instance.new("TextLabel",f); tt.Text = em.title; tt.Size = UDim2.new(1,0,0,16)
					tt.TextColor3 = Color3.fromRGB(80,140,255); tt.BackgroundTransparency = 1
					tt.Font = Enum.Font.GothamBold; tt.TextSize = 11; tt.TextXAlignment = Enum.TextXAlignment.Left
				end
				if em.video and em.video.url then
					local vv = Instance.new("TextLabel",f); vv.Text = em.video.url; vv.Size = UDim2.new(1,0,0,14)
					vv.TextColor3 = Color3.fromRGB(120,120,120); vv.BackgroundTransparency = 1
					vv.TextSize = 9; vv.TextXAlignment = Enum.TextXAlignment.Left
				end
			end
		end
	end

	downbtn.Text = got_plugs[p.id] and "got" or "get"
	downbtn.TextColor3 = got_plugs[p.id] and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,255,255)
	downbtn.BackgroundColor3 = got_plugs[p.id] and Color3.fromRGB(35,35,35) or Color3.fromRGB(0,120,0)
end

downbtn.MouseButton1Click:Connect(function()
	if not cur then return end
	if got_plugs[cur.id] then return end
	dl_plugin(cur, downbtn)
end)
bckbtn.MouseButton1Click:Connect(function() info.Visible = false cur = nil end)

function draw_list(ls)
	for _,c in pairs(scrl:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for _,p in pairs(ls) do
		local c = Instance.new("Frame",scrl)
		c.BackgroundColor3=Color3.fromRGB(20,20,20); c.BorderSizePixel=0

		local h = Instance.new("TextButton",c); h.Text=""; h.Size=UDim2.new(1,-65,1,0); h.BackgroundTransparency=1
		h.MouseButton1Click:Connect(function() showInfo(p) end)

		local n = Instance.new("TextLabel",h); n.Text = p.name or "nan"
		n.Size = UDim2.new(1,0,0,20); n.Position = UDim2.new(0,6,0,2)
		n.TextColor3 = Color3.fromRGB(255,255,255); n.Font = Enum.Font.GothamBold; n.TextSize = 11
		n.TextXAlignment = Enum.TextXAlignment.Left; n.BackgroundTransparency = 1; n.TextTruncate = Enum.TextTruncate.AtEnd

		local a = Instance.new("TextLabel",h); a.Text = p.author and p.author.name or "nan"
		a.Size = UDim2.new(1,0,0,12); a.Position = UDim2.new(0,6,0,21)
		a.TextColor3 = Color3.fromRGB(100,100,100); a.Font = Enum.Font.Gotham; a.TextSize = 9
		a.TextXAlignment = Enum.TextXAlignment.Left; a.BackgroundTransparency = 1

		local gb = Instance.new("TextButton",c); gb.Size=UDim2.new(0,32,0,18); gb.Position=UDim2.new(1,-62,0.5,-9)
		gb.BackgroundColor3=Color3.fromRGB(35,35,35); gb.Font=Enum.Font.GothamBold; gb.TextSize=9; gb.BorderSizePixel=0
		gb.Text = got_plugs[p.id] and "got" or "get"
		gb.TextColor3 = got_plugs[p.id] and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,255,255)

		local db = Instance.new("TextButton",c); db.Size=UDim2.new(0,18,0,18); db.Position=UDim2.new(1,-26,0.5,-9)
		db.BackgroundColor3=Color3.fromRGB(35,35,35); db.Text="x"; db.TextColor3=Color3.fromRGB(255,80,80)
		db.Font=Enum.Font.GothamBold; db.TextSize=10; db.BorderSizePixel=0
		db.Visible = got_plugs[p.id] and true or false

		gb.MouseButton1Click:Connect(function()
			if gb.Text ~= "get" then return end
			dl_plugin(p, gb)
			task.delay(1.5, function() db.Visible = got_plugs[p.id] and true or false end)
		end)
		db.MouseButton1Click:Connect(function() rem_plugin(p, gb, db) end)
	end
end

box:GetPropertyChangedSignal("Text"):Connect(function()
	local q = box.Text:lower()
	if q == "" then draw_list(all) return end
	local r = {}
	for _,p in pairs(all) do
		if (p.name or ""):lower():find(q,1,true) or (p.author and p.author.name or ""):lower():find(q,1,true) then
			table.insert(r, p)
		end
	end
	draw_list(r)
end)

close.MouseButton1Click:Connect(function() gui:Destroy() end)
min.MouseButton1Click:Connect(function() win.Visible = false; fbtn.Visible = true end)

-- load data
pcall(function()
	--print("fetching plugins...")
	local raw = game:HttpGet(API.."/data/plugins.json")
	local dat = HS:JSONDecode(raw)
	all = dat.plugins or {}
	table.sort(all, function(x,y) return gettime(x.date) > gettime(y.date) end)
	win.Visible = true
	fbtn.Visible = false
	draw_list(all)
end)
