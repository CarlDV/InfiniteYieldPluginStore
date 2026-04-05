--!strict

-- // Services
local RunService = cloneref(game:GetService("RunService"))
local Workspace  = cloneref(game:GetService("Workspace"))

-- // Variables
local Camera = Workspace.CurrentCamera
local Active = false

-- // Connections
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- // Init
local Bind do -- / fuck you amity
    local Rand = Random.new()
    local Max = Rand:NextInteger(Rand:NextInteger(0, 5), 25)
    local Buffer = buffer.create(Max)

    for i = 0, Max - 1 do
        buffer.writei8(Buffer, i, Rand:NextInteger(0, 255))
    end

    Bind = buffer.tostring(Buffer)
end

-- // Types (omg imagine using static type checking 🤓)
type Command = {
    ListName: string,
    Description: string,
    Aliases: {string},
    Function: (args: {string}, speaker: Player) -> ()
}

-- // Plugin ong
local Plugin: {
    PluginName: string,
    PluginDescription: string,
    Commands: {[string]: Command}
} = {
    PluginName = "Stretched Resolution.",
    PluginDescription = "Stretches your resolution, many thanks to some guy on devforums for making the prototype of this code.",
    Commands = {
        stretchresolution = {
            ListName = "stretchresolution [stretch]",
            Description = "Stretches your resolution. No input or input <= 1 unstretches your resolution.",
            Aliases = {"stretchedresolution", "stretchres", "stretchres", "strres", "stretch"},
            Function = function(args: {string})
                local ToNumber = tonumber(args[1])
                if ToNumber then
                    ToNumber = math.clamp(ToNumber, 1, 100) -- This has a minimum of 1, because unfortunately the stretch can't apply vertically
                end
                local Stretch = ToNumber and 1 / ToNumber or 1
                if not Stretch then notify("Number Expected", `Got "{args[1]}".`); return end

                if Stretch == 1 then
                    RunService:UnbindFromRenderStep(Bind)
                    Active = false
                else
                    if Active then
                        RunService:UnbindFromRenderStep(Bind)
                    end

                    local SquishCFrame = CFrame.new(0, 0, 0, 1, 0, 0, 0, Stretch, 0, 0, 0, 1)

                    RunService:BindToRenderStep(Bind, Enum.RenderPriority.Camera.Value + 5, function()
                        Camera.CFrame *= SquishCFrame
                    end)

                    Active = true
                end
            end
        },
        unstretchresolution = {
            ListName = "unstretchresolution",
            Description = "Unstretches your resolution.",
            Aliases = {"unstretchedresolution", "unstretchres", "unstretchres", "unstrres", "unstretch"},
            Function = function()
                if not Active then return end
                RunService:UnbindFromRenderStep(Bind)
                Active = false
            end
        }
    }
}

return Plugin