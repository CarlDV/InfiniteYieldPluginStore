-- tuff plugin
local id = 112798190766214
local plr = game.Players.LocalPlayer
local done = false
local id67 = 6754147732

local function tuffify()
    if not done then
        local gui = Instance.new("ScreenGui")
        gui.Name = "amongus"
        gui.ResetOnSpawn = false
        gui.Parent = plr:WaitForChild("PlayerGui")
        
        local tuffy = Instance.new("ImageLabel")
        tuffy.Size = UDim2.fromScale(1, 1)
        tuffy.Position = UDim2.fromScale(0, 0)
        -- fit perfectly into daddy kendrick tight hole
        tuffy.BackgroundTransparency = 1
        tuffy.Image = "rbxassetid://" .. id
        tuffy.Parent = gui
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. id67
        sound.Volume = 67
        sound.PlaybackSpeed = 2.67
        sound.Looped = true
        sound.Parent = gui
        sound:Play()

        done = true
    end
end

local Plugin = {
    ["PluginName"] = "tuff sigma",
    ["PluginDescription"] = "67",
    ["Commands"] = {
        ["mustard"] = {
            ["ListName"] = "mustard",
            ["Description"] = "makes tuff",
            ["Aliases"] = {"mustard","67","tuff"},
            ["Function"] = function(args,speaker)
                if plr.Name ~= "ihateniggers1488" then
                    tuffify()
                end
            end
        },
    }
}

return Plugin
