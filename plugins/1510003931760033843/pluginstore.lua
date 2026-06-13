local Plugin = {
	["PluginName"] = "PluginStore",
	["PluginDescription"] = "Browse and install plugins from the plugin store.",
	["Commands"] = {
		["pluginstore"] = {
			["ListName"] = "pluginstore / ps / store",
			["Description"] = "Open the plugin store GUI to browse and install .iy plugins.",
			["Aliases"] = {"ps", "store"},
			["Function"] = function(args, speaker)
				if not writefileExploit() then
					notify('Plugin Store', 'Your exploit does not support plugins (missing writefile)')
					return
				end

				task.spawn(function()
					local PLUGIN_URL = 'https://raw.githubusercontent.com/corecommit/plugin-store/main/plugins.json'
					local plugins
					local success, result = pcall(function()
						return game:HttpGet(PLUGIN_URL, true)
					end)
					if not success then
						notify('Plugin Store','Failed to connect to plugin store')
						return
					end
					local success2, data = pcall(function()
						return HttpService:JSONDecode(result)
					end)
					if not success2 then
						notify('Plugin Store','Failed to parse plugin data')
						return
					end
					plugins = data

					local storeGui = Instance.new("ScreenGui")
					storeGui.Name = "Plugin Store"
					storeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					storeGui.ResetOnSpawn = false
					storeGui.Parent = game:GetService("CoreGui")

					local function showError(title, message)
						local errGui = Instance.new("ScreenGui")
						errGui.Name = "ErrorPopup"
						errGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
						errGui.ResetOnSpawn = false
						errGui.Parent = game:GetService("CoreGui")

						local box = Instance.new("Frame")
						box.Size = UDim2.new(0.275, 0, 0.199, 0)
						box.AnchorPoint = Vector2.new(0.5, 0.5)
						box.Position = UDim2.new(0.5, 0, 0.5, 0)
						box.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
						box.BorderSizePixel = 0
						box.ZIndex = 11
						box.Parent = errGui

						local corner = Instance.new("UICorner")
						corner.CornerRadius = UDim.new(0.08, 0)
						corner.Parent = box

						local bar = Instance.new("Frame")
						bar.Size = UDim2.new(1, 0, 0.25, 0)
						bar.Position = UDim2.new(0.5, 0, 0.125, 0)
						bar.AnchorPoint = Vector2.new(0.5, 0.5)
						bar.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
						bar.BorderSizePixel = 0
						bar.ZIndex = 12
						bar.Parent = box

						local barCorner = Instance.new("UICorner")
						barCorner.CornerRadius = UDim.new(0.3, 0)
						barCorner.Parent = bar

						local barFix = Instance.new("Frame")
						barFix.Size = UDim2.new(1, 0, 0.5, 0)
						barFix.AnchorPoint = Vector2.new(0.5, 0.5)
						barFix.Position = UDim2.new(0.5, 0, 0.75, 0)
						barFix.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
						barFix.BorderSizePixel = 0
						barFix.ZIndex = 12
						barFix.Parent = bar

						local titleLbl = Instance.new("TextLabel")
						titleLbl.Text = "⚠ " .. title
						titleLbl.Size = UDim2.new(0.971, 0, 1, 0)
						titleLbl.Position = UDim2.new(0.515, 0, 0.5, 0)
						titleLbl.AnchorPoint = Vector2.new(0.5, 0.5)
						titleLbl.BackgroundTransparency = 1
						titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
						titleLbl.TextScaled = true
						titleLbl.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
						titleLbl.TextXAlignment = Enum.TextXAlignment.Left
						titleLbl.ZIndex = 13
						titleLbl.Parent = bar

						local msgLbl = Instance.new("TextLabel")
						msgLbl.Text = message
						msgLbl.Size = UDim2.new(0.941, 0, 0.438, 0)
						msgLbl.Position = UDim2.new(0.5, 0, 0.519, 0)
						msgLbl.AnchorPoint = Vector2.new(0.5, 0.5)
						msgLbl.BackgroundTransparency = 1
						msgLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
						msgLbl.TextWrapped = true
						msgLbl.TextSize = 30
						msgLbl.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
						msgLbl.TextXAlignment = Enum.TextXAlignment.Center
						msgLbl.TextYAlignment = Enum.TextYAlignment.Center
						msgLbl.ZIndex = 12
						msgLbl.Parent = box

						local okBtn = Instance.new("TextButton")
						okBtn.Text = "OK"
						okBtn.Size = UDim2.new(0.294, 0, 0.2, 0)
						okBtn.AnchorPoint = Vector2.new(0.5, 0.5)
						okBtn.Position = UDim2.new(0.5, 0, 0.838, 0)
						okBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
						okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
						okBtn.TextScaled = true
						okBtn.BorderSizePixel = 0
						okBtn.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json")
						okBtn.ZIndex = 12
						okBtn.Parent = box

						local okCorner = Instance.new("UICorner")
						okCorner.CornerRadius = UDim.new(0.3, 0)
						okCorner.Parent = okBtn

						okBtn.MouseButton1Click:Connect(function()
							errGui:Destroy()
						end)
					end

					local function setGuiVisible(gui, state)
						if gui and gui.Parent then
							pcall(function()
								gui.Visible = state
							end)
						end
					end

					local MainFrame = Instance.new("Frame")
					MainFrame.Name = "Main Frame"
					MainFrame.BorderSizePixel = 0
					MainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
					MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
					MainFrame.Size = UDim2.new(0.5, 0, 0.55, 0)
					MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
					MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					MainFrame.Parent = storeGui

					local MainFrameAspectRatio = Instance.new("UIAspectRatioConstraint")
					MainFrameAspectRatio.AspectRatio = 1.40279
					MainFrameAspectRatio.Parent = MainFrame

					local SearchBar = Instance.new("TextBox")
					SearchBar.Name = "SearchBar"
					SearchBar.CursorPosition = -1
					SearchBar.PlaceholderColor3 = Color3.fromRGB(61, 61, 61)
					SearchBar.PlaceholderText = "Search for plugins..."
					SearchBar.Text = ""
					SearchBar.BorderSizePixel = 0
					SearchBar.TextWrapped = true
					SearchBar.TextSize = 35
					SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
					SearchBar.TextScaled = true
					SearchBar.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
					SearchBar.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					SearchBar.AnchorPoint = Vector2.new(0.5, 0.5)
					SearchBar.Size = UDim2.new(1, 0, 0.08, 0)
					SearchBar.Position = UDim2.new(0.5, 0, 0.03957, 0)
					SearchBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
					SearchBar.Visible = false
					SearchBar.ZIndex = 3
					SearchBar.Parent = MainFrame

					local SearchBarAspectRatio = Instance.new("UIAspectRatioConstraint")
					SearchBarAspectRatio.AspectRatio = 17.5349
					SearchBarAspectRatio.Parent = SearchBar

					local Header = Instance.new("TextLabel")
					Header.Name = "Header"
					Header.Text = "Plugin Store"
					Header.TextWrapped = true
					Header.ZIndex = 2
					Header.BorderSizePixel = 0
					Header.TextSize = 14
					Header.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
					Header.TextScaled = true
					Header.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
					Header.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					Header.TextColor3 = Color3.fromRGB(255, 255, 255)
					Header.AnchorPoint = Vector2.new(0.5, 0.5)
					Header.Size = UDim2.new(1, 0, 0.08, 0)
					Header.Position = UDim2.new(0.5, 0, 0.04, 0)
					Header.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Header.Parent = MainFrame

					local HeaderAspectRatio = Instance.new("UIAspectRatioConstraint")
					HeaderAspectRatio.AspectRatio = 17.5349
					HeaderAspectRatio.Parent = Header

					local CloseButton = Instance.new("TextButton")
					CloseButton.Text = "X"
					CloseButton.TextWrapped = true
					CloseButton.BorderSizePixel = 0
					CloseButton.TextSize = 14
					CloseButton.AutoButtonColor = false
					CloseButton.TextScaled = true
					CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					CloseButton.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
					CloseButton.BackgroundTransparency = 1
					CloseButton.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					CloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
					CloseButton.Size = UDim2.new(0.05793, 0, 1.00796, 0)
					CloseButton.Position = UDim2.new(0.97104, 0, 0.49602, 0)
					CloseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
					CloseButton.Parent = Header

					CloseButton.MouseButton1Click:Connect(function()
						storeGui:Destroy()
					end)

					local CloseButtonAspectRatio = Instance.new("UIAspectRatioConstraint")
					CloseButtonAspectRatio.AspectRatio = 1.00776
					CloseButtonAspectRatio.Parent = CloseButton

					local IconButton = Instance.new("ImageButton")
					IconButton.BorderSizePixel = 0
					IconButton.ScaleType = Enum.ScaleType.Fit
					IconButton.BackgroundTransparency = 1
					IconButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					IconButton.AnchorPoint = Vector2.new(0.5, 0.5)
					IconButton.Image = "rbxassetid://129011728174193"
					IconButton.Size = UDim2.new(0.05663, 0, 0.99308, 0)
					IconButton.Position = UDim2.new(0.91359, 0, 0.5, 0)
					IconButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
					IconButton.Parent = Header

					IconButton.MouseButton1Click:Connect(function()
						SearchBar.Visible = not SearchBar.Visible
						if SearchBar.Visible then
							SearchBar:CaptureFocus()
						else
							SearchBar.Text = ''
						end
					end)

					SearchBar.FocusLost:Connect(function(enterPressed)
						if enterPressed then
							SearchBar.Visible = false
							SearchBar.Text = ''
						end
					end)

					game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
						if processed then return end
						if input.KeyCode == Enum.KeyCode.Escape and SearchBar.Visible then
							SearchBar.Visible = false
							SearchBar.Text = ''
						end
					end)

					local IconButtonAspectRatio = Instance.new("UIAspectRatioConstraint")
					IconButtonAspectRatio.Parent = IconButton

					local ScrollingFrame = Instance.new("ScrollingFrame")
					ScrollingFrame.Active = true
					ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
					ScrollingFrame.BorderSizePixel = 0
					ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
					ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
					ScrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Always
					ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
					ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
					ScrollingFrame.Size = UDim2.new(1, 0, 0.88141, 0)
					ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5366, 0)
					ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ScrollingFrame.ScrollBarThickness = 7
					ScrollingFrame.BackgroundTransparency = 1
					ScrollingFrame.Parent = MainFrame

					local ScrollingFrameLayout = Instance.new("UIListLayout")
					ScrollingFrameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					ScrollingFrameLayout.Padding = UDim.new(0, 5)
					ScrollingFrameLayout.Parent = ScrollingFrame

					local CardTemplate = Instance.new("TextButton")
					CardTemplate.Name = "CardTemplate"
					CardTemplate.Text = ""
					CardTemplate.AutoButtonColor = false
					CardTemplate.BorderSizePixel = 0
					CardTemplate.BackgroundColor3 = Color3.fromRGB(41, 41, 41)
					CardTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
					CardTemplate.AutomaticSize = Enum.AutomaticSize.Y
					CardTemplate.Size = UDim2.new(0.967, 0, 0, 0)
					CardTemplate.BorderColor3 = Color3.fromRGB(0, 0, 0)

					local CardCorner = Instance.new("UICorner")
					CardCorner.CornerRadius = UDim.new(0.1, 0)
					CardCorner.Parent = CardTemplate

					local CardLayout = Instance.new("UIListLayout")
					CardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					CardLayout.SortOrder = Enum.SortOrder.Name
					CardLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
					CardLayout.VerticalAlignment = Enum.VerticalAlignment.Center
					CardLayout.Parent = CardTemplate

					local CardPadding = Instance.new("UIPadding")
					CardPadding.PaddingTop = UDim.new(0, 6)
					CardPadding.PaddingBottom = UDim.new(0, 6)
					CardPadding.Parent = CardTemplate

					local CardTitle = Instance.new("TextLabel")
					CardTitle.Name = "1"
					CardTitle.Text = ""
					CardTitle.TextWrapped = true
					CardTitle.BorderSizePixel = 0
					CardTitle.TextSize = 14
					CardTitle.TextScaled = true
					CardTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					CardTitle.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					CardTitle.BackgroundTransparency = 1
					CardTitle.Size = UDim2.new(0.967, 0, 0, 22)
					CardTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
					CardTitle.Parent = CardTemplate

					local CardDesc = Instance.new("TextLabel")
					CardDesc.Name = "2"
					CardDesc.Text = ""
					CardDesc.TextWrapped = true
					CardDesc.BorderSizePixel = 0
					CardDesc.TextScaled = false
					CardDesc.TextSize = 12
					CardDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					CardDesc.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					CardDesc.TextColor3 = Color3.fromRGB(201, 201, 201)
					CardDesc.BackgroundTransparency = 1
					CardDesc.AutomaticSize = Enum.AutomaticSize.Y
					CardDesc.Size = UDim2.new(0.967, 0, 0, 0)
					CardDesc.BorderColor3 = Color3.fromRGB(0, 0, 0)
					CardDesc.Parent = CardTemplate

					local CardAuthor = Instance.new("TextLabel")
					CardAuthor.Name = "3"
					CardAuthor.Text = ""
					CardAuthor.TextWrapped = true
					CardAuthor.BorderSizePixel = 0
					CardAuthor.TextSize = 11
					CardAuthor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					CardAuthor.FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					CardAuthor.TextColor3 = Color3.fromRGB(95, 95, 95)
					CardAuthor.BackgroundTransparency = 1
					CardAuthor.Size = UDim2.new(0.967, 0, 0, 16)
					CardAuthor.BorderColor3 = Color3.fromRGB(0, 0, 0)
					CardAuthor.Parent = CardTemplate

					local allCards = {}
					local cardIndex = 0
					local LOAD_BATCH = 25
					local loadingMore = false

					local function buildCard(p)
						local card = CardTemplate:Clone()
						card.Name = p.name
						card.Parent = ScrollingFrame

						local titleLabel  = card:FindFirstChild("1")
						local descLabel   = card:FindFirstChild("2")
						local authorLabel = card:FindFirstChild("3")

						if titleLabel  then titleLabel.Text  = p.name:gsub('%.iy$', '') end
						if descLabel   then descLabel.Text   = p.description or '' end
						if authorLabel then
							local a = p.author or ''
							authorLabel.Text = a ~= '' and 'by ' .. a or ''
						end

						card.MouseButton1Click:Connect(function()
							local name = p.name
							local pluginPath = 'plugins/' .. name
							if isfile(pluginPath) then
								showError('Plugin Store', '"' .. name .. '" is already installed.')
								return
							end

							setGuiVisible(storeGui, false)

							local dlSuccess, dlResult = pcall(function()
								return game:HttpGet(p.url, true)
							end)
							if not dlSuccess then
								showError('Plugin Store', 'Failed to download "' .. name .. '".\n' .. tostring(dlResult))
								setGuiVisible(storeGui, true)
								return
							end

							local writeSuccess, writeErr = pcall(function()
								writefile(pluginPath, dlResult)
							end)
							if not writeSuccess then
								showError('Plugin Store', 'Failed to save "' .. name .. '".\n' .. tostring(writeErr))
								setGuiVisible(storeGui, true)
								return
							end

							notify('Plugin Store', 'Downloaded ' .. name)
							addPlugin(pluginPath)
							setGuiVisible(storeGui, true)
						end)

						return card
					end

					local function loadBatch()
						if loadingMore or cardIndex >= #plugins then return end
						loadingMore = true
						local count = 0
						while cardIndex < #plugins and count < LOAD_BATCH do
							cardIndex = cardIndex + 1
							local card = buildCard(plugins[cardIndex])
							card.Visible = true
							allCards[#allCards + 1] = card
							count = count + 1
						end
						loadingMore = false
					end

					local function clearCards()
						for _, card in ipairs(allCards) do
							card:Destroy()
						end
						allCards = {}
						cardIndex = 0
						loadingMore = false
					end

					loadBatch()

					ScrollingFrame:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
						local viewHeight   = ScrollingFrame.AbsoluteSize.Y
						local canvasHeight = ScrollingFrame.AbsoluteCanvasSize.Y
						if canvasHeight > 0 and ScrollingFrame.CanvasPosition.Y + viewHeight * 2 >= canvasHeight then
							loadBatch()
						end
					end)

					SearchBar:GetPropertyChangedSignal('Text'):Connect(function()
						local q = SearchBar.Text:lower()
						clearCards()
						if q == '' then
							loadBatch()
							return
						end
						for _, p in ipairs(plugins) do
							local name    = p.name:gsub('%.iy$', ''):lower()
							local pdesc   = (p.description or ''):lower()
							local pauthor = (p.author or ''):lower()
							if name:find(q, 1, true) or pdesc:find(q, 1, true) or pauthor:find(q, 1, true) then
								local card = buildCard(p)
								card.Visible = true
								allCards[#allCards + 1] = card
							end
						end
					end)
				end)
			end
		}
	}
}

return Plugin