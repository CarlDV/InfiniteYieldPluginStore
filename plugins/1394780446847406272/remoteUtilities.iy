local looping = false

local Plugin = {
    ["PluginName"] = "Remote Utilities",
    ["PluginDescription"] = "made by xyz",
    ["Commands"] = {

        ["fireRemote"] = {
            ["ListName"] = "fireRemote [remoteName] [args]",
            ["Description"] = "fires the chosen remote event",
            ["Aliases"] = {"fr", "fireR", "fRemote"},
            ["Function"] = function(args, speaker)
                local g = game:GetDescendants()
                for _, v in pairs(g) do
                    if v.Name == args[1] then
                        if v:IsA("RemoteEvent") then
                            if args[2] then
                                v:FireServer(args[2])
                                notify("Fired " .. v:GetFullName() .. " with argument: " .. tostring(args[2]))
                            else
                                v:FireServer()
                                notify("Fired " .. v:GetFullName() .. " with no arguments.")
                            end
                        elseif v:IsA("RemoteFunction") then
                            if args[2] then
                                v:InvokeServer(args[2])
                                notify("Fired " .. v:GetFullName() .. " with argument: " .. tostring(args[2]))
                            else
                                v:InvokeServer()
                                notify("Fired " .. v:GetFullName() .. " with no arguments.")
                            end
                        end
                    end
                end
            end
        },

        ["fireAllRemotes"] = {
            ["ListName"] = "fireAllRemotes [args]",
            ["Description"] = "fires all remotes found",
            ["Aliases"] = {"FAR"},
            ["Function"] = function(args, speaker)
                local g = game:GetDescendants()
                for _, v in pairs(g) do
                    if v:IsA("RemoteEvent") then
                        v:FireServer(args[1])
                        notify("Fired " .. v:GetFullName() .. " with argument: " .. tostring(args[1] or "none"))
                    elseif v:IsA("RemoteFunction") then
                        v:InvokeServer(args[1])
                        notify("Fired " .. v:GetFullName() .. " with argument: " .. tostring(args[1] or "none"))
                    end
                end
            end
        },

        ["listRemotes"] = {
            ["ListName"] = "listRemotes",
            ["Description"] = "Lists all RemoteEvents and RemoteFunctions in the game and copies to clipboard",
            ["Aliases"] = {"lr", "remotes"},
            ["Function"] = function(args, speaker)
                local remotesList = {}
                for _, v in pairs(game:GetDescendants()) do
                    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                        table.insert(remotesList, v.ClassName .. ": " .. v:GetFullName())
                    end
                end
                if #remotesList == 0 then
                    notify("No remotes found.")
                    setclipboard("No remotes found.")
                else
                    local combined = "Remotes found (" .. #remotesList .. "):\n" .. table.concat(remotesList, "\n")
                    notify(combined)
                    setclipboard(combined)
                end
            end
        },

        ["loopRemote"] = {
            ["ListName"] = "loopRemote [remoteName] [delay] [arg]",
            ["Description"] = "Continuously fires the remote with a delay between each fire",
            ["Aliases"] = {"lr", "loopR"},
            ["Function"] = function(args, speaker)
                local remoteName = args[1]
                local delay = tonumber(args[2]) or 1
                local payload = args[3]

                if not remoteName then
                    notify("Missing remote name.")
                    return
                end

                if looping then
                    notify("Already looping a remote. Use 'stopLoop' to stop.")
                    return
                end

                looping = true

                spawn(function()
                    while looping do
                        local found = false
                        for _, v in pairs(game:GetDescendants()) do
                            if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                                found = true
                                if v:IsA("RemoteEvent") then
                                    v:FireServer(payload)
                                else
                                    v:InvokeServer(payload)
                                end
                                notify("Fired " .. v:GetFullName())
                                break
                            end
                        end
                        if not found then
                            notify("Remote '" .. remoteName .. "' not found.")
                            looping = false
                            break
                        end
                        wait(delay)
                    end
                end)
            end
        },

        ["stopLoop"] = {
            ["ListName"] = "stopLoop",
            ["Description"] = "Stops the currently looping remote",
            ["Aliases"] = {"sl"},
            ["Function"] = function(args, speaker)
                if looping then
                    looping = false
                    notify("Stopped looping remote.")
                else
                    notify("No remote is currently looping.")
                end
            end
        },

        ["disableRemote"] = {
            ["ListName"] = "disableRemote [remoteName]",
            ["Description"] = "Disables the first remote found with the given name",
            ["Aliases"] = {"dr", "killRemote"},
            ["Function"] = function(args, speaker)
                local remoteName = args[1]
                if not remoteName then
                    notify("Missing remote name.")
                    return
                end
                for _, v in pairs(game:GetDescendants()) do
                    if v.Name == remoteName and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
                        local target = v
                        local old
                        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                            local method = getnamecallmethod()
                            if self == target and (method == "FireServer" or method == "InvokeServer") then
                                return
                            end
                            return old(self, ...)
                        end))
                        notify("Hooked and disabled remote: " .. target:GetFullName())
                        return
                    end
                end
                notify("Remote '" .. remoteName .. "' not found.")
            end
        }

    }
}

return Plugin
