local Plugin = {
    ["PluginName"] = "Better Hop",
    ["PluginDescription"] = "a better server hop",
    ["Commands"] = {
        ["lowhop"] = {
            ["ListName"] = "lowhop",
            ["Description"] = "Low Player Server Hop",
            ["Aliases"] = {"lhop", "lh"},
            ["Function"] = function(args,speaker)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/P3nguinMinecraft/MiscScripts/refs/heads/main/serverhop.lua"))()(game.PlaceId, true)
            end
        },
        ["highhop"] = {
            ["ListName"] = "highhop",
            ["Description"] = "High Player Server Hop",
            ["Aliases"] = {"hhop", "hh"},
            ["Function"] = function(args,speaker)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/P3nguinMinecraft/MiscScripts/refs/heads/main/serverhop.lua"))()(game.PlaceId, false)
            end
        }
     }
}

return Plugin