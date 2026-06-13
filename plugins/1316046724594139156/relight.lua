local Lighting = game:GetService("Lighting")
local FolderPath = "LightingFiles"
local FilePath = FolderPath .. "/"
local Properties = {
    Lighting = { "Ambient", "Brightness", "ClockTime", "ColorShift_Bottom", "ColorShift_Top", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "ExposureCompensation", "FogColor", "FogEnd", "FogStart", "GeographicLatitude", "GlobalShadows", "OutdoorAmbient", "ShadowSoftness", "TimeOfDay" },
    Atmosphere = { "Color", "Decay", "Density", "Glare", "Haze", "Offset" },
    Sky = { "CelestialBodiesShown", "MoonAngularSize", "MoonTextureId", "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "StarCount", "SunAngularSize", "SunTextureId" },
    ColorCorrectionEffect = { "Brightness", "Contrast", "Saturation", "TintColor", "Enabled" },
    BloomEffect = { "Intensity", "Size", "Threshold", "Enabled" },
    BlurEffect = { "Size", "Enabled" },
    SunRaysEffect = { "Intensity", "Spread", "Enabled" }
}

if not isfolder(FolderPath) then
    makefolder(FolderPath)
end

local function SaveLightingProperties(FileName)
    local FileContent = "local Lighting = game:GetService(\"Lighting\")\n\n"

    FileContent = FileContent .. "for _, Child in pairs(Lighting:GetChildren()) do\n"
    FileContent = FileContent .. "    if Child:IsA(\"Atmosphere\") or Child:IsA(\"Sky\") or Child:IsA(\"ColorCorrectionEffect\") or Child:IsA(\"BloomEffect\") or Child:IsA(\"BlurEffect\") or Child:IsA(\"SunRaysEffect\") then\n"
    FileContent = FileContent .. "        Child:Destroy()\n"
    FileContent = FileContent .. "    end\n"
    FileContent = FileContent .. "end\n\n"

    for _, PropertyName in ipairs(Properties.Lighting) do
        local PropertyValue = Lighting[PropertyName]
        if typeof(PropertyValue) == "string" then
            FileContent = FileContent .. string.format("Lighting.%s = \"%s\"\n", PropertyName, PropertyValue)
        elseif typeof(PropertyValue) == "Color3" then
            FileContent = FileContent .. string.format("Lighting.%s = Color3.new(%f, %f, %f)\n", PropertyName, PropertyValue.R, PropertyValue.G, PropertyValue.B)
        else
            FileContent = FileContent .. string.format("Lighting.%s = %s\n", PropertyName, tostring(PropertyValue))
        end
    end

    local InstanceCount = {}

    for _, Child in ipairs(Lighting:GetChildren()) do
        local ClassName = Child.ClassName
        if Properties[ClassName] then
            InstanceCount[ClassName] = (InstanceCount[ClassName] or 0) + 1
            local InstanceName = ClassName .. (InstanceCount[ClassName] > 1 and InstanceCount[ClassName] or "")
            FileContent = FileContent .. string.format("\nlocal %s = Instance.new(\"%s\")\n", InstanceName, ClassName)
            for _, PropertyName in ipairs(Properties[ClassName]) do
                local PropertyValue = Child[PropertyName]
                if typeof(PropertyValue) == "string" then
                    FileContent = FileContent .. string.format("%s.%s = \"%s\"\n", InstanceName, PropertyName, PropertyValue)
                elseif typeof(PropertyValue) == "Color3" then
                    FileContent = FileContent .. string.format("%s.%s = Color3.new(%f, %f, %f)\n", InstanceName, PropertyName, PropertyValue.R, PropertyValue.G, PropertyValue.B)
                else
                    FileContent = FileContent .. string.format("%s.%s = %s\n", InstanceName, PropertyName, tostring(PropertyValue))
                end
            end
            FileContent = FileContent .. string.format("%s.Parent = Lighting\n", InstanceName)
        end
    end

    writefile(FilePath .. FileName .. ".txt", FileContent)
end

local function LoadLightingProperties(FileName)
    if isfile(FilePath .. FileName .. ".txt") then
        local FileContent = readfile(FilePath .. FileName .. ".txt")
        loadstring(FileContent)()
    else
        notify("File Not Found", "The file " .. FileName .. " does not exist.")
    end
end

local Plugin = {
    ["PluginName"] = "Re:Light",
    ["PluginDescription"] = "The power to save and load graphics.",
    ["Commands"] = {
        ["savegraphics"] = {
            ["ListName"] = "savegraphics / saveg / sg [FileName]",
            ["Description"] = "Saves the lighting properties to a file with the given filename.",
            ["Aliases"] = {"savegraphics", "saveg", "sg"},
            ["Function"] = function(args, speaker)
                local FileName = args[1]
                if FileName then
                    SaveLightingProperties(FileName)
                    notify("Success", "Lighting properties saved to " .. FileName .. ".txt")
                else
                    notify("Error", "Please provide a file name.")
                end
            end
        },
        ["loadgraphics"] = {
            ["ListName"] = "loadgraphics / loadg / lg [FileName]",
            ["Description"] = "Loads the lighting properties from a saved file.",
            ["Aliases"] = {"loadgraphics", "loadg", "lg"},
            ["Function"] = function(args, speaker)
                local FileName = args[1]
                if FileName then
                    LoadLightingProperties(FileName)
                    notify("Success", "Lighting properties loaded from " .. FileName .. ".txt")
                else
                    notify("Error", "Please provide a file name.")
                end
            end
        }
    }
}

return Plugin
