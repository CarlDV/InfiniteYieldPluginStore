-- change file type to .iy before import!

local isEnabled, isPreloaded = false, false
local TRIGGERTHRESHOLD = 420
local DURATIONTHRESHOLD = 5

local Plugin = {
	["PluginName"] = "sigma's edit",
	["PluginDescription"] = "this is how alpha plays roblox",
	["Commands"] = {
		["sigmasedit"] = {
			["ListName"] = "sigmasedit",
			["Description"] = "this is how you as an alpha plays roblox?",
			["Aliases"] = { "sigmaedit" },
			["Function"] = function(args, speaker)
				if isEnabled then
					isEnabled = not isEnabled
					notify("sigma's edit", "is " .. (isEnabled and "on" or "off"))
					return
				end

				isEnabled = true
				notify("sigma's edit", "enabled! stay frosty me frens (cmd + q if stuck in low framerate)")

				local userInputService = game:GetService("UserInputService")
				local contextActionService = game:GetService("ContextActionService")
				local workspace = game:GetService("Workspace")
				local players = game:GetService("Players")
				-- local ContentProvider = game:GetService("ContentProvider")

				local equipEvent = contextActionService.LocalToolEquipped
				local unequipEvent = contextActionService.LocalToolUnequipped
				local inputEvent = userInputService.InputBegan

				-- personally, i think luau's table is nicer than whatever js is
				local sigmas = {
					["image"] = {
						17334028110,
						15729950259,
						137892003660281,
						98357432058989,
						12552431195,
						76090971615079,
						18735477147,
						15563091890,
						13497658487,
						78906920386708,
						18383312122,
						18924353209,
						17337974860,
						16211045192,
						13304453336,
						11393121553,
						127678838552035,
						77987465336971,
						6970682513,
						99747784406996,
						10177679701,
						16740418002,
						7783359239,
						18849681057,
						10009449194,
						122354736220591,
						127588103445571,
						17307559228,
						5274729037,
					},
					["music"] = { -- struct: [id, [point(s) of interest]]
						{ 140667339171815, ["duration"] = { 0, 18, 54 } },
						{ 140521045204459, ["duration"] = { 0, 14, 103 } },
						{ 140667339171815, ["duration"] = { 26, 60 } },
					},
				}

				function preload()
					-- should only call once per init
					if isPreloaded then
						return
					end

					-- 	ContentProvider:PreloadAsync(contents, function(assetId, status)
					-- 		print(status)
					-- 	end)

					notify("sigma's edit (first time init)", "preloading (may slow a lil bit)")
					local mainContainer = Instance.new("ScreenGui", players.LocalPlayer.PlayerGui)
					local preloadFrame = Instance.new("Frame", mainContainer)
					local preloadImg = Instance.new("ImageLabel")
					local preloadAudio = Instance.new("Sound")

					mainContainer.Name = randomString()

					preloadFrame.Name = "preloadFrame"
					preloadFrame.Size = UDim2.new(0, 1, 0, 1)
					preloadFrame.BackgroundTransparency = 1

					preloadImg.Name = randomString()
					preloadImg.Parent = preloadFrame
					preloadImg.Size = UDim2.new(0, 1, 0, 1)
					preloadImg.BackgroundTransparency = 1

					preloadAudio.Name = randomString()
					preloadAudio.Parent = preloadFrame
					preloadAudio.Volume = 0.1

					for _, id in ipairs(sigmas["image"]) do
						preloadImg.Image = "rbxassetid://" .. id
						task.wait(0.1)
					end
					for _, entry in ipairs(sigmas["music"]) do
						preloadAudio.SoundId = "rbxassetid://" .. entry[1]
						task.wait(0.1)
						preloadAudio:Play()
						task.wait(0.1)
						preloadAudio:Stop()
					end

					mainContainer:Destroy()

					isPreloaded = true
					notify("sigma's edit (first time init)", "preloaded!!")
				end
				preload()

				local randomPicked = function(type: "image" | "music" | "duration"): number
					if type == "duration" then
						local entry = sigmas["music"][math.random(1, #sigmas["music"])]
						local durations = entry["duration"]
						return durations[math.random(1, #durations)]
					end

					if type == "image" then
						return sigmas["image"][math.random(1, #sigmas["image"])]
					end

					return sigmas["music"][math.random(1, #sigmas["music"])][1]
				end

				local shouldBeTriggered = function(): boolean
					return math.random(1, TRIGGERTHRESHOLD) == 1
				end

				-- local img: ImageLabel = workspace:WaitForChild("d").main.img

				local localPlayer = (game:GetService("Players")).LocalPlayer
				local mainContainer = Instance.new("ScreenGui", localPlayer.PlayerGui)
				local imageLabel = Instance.new("ImageLabel", mainContainer)
				local musicPlayer = Instance.new("Sound", mainContainer)
				local fadeOverlay = Instance.new("Frame", mainContainer)

				mainContainer.Name = randomString()

				imageLabel.Name = randomString()
				imageLabel.AnchorPoint = Vector2.new(0.5, 1)
				imageLabel.Position = UDim2.new(0.5, 0, 0.95, 0)
				imageLabel.Size = UDim2.new(0.2, 0, 0.3, 0)
				imageLabel.ZIndex = 2
				imageLabel.BorderSizePixel = 0
				imageLabel.BackgroundTransparency = 1

				fadeOverlay.Name = randomString()
				fadeOverlay.Visible = false
				fadeOverlay.AnchorPoint = Vector2.new(0.5, 0.5)
				fadeOverlay.Position = UDim2.new(0.5, 0, 0.5, 0)
				fadeOverlay.Size = UDim2.new(2, 0, 2, 0)
				fadeOverlay.BackgroundColor3 = Color3.new(119, 119, 119)
				fadeOverlay.BackgroundTransparency = 0.4

				musicPlayer.Name = "sigma_audio"
				musicPlayer.Volume = 0.67
				musicPlayer.Playing = false
				musicPlayer.Parent = workspace

				local fpsCapThread: thread | nil = nil
				function fpsCap(target: number | nil)
					if fpsCapThread then
						task.cancel(fpsCapThread)
					end

					if not target then
						fpsCap(math.huge)
						return
					end

					local targetFps = math.floor(target) <= 0 and 1 or math.floor(target)
					-- built in setfpscap is... so-so
					-- lets torment cpu

					-- if setfpscap and type(setfpscap) == "function" then
					-- 	setfpscap(targetFps)
					-- else

					fpsCapThread = task.spawn(function()
						local timer = os.clock()
						while true do
							if os.clock() >= timer + 1 / targetFps then
								timer = os.clock()
								task.wait()
							end
						end
					end)
				end

				local isDebaunce: boolean = false
				local function playRandom()
					if not shouldBeTriggered() or isDebaunce then
						return
					end

					isDebaunce = true

					-- preloadElement({
					-- 	"rbxtextureid://" .. randomPicked("image"),
					-- 	"rbxassetid://" .. randomPicked("music"),
					-- })

					imageLabel.Image = "rbxassetid://" .. randomPicked("image")
					musicPlayer.SoundId = "rbxassetid://" .. randomPicked("music")
					musicPlayer.TimePosition = randomPicked("duration")

					musicPlayer.Playing = true
					fadeOverlay.Visible = true
					imageLabel.Visible = true

					-- .1 hangs the whole engine
					-- 1 looks like powerpoint
					task.wait(0.45)
					fpsCap(0.6)

					task.delay(DURATIONTHRESHOLD, function()
						fpsCap()
						fadeOverlay.Visible = false

						imageLabel.Visible = false
						imageLabel.Image = ""

						musicPlayer.Playing = false
						musicPlayer.TimePosition = 0

						isDebaunce = false
					end)

					-- print("stopping...")
				end

				if isEnabled then
					task.delay(0.5, function()
						equipEvent:Connect(function(_)
							playRandom()
						end)

						unequipEvent:Connect(function(_)
							playRandom()
						end)

						inputEvent:Connect(function(_, __)
							playRandom()
						end)
					end)
				else
					equipEvent:Disconnect()
					unequipEvent:Disconnect()
					inputEvent:Disconnect()
				end
			end,
		},
		["sigmathreshold"] = {
			["ListName"] = "sigmathreshold [number]",
			["Description"] = "define the threshold to trigger the sigma's edit (default is "
				.. TRIGGERTHRESHOLD
				.. ") (higher = less frequent)",
			["Aliases"] = { "sigmaamount" },
			["Function"] = function(args, speaker)
				local numArg = tonumber(args[1])
				if type(numArg) ~= "number" or numArg <= 0 then
					notify(
						"sigma's edit (threshold val err)",
						"expected CORRECT number argument ( n num > 0 , type as 'number')"
					)
					return
				end

				if numArg <= 50 then
					notify("sigma's edit (low threshold val warn)", "might cause significant inconvenience")
				end

				TRIGGERTHRESHOLD = numArg or TRIGGERTHRESHOLD
				notify(
					"sigma's edit (threshold changed)",
					"threshold set to "
						.. TRIGGERTHRESHOLD
						.. "."
						.. (TRIGGERTHRESHOLD > 1000 and " (..and okay i can tell that you are mad)" or "")
				)
			end,
		},
		-- ["togglesigmasedit"] = {
		-- 	["ListName"] = "togglesigmasedit",
		-- 	["Description"] = "toggle the sigma's edit",
		-- 	["Aliases"] = { "togglesigmaedit" },
		-- 	["Function"] = function(args, speaker)
		-- 		isEnabled = not isEnabled
		-- 		notify("sigma's edit", "effect: " .. tostring(isEnabled))
		-- 	end,
		-- },
	},
}

return Plugin
