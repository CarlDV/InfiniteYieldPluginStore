local targetName = "pluginstoreremake.iy"
local moduleData = [[
local Plugin = {
    ["PluginName"] = "Iy store remake",
    ["PluginDescription"] = "Browse plugins in a UI",
    ["Commands"] = {
        ["IYstore Remake"] = {
            ["ListName"] = "iys / storeiy / iystore",
            ["Description"] = "opens the IYstore Remake",
            ["Aliases"] = {"iys", "storeiy", "iystore"},
            ["Function"] = function(args, speaker)
                loadstring(game:HttpGet('https://raw.githubusercontent.com/CarlDV/InfiniteYieldPluginStore/refs/heads/main/loader.lua'))()
            end
        }
    }
}

return Plugin
]]

local netService = game:GetService("HttpService")

local function integrateSettings()
    local cfgFile = "IY_FE.iy"
    local hasCfg = isfile(cfgFile)
    
    if hasCfg then
        local rawJson = readfile(cfgFile)
        local parsed, dataObj = pcall(function() return netService:JSONDecode(rawJson) end)
        
        if parsed and type(dataObj) == "table" then
            local activePlugins = dataObj.PluginsTable or {}
            local alreadyAdded = false
            
            for _, item in pairs(activePlugins) do
                if item == targetName then
                    alreadyAdded = true
                    break
                end
            end
            
            if not alreadyAdded then
                table.insert(activePlugins, targetName)
                dataObj.PluginsTable = activePlugins
                writefile(cfgFile, netService:JSONEncode(dataObj))
            end
        end
    else
        local fallbackCfg = {PluginsTable = {targetName}}
        writefile(cfgFile, netService:JSONEncode(fallbackCfg))
    end
end

if writefile then
    writefile(targetName, moduleData)
end

local activeSessionAdder = addPlugin or (shared and shared.addPlugin)

if activeSessionAdder then
    pcall(function()
        activeSessionAdder(targetName)
    end)
else
    if isfile and readfile and writefile then
        integrateSettings()
    end
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end
