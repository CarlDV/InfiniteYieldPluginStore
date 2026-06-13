if not readfile and not writefile and not request then
	notify(
		"prideYield ",
		"readfile(), writefile(), and request() do not exist, please remove the plugin, or change your exec"
	)
	return
end

local isPrideMonth = os.date("*t").month == 6

if not isPrideMonth then
	-- print(isPrideMonth)
	return
end

local rfSuccess, _ = pcall(function()
	return readfile("prideYield.png")
end)

if not rfSuccess then
	local imgCDN = request({
		Url = "https://share.valhalladev.org/raw/New%20Project2.png",
		Method = "GET",
	})
	-- print(imgCDN.StatusCode)
	if imgCDN.Success and imgCDN.StatusCode == 200 then
		writefile("prideYield.png", imgCDN.Body)
	else
		notify("prideYield", `cdn error: {imgCDN.StatusCode} {imgCDN.StatusMessage or ""}`)
		return
	end
end

local succ, err = pcall(function()
	local localImg = getcustomasset("prideYield.png")
	Logo.Image = localImg
end)

-- print(succ)

if not succ then
	notify("prideYield", `unable to init: {err}`)
	return
end

local Plugin = {
	["PluginName"] = "prideYield",
	["PluginDescription"] = "shows your support in iy",
	["Commands"] = {
		["aboutprideYield"] = {
			["ListName"] = "aboutprideYield",
			["Description"] = "about prideYield",
			["Aliases"] = { "prideyield" },
			["Function"] = function(args, speaker)
				local out = `prideYield, hhh, '26 (isPrideMonth?: {isPrideMonth}`
				print(out)
				notify("prideYield", out)
			end,
		},
	},
}

return Plugin
