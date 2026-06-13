--[[
░██████╗░░█████╗░███╗░░░███╗███████╗░██████╗
██╔════╝░██╔══██╗████╗░████║██╔════╝██╔════╝
██║░░██╗░███████║██╔████╔██║█████╗░░╚█████╗░
██║░░╚██╗██╔══██║██║╚██╔╝██║██╔══╝░░░╚═══██╗
╚██████╔╝██║░░██║██║░╚═╝░██║███████╗██████╔╝
 ░╚═════╝░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░
]]--
-- Version 1.2 / Версия 1.2

local setclipboard = setclipboard or toclipboard or setrbxclipboard or set_clipboard or to_clipboard or set_rbx_clipboard or (Clipboard and Clipboard.set) or writeclipboard or write_clipboard or nil
local _1, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
local _2, CoreGui = pcall(function() return game:GetService("CoreGui") end)
local _1_ReturnTable = {}
local UserInputService = game:GetService("UserInputService")

if not setclipboard then 
   notify("Error", "Your executor doesn't support setclipboard or other functions")
   return
end

if not VirtualInputManager then 
   notify("Error", "Your Executor doesn't support VirtualInputManager service")
   return
end

if not CoreGui then
   notify("Error", "Your Executor doesn't support CoreGui service")
   return 
end

local Plugin = {
    ["PluginName"] = "– Auto Clicker –--",
    ["PluginDescription"] = "Plugin for auto clicker",
    ["Commands"] = {
        ["clicktocopyvector2pos"] = {
           ["ListName"] = "ClickToCopyVector2Pos / ClickCopy",
           ["Description"] = "Copy Vector2 pose with click",
           ["Aliases"] = {"clicktocopyvector2pos", "clickcopy"},
           ["Function"] = function(args, speaker)
           table.clear(_1_ReturnTable)
           for _, v in ipairs(CoreGui:GetDescendants()) do
              if v:IsA("ScreenGui") then
                 table.insert(_1_ReturnTable, {v, v.Enabled})
                  v.Enabled = false
              end
           end
           local BlockGui = Instance.new("ScreenGui")
           BlockGui.ResetOnSpawn = false
           BlockGui.Parent = CoreGui
           BlockGui.IgnoreGuiInset = true
           BlockGui.DisplayOrder = math.huge
           
           local BlockFrame = Instance.new("Frame")
           BlockFrame.AnchorPoint = Vector2.new(0, 0)
           BlockFrame.Position = UDim2.new(0, 0, 0, 0)
           BlockFrame.Size = UDim2.new(1, 0, 1, 0)
           BlockFrame.BackgroundTransparency = 1
           BlockFrame.Parent = BlockGui
           BlockFrame.Active = true
           
           BlockFrame.InputBegan:Connect(function(input)
              if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                 local pos = UserInputService:GetMouseLocation()
                 setclipboard(string.format("%.2f %.2f", pos.X, pos.Y))
                 
                 for _, v in ipairs(_1_ReturnTable) do
                    v[1].Enabled = v[2]
                 end
                 BlockGui:Destroy()
                 table.clear(_1_ReturnTable)
              end
           end)
           
           end
        },
         ["clickonvector2pos"] = {
           ["ListName"] = "ClickOnVector2 / Click [x] [y]",
           ["Description"] = "Click On Vector2 Position",
           ["Aliases"] = {"clickonvector2", "click"},
           ["Function"] = function(args, speaker)
           local ClickPosX = tonumber(args[1])
           local ClickPosY = tonumber(args[2])
           if not ClickPosX or not ClickPosY then
              notify("Error", "Enter Vector2 Position")
              return
           end
           VirtualInputManager:SendMouseButtonEvent(ClickPosX, ClickPosY, 0, true, nil, 0)
           task.wait(0.01)
           VirtualInputManager:SendMouseButtonEvent(ClickPosX, ClickPosY, 0, false, nil, 0)
           end
        },
        ["clickonvector2pro"] = {
           ["ListName"] = "ClickOnVector2Pro / ClickPro [x] [y] [times] [delay]",
           ["Description"] = "Click On Vector2 Position Pro Version",
           ["Aliases"] = {"clickonvector2pro"},
           ["Function"] = function(args, speaker)
           local ClickPosX = tonumber(args[1])
           local ClickPosY = tonumber(args[2])
           local ClickTimes = tonumber(args[3])
           local ClickDelay = tonumber(args[4])
           if not ClickPosX or not ClickPosY or not ClickTimes or not ClickDelay then
              notify("Error", "Enter Vector2 Position or click times or click delay")
              return
           end
           for i = 1, ClickTimes do
              VirtualInputManager:SendMouseButtonEvent(ClickPosX, ClickPosY, 0, true, nil, 0)
              task.wait(0.01)
              VirtualInputManager:SendMouseButtonEvent(ClickPosX, ClickPosY, 0, false, nil, 0)
              task.wait(ClickDelay)
           end
           end
        },
        ["clickdrag"] = {
           ["ListName"] = "ClickDrag [x] [y] [x] [y] [delay]",
           ["Description"] = "Drag to your coordinates",
           ["Aliases"] = {"clickdrag"},
           ["Function"] = function(args, speaker)
           local _1_ClickPosX = tonumber(args[1])
           local _1_ClickPosY = tonumber(args[2])
           local _2_ClickPosX = tonumber(args[3])
           local _2_ClickPosY = tonumber(args[4])
           local _3_Delay = tonumber(args[5])
           if not _1_ClickPosX or not _1_ClickPosY or not _2_ClickPosX or not _2_ClickPosY or not _3_Delay then
              notify("Error", "Enter Vector2 Positions or delay")
              return
           end
           local Steps = math.max(1, math.floor(_3_Delay / 0.02))
           local StepDelay = _3_Delay / Steps
           VirtualInputManager:SendMouseButtonEvent(_1_ClickPosX, _1_ClickPosY, 0, true, nil, 0)
           for i = 1, Steps do
              VirtualInputManager:SendMouseMoveEvent(_1_ClickPosX + (_2_ClickPosX - _1_ClickPosX) * (i / Steps), _1_ClickPosY + (_2_ClickPosY - _1_ClickPosY) * (i / Steps), nil)
              task.wait(StepDelay)
           end
           VirtualInputManager:SendMouseButtonEvent(_2_ClickPosX, _2_ClickPosY, 0, false, nil, 0)
           end
        },
        ["clickhold"] = {
           ["ListName"] = "ClickHold [x] [y] [delay]",
           ["Description"] = "Hold on your coordinates",
           ["Aliases"] = {"clickhold"},
           ["Function"] = function(args, speaker)
           local _1_X = tonumber(args[1])
           local _2_Y = tonumber(args[2])
           local _3_D = tonumber(args[3])
           if not _1_X or not _2_Y or not _3_D then 
              notify("Error", "Enter coordinates or delay")
              return
           end
           VirtualInputManager:SendMouseButtonEvent(_1_X, _2_Y, 0, true, nil, 0)
           task.wait(_3_D)
           VirtualInputManager:SendMouseButtonEvent(_1_X, _2_Y, 0, false, nil, 0)
           end
        },
        ["clickscroll"] = {
           ["ListName"] = "ClickScroll [x] [y] [times] [delay]",
           ["Description"] = "scroll on your coordinates",
           ["Aliases"] = {"clickscroll"},
           ["Function"] = function(args, speaker)
           local _1_X_ = tonumber(args[1])
           local _2_Y_ = tonumber(args[2])
           local _3_T_ = tonumber(args[3])
           local _4_D_ = tonumber(args[4])
           if not _1_X_ or not _2_Y_ or not _3_T_ or not _4_D_ then 
              notify("Error", "Enter coordinates or times or delay")
              return
           end
           local _5_Times = math.abs(_3_T_)
           local _6_F = _3_T_ > 0
           for i = 1, _5_Times do
              VirtualInputManager:SendMouseWheelEvent(_1_X_, _2_Y_, _6_F, nil)
              task.wait(_4_D_)
           end
           end
        },
        ["keyprees"] = {
           ["ListName"] = "KeyPrees [key]",
           ["Description"] = "Prees Your Key",
           ["Aliases"] = {"keyprees"},
           ["Function"] = function(args, speaker)
           local _1_K_ = Enum.KeyCode[string.upper(tostring(args[1]))]
           if not _1_K_ then 
              notify("Error", "Enter your key")
              return
           end
           VirtualInputManager:SendKeyEvent(true, _1_K_, false, game)
           task.wait(0.05)
           VirtualInputManager:SendKeyEvent(false, _1_K_, false, game)
           end
        },
        ["keypreespro"] = {
           ["ListName"] = "KeyPreesPro [key] [times] [delay]",
           ["Description"] = "Prees Your Key Pro Version",
           ["Aliases"] = {"keypreespro"},
           ["Function"] = function(args, speaker)
           local _291_K_ = Enum.KeyCode[string.upper(args[1])]
           local _666_ = tonumber(args[2])
           local _777_ = tonumber(args[3])
           if not _291_K_ or not _666_ or not _777_ then 
              notify("Error", "Enter your key or times or delay")
              return
           end
           for i = 1, _666_ do
              VirtualInputManager:SendKeyEvent(true, _291_K_, false, game)
              task.wait(0.03)
              VirtualInputManager:SendKeyEvent(false, _291_K_, false, game)
              task.wait(_777_)
           end
           end
        },
        ["holdkey"] = {
           ["ListName"] = "HoldKey [key] [delay]",
           ["Description"] = "Hold Your Key",
           ["Aliases"] = {"holdkey"},
           ["Function"] = function(args, speaker)
           local _191_K_ = Enum.KeyCode[string.upper(args[1])]
           local _166_ = tonumber(args[2])
           if not _191_K_ or not _166_ then 
              notify("Error", "Enter your key or delay")
              return
           end
           VirtualInputManager:SendKeyEvent(true, _191_K_, false, game)
           task.wait(_166_)
           VirtualInputManager:SendKeyEvent(false, _191_K_, false, game)
           end
        }
    }
}

return Plugin