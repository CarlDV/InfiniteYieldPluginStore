local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local skibidiSave = function(image, transparency)
	local settings = HttpService:JSONDecode(readfile("wallpapersettings.json"))
	settings["image"] = image
	settings["imagetransparency"] = transparency
	writefile("wallpapersettings.json", HttpService:JSONEncode(settings))
end

local Wallpaper = Instance.new("ImageLabel")
Wallpaper.Parent = Dark
Wallpaper.Size = UDim2.new(1,0,1,0)
Wallpaper.BackgroundTransparency = 1
Wallpaper.ImageTransparency = 0.4
Wallpaper.ZIndex = 10

local spriteCoroutine
function imageSprite(imgw, imgh, w, h, frames, fps)
	local fps = 1 / fps
	Wallpaper.ImageRectSize = Vector2.new(w,h)
	while true do
		local row = 0
		local column = 0
		for i = 1, frames do
			local x = row * w
			local y = column * h
			Wallpaper.ImageRectOffset = Vector2.new(x,y)
			row += 1
			if x == (imgw - w) then
				row = 0
				column += 1
			end
			task.wait(fps)
		end
	end
end
function loadImage(image)
	local isSprite = false
	if string.match(image, "^file://") then
		Wallpaper.Image = getcustomasset(string.gsub(image, "file://", ""))
	elseif string.match(image, "^sprite://") then
		isSprite = true
		local spriteInfo = HttpService:JSONDecode(readfile(string.gsub(image, "sprite://", "")))
		if string.match(spriteInfo["image"], "^file://") then
			Wallpaper.Image = getcustomasset(string.gsub(spriteInfo["image"], "file://", ""))
		else
			Wallpaper.Image = sprite["image"]
		end
		--coroutine.close(spriteCoroutine)
		spriteCoroutine = coroutine.create(imageSprite)
		coroutine.resume(spriteCoroutine, spriteInfo["imgw"], spriteInfo["imgh"], spriteInfo["w"], spriteInfo["h"], spriteInfo["frames"], spriteInfo["fps"])
	else
		Wallpaper.Image = image
	end
	if not isSprite then
		if spriteCoroutine then
			coroutine.close(spriteCoroutine)
			spriteCoroutine = nil
		end
		Wallpaper.ImageRectOffset = Vector2.new(0,0)
		Wallpaper.ImageRectSize = Vector2.new(0,0)
	end
	skibidiSave(image, Wallpaper.ImageTransparency)
end

if not table.find(listfiles("."), "wallpapersettings.json") then
	writefile("wallpapersettings.json", HttpService:JSONEncode({image = "", imagetransparency = 0.4}))
else
	local settings = HttpService:JSONDecode(readfile("wallpapersettings.json"))
	loadImage(settings["image"])
	Wallpaper.ImageTransparency = settings["imagetransparency"]
end

return {
	PluginName = "Wallpaper",
	PluginDescription = "Turn IY's boring solid background into a wallpaper",
	Commands = {
		wallpaper  = {
			ListName = "wallpaper [image]",
			Description = "Changes the Image",
			Aliases = {},
			Function = function(args, speaker)
				image = args[1]
				loadImage(args[1])
			end
		},
		wptransparency = {
			ListName = "wptransparency [number]",
			Description = "Changes the image's transparency",
			Aliases = {},
			Function = function(args, speaker)
				Wallpaper.ImageTransparency = tonumber(args[1])
				skibidiSave(image, tonumber(args[1]))
			end
		},
		wpreset = {
			ListName = "wpreset",
			Description = "Resets the wallpaper",
			Aliases = {},
			Function = function(args, speaker)
				if spriteCoroutine then
					coroutine.close(spriteCoroutine)
					spriteCoroutine = nil
				end
				Wallpaper.Image = ""
				Wallpaper.ImageTransparency = 0.4
				skibidiSave("", 0.4)
			end
		}
	}
}