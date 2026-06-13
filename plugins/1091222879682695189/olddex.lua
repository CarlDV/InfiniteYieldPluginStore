execCmd("removecmd olddex") --cant call the removecmd function directly because of differing environments
wait() --wait for the cmd to be removed

local p = {
  PluginName = "olddex",
  PluginDescription = "Loads a fixed version of dex",
  Commands = {
    olddex = {
      ListName = "olddex / odex",
      Description = "loads dex v3 with patches",
      Aliases = {"odex"},
      Function = function()
        local str = game:HttpGet("https://raw.githubusercontent.com/KnuxTheFixer/dex/main/loader.lua")
        if not str or str=="" then --httpget returns an empty string if the url does not exist
          notify("HttpGet error occurred (is github blocked?)")
          return
        end
        local f,err = loadstring(str)
        if not f then
          notify("error occurred while loading dex: "..err)
          return
        end
        f()
      end
    }
  }
}

return p