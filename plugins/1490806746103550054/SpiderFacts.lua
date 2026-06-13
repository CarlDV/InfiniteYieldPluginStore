local Plugin = {
    ["PluginName"] = "SpiderFacts",
    ["PluginDescription"] = "Idk i was asked to do this okay ?",
    ["Commands"] = {
        ["example"] = {
            ["ListName"] = "example / ex",
            ["Description"] = "Prints a message to the console",
            ["Aliases"] = {"ex"},
            ["Function"] = function(args, speaker)
                print("Hello from ExamplePlugin!")
            end
        },
        ["spiderfact"] = {
            ["ListName"] = "spiderfact / spdrfct",
            ["Description"] = "notifies a spider fact.",
            ["Aliases"] = {"spdrfct"},
            ["Function"] = function(args, speaker)
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/Fiazer1/Spider/refs/heads/main/Facts.lua"))()
            end
        }
    }
}

return Plugin
