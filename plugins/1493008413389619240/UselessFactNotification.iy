local Plugin = {
    ["PluginName"] = "Useless Facts",
    ["PluginDescription"] = "Let's learn some random useless facts",
    ["Commands"] = {
        ["UselessFacts"] = {
            ["ListName"] = "fact / useless",
            ["Description"] = "Notifies the player a random fact using IY Notification system",
            ["Aliases"] = {"fact"},{"useless"},
            ["Function"] = function(args, speaker)
                local Response = request({
    Url = "https://uselessfacts.jsph.pl/random",
    Method = "GET",
    Headers = {
        ["Content-Type"] = "application/html"
    },
})
local Start = string.find(Response.Body, '<blockquote>') + 12
local End = string.find(Response.Body,'</blockquote>',Start) - 1
local Finish = string.sub(Response.Body,Start,End)
notify('Useless Facts',Finish)
            end
        }
    }
}

return Plugin