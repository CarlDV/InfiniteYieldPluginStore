local socialcredits = 0
local salary = 10
local goodId, badId = 97706535327330, 120196717442347
local chineseId = 8383718211
local mao = 83646707081518
local plr = game.Players.LocalPlayer

local function punishment(id, message)
    notify(message)
    task.wait(2)
    local gui = Instance.new("ScreenGui", plr.PlayerGui)
    local image = Instance.new("ImageLabel", gui)
    image.Image = "rbxassetid://" .. id
    image.Size = UDim2.new(1, 0, 1, 0)
    image.BackgroundTransparency = 0
    local sound = Instance.new("Sound", game.SoundService)
    sound.SoundId = "rbxassetid://" .. chineseId
    sound.Volume = 1
    sound.Looped = true
    sound.PlaybackSpeed = 0.1
    sound:Play()
    task.wait(1.5)
    while true do
        print("nothing happened in Beijing on June 5, 1989")
    end
end

local function work(hours)
    local won = salary * hours
    notify('you have worked for china and you won ' .. won .. ' social credits!')
    socialcredits = socialcredits + won

    local sound = Instance.new("Sound", game.SoundService)
    sound.SoundId = "rbxassetid://" .. chineseId
    sound:Play()

    local gui = Instance.new("ScreenGui", plr.PlayerGui)
    local image = Instance.new("ImageLabel", gui)

    if socialcredits < 0 then
        image.Image = "rbxassetid://" .. badId
        image.Size = UDim2.new(1, 0, 1, 0)
        image.BackgroundTransparency = 0
        task.wait(3)
        gui:Destroy()
        punishment(mao, 'YOU HAVE AWAKENED MAO BECAUSE OF YOUR SOCIAL CREDIT DEBT.')
    else
        image.Image = "rbxassetid://" .. goodId
        image.Size = UDim2.new(1, 0, 1, 0)
        image.BackgroundTransparency = 0
        task.wait(3)
        gui:Destroy()
    end
end

local Plugin = {
    ["PluginName"] = "CSCS",
    ["PluginDescription"] = "wassup beijing",
    ["Commands"] = {
        ["workforchina"] = {
            ["ListName"] = "workforchina [amount]",
            ["Description"] = "gives you social credits as a chinese citizen",
            ["Aliases"] = {"wfm","work","funny"},
            ["Function"] = function(args,speaker)
                local hours = tonumber(args[1]) or 0
                pcall(function()
                    work(hours)
                end)
            end
        },
        ["balance"] = {
            ["ListName"] = "balance",
            ["Description"] = "shows your social credit",
            ["Aliases"] = {"bal"},
            ["Function"] = function(args,speaker)
                notify('you have ' .. socialcredits .. ' social credits!')
            end
        },
        ["hackchina"] = {
            ["ListName"] = "hackchina",
            ["Description"] = "hacks the social credit system (dangerous) (may revive adolf rizzler",
            ["Aliases"] = {"hack"},
            ["Function"] = function(args,speaker)
                notify('YOU HAVE HACKED PEOPLES REPUBLIC OF CHINA, GAINING A GAZILION SOCIAL CREDITS')
                socialcredits = socialcredits + 10000000000
                punishment(83646707081518, 'MAO HAS REVIVED TO RAPE YOU FOR THAT.')
            end
        }
    }
}

return Plugin
