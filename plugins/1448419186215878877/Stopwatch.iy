local startTime = 0
local running = false
local elapsed = 0

local function formatTime(t)
    local mins = math.floor(t / 60)
    local secs = math.floor(t % 60)
    local ms   = math.floor((t - math.floor(t)) * 1000)
    return string.format("%02d:%02d.%03d", mins, secs, ms)
end

local Plugin = {
    ["PluginName"] = "Stopwatch",
    ["PluginDescription"] = "Simple stopwatch: sw start | stop | reset | time",
    ["Commands"] = {
        ["sw"] = {
            ["ListName"] = "sw [start/stop/reset/time]",
            ["Description"] = "Controls the stopwatch",
            ["Aliases"] = {},
            ["Function"] = function(args, speaker)
                local action = getstring(1):lower()

                if action == "start" then
                    if running then
                        notify("Stopwatch", "Already running.")
                        return
                    end
                    startTime = tick() - elapsed
                    running = true
                    notify("Stopwatch", "Started.")

                elseif action == "stop" then
                    if not running then
                        notify("Stopwatch", "Already stopped.")
                        return
                    end
                    elapsed = tick() - startTime
                    running = false
                    notify("Stopwatch", "Stopped at " .. formatTime(elapsed))

                elseif action == "reset" then
                    running = false
                    elapsed = 0
                    startTime = 0
                    notify("Stopwatch", "Reset.")

                elseif action == "time" then
                    local t = running and (tick() - startTime) or elapsed
                    notify("Stopwatch", "Current time: " .. formatTime(t))

                else
                    notify("Stopwatch", "Usage: sw start | stop | reset | time")
                end
            end
        }
    }
}

return Plugin