local Plugin = {
    ["PluginName"] = "ToSpawn",
    ["PluginDescription"] = "Teleports you to spawn (a random one if multiple exist)",
    ["Commands"] = {
        ["tospawn"] = {
            ["ListName"] = "tospawn",
            ["Description"] = "Teleports you to workspace spawn point",
            ["Aliases"] = {"gotospawn"},
            ["Function"] = function(args,speaker)
							local spawnPoints = {}
							local player = game.Players.LocalPlayer
							local team = player.Team
							
							for _, obj in pairs(workspace:GetDescendants()) do
							    if obj:IsA("SpawnLocation") then
							        if team and obj.TeamColor == team.TeamColor then
							            table.insert(spawnPoints, obj) -- Add team-specific spawns
							        end
							    end
							end
							
							if #spawnPoints == 0 then
							    for _, obj in pairs(workspace:GetDescendants()) do
							        if obj:IsA("SpawnLocation") then
							            table.insert(spawnPoints, obj)
							        end
							    end
							end
							
							if #spawnPoints > 0 then
							    local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
							    
							    local character = player.Character
							    if character and randomSpawn then
							        local spawnCFrame = randomSpawn.CFrame + Vector3.new(0, 5, 0) -- Spawn 5 studs above
							        character:SetPrimaryPartCFrame(spawnCFrame)
							    end
							else
							    local character = player.Character
							    if character then
							        local fallbackCFrame = CFrame.new(0, 5, 0) -- Spawn 5 studs above (0,0,0)
							        character:SetPrimaryPartCFrame(fallbackCFrame)
							    end
							end
							            end
        }
    }
}

return Plugin