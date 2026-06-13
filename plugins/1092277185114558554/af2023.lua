local Titles = {"Ricky Wicky Yield 😱", "Infinite Bread", "Egg Admino", "Amity coughed", "Where am I", "Rickity Yieldd", "walter white", "Nick Cage?!?!", "peyton real", "april fool!!"}
local Images = {"11688231017", "11339922083", "11914981726", "5783845592", "6762179979", "7846015915", "11171958623", "11308149650", "7444547410", "6093472109"}

Title.Text = Titles[math.random(1, #Titles)] .. " v" .. currentVersion
Logo.Image = "rbxassetid://" .. Images[math.random(1, #Images)]

return {PluginName = "April Fools 2023", PluginDescription = "get pranked lol", Commands = {}}
