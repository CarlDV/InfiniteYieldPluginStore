local Plugin = {
    ["PluginName"] = "Youtube Thumbnail Downloader",
    ["PluginDescription"] = "Download Youtube Thumbnails.",
    ["Commands"] = {
        ["friendspam"] = {
            ["ListName"] = "thumbdownload / td",
            ["Description"] = "Download Youtube Thumbnails.",
            ["Aliases"] = {"td"},
            ["Function"] = function(args)
                if not (writefile) then 
                    notify("Your executor doesn't support the required functions.")
                    else
                    link = args[1]
                    local imageData = game:HttpGet("https://img.youtube.com/vi/"..string.sub(link,33,100).."/maxresdefault.jpg")
                    makefolder("Images")
                    writefile("Images/"..string.sub(link,33,100)..".jpg", imageData)
                    notify("Image saved check the Images folder in your workspace folder!")
                end
            end
        }
    }
}
return Plugin