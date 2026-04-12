local HttpService = game:GetService("HttpService")
local BASE = "https://iyplugins.pages.dev"

local function downloadAndLoadAll()
    if not writefile then
        notify("Incompatible Exploit", "Your exploit does not support writefile")
        return
    end

    print("Fetching plugin list...")
    local response = game:HttpGet(BASE .. "/data/api.json")
    local data = HttpService:JSONDecode(response)

    for i, plugin in ipairs(data.plugins) do
        print(string.format("[%d/%d] Downloading: %s", i, data.total, plugin.name))
        for _, file in ipairs(plugin.files) do
            local success, content = pcall(function()
                return game:HttpGet(BASE .. "/" .. file.url)
            end)

            if success then
                writefile(file.filename, content)
            else
                warn("Failed to download: " .. file.filename)
            end
        end
    end
    print("Download complete! Loading plugins...")

    if not listfiles or not isfolder then
        warn("Cannot auto-load: exploit missing listfiles/isfolder")
        return
    end

    for _, filePath in ipairs(listfiles("")) do
        local fileName = filePath:match("([^/\\]+%.iy)$")

        if fileName and
            fileName:lower() ~= "iy_fe.iy" and
            not isfolder(fileName) and
            not table.find(PluginsTable, fileName)
        then
            addPlugin(fileName)
        end
    end
    print("All plugins loaded!")
end

downloadAndLoadAll()