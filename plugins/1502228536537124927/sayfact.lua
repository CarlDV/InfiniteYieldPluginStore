local Plugin = {
    ["PluginName"] = "sayfact",
    ["PluginDescription"] = "Send a random fact to the game",
    ["Commands"] = {
        ["sayfact"] = {
            ["ListName"] = "sayfact",
            ["Description"] = "Sends a random fact to the game",
            ["Aliases"] = {""},
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
local TextChatService = game:GetService("TextChatService")
local generalChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
generalChannel:SendAsync(Finish)
            end
        }
    }
}

return Plugin