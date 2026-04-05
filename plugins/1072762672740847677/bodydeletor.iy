local Plugin = {
	["PluginName"] = "BodyDeletor",
	["PluginDescription"] = "Useful for Fake VR. Deletes all presents of body",
	["Commands"] = {
		["notorso"] = {
			["ListName"] = "notorso / deltorso / delt",
			["Description"] = "Removes your torso",
			["Aliases"] = {"deltorso","delt"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.UpperTorso:Remove()
					game.Players.LocalPlayer.Character.LowerTorso:Remove()
			end
		},
		["norightleg"] = {
			["ListName"] = "norightleg / deleterightleg / delrl / korblox",
			["Description"] = "Removes all presents of right leg. K O R B L O X",
			["Aliases"] = {"delrightleg","delrl", "korblox"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.RightFoot:Remove()
					game.Players.LocalPlayer.Character.RightUpperLeg:Remove()
					game.Players.LocalPlayer.Character.RightLowerLeg:Remove()
			end
		},
		["noleftleg"] = {
			["ListName"] = "noleftleg / delleftleg / delll",
			["Description"] = "Removes all presents of left leg",
			["Aliases"] = {"delleftleg","delll"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.LeftFoot:Remove()
					game.Players.LocalPlayer.Character.LeftUpperLeg:Remove()
					game.Players.LocalPlayer.Character.LeftLowerLeg:Remove()
			end
		},
		["norightarm"] = { 
			["ListName"] = "norightarm / deletera / delra",
			["Description"] = "Removes all presents of right arm",
			["Aliases"] = {"deletera","delra"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.RightHand:Remove()
					game.Players.LocalPlayer.Character.RightUpperArm:Remove()
					game.Players.LocalPlayer.Character.RightLowerArm:Remove()
			end
		},
		["noleftarm"] = {
			["ListName"] = "noleftarm / deleteleftarm / della",
			["Description"] = "Removes all presents of left arm",
			["Aliases"] = {"deleteleftarm","della"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.LeftHand:Remove()
					game.Players.LocalPlayer.Character.LeftUpperArm:Remove()
					game.Players.LocalPlayer.Character.LeftLowerArm:Remove()
			end
		},
		["rightHand"] = { 
			["ListName"] = "righthand / rhand",
			["Description"] = "Removes all presents of right arm, but doesnt deletes RightHand (R15)",
			["Aliases"] = {"rhand"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.RightUpperArm:Remove()
					game.Players.LocalPlayer.Character.RightLowerArm:Remove()
			end
		},
		["leftHand"] = {
			["ListName"] = "lefthand / lhand",
			["Description"] = "Removes all presents of left arm, but doesnt deletes LeftHand (R15)",
			["Aliases"] = {"lhand"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.LeftUpperArm:Remove()
					game.Players.LocalPlayer.Character.LeftLowerArm:Remove()
			end
		},
		["nolrightHand"] = { 
			["ListName"] = "nolrighthand / nolrhand",
			["Description"] = "Removes Lower part of right arm, it's looks f u n n y",
			["Aliases"] = {"nolrhand"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.RightLowerArm:Remove()
			end
		},
		["nolleftarm"] = {
			["ListName"] = "nollefthand / nollhand",
			["Description"] = "Removes Lower part of left arm, it's looks f u n n y",
			["Aliases"] = {"nollhand"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.LeftLowerArm:Remove()
			end
		},
		["noohead"] = {
			["ListName"] = "noohead / deletehead / delhead",
			["Description"] = "Removes your head",
			["Aliases"] = {"deletehead","delhead"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.Head:Remove()
			end
		},
		["notorsoR6"] = {
			["ListName"] = "notorsoR6 / deltorsoR6 / deltR6",
			["Description"] = "Removes your torso",
			["Aliases"] = {"deltorsoR6","deltR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.Torso:Remove()
			end
		},
		["norightlegR6"] = {
			["ListName"] = "norightlegR6 / deleterightlegR6 / delrlR6 / korbloxR6",
			["Description"] = "Removes all presents of right leg. K O R B L O X",
			["Aliases"] = {"delrightlegR6","delrlR6", "korbloxR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character["Right Leg"]:Remove()
			end
		},
		["noleftlegR6"] = {
			["ListName"] = "noleftlegR6 / delleftlegR6 / delllR6",
			["Description"] = "Removes all presents of left leg",
			["Aliases"] = {"delleftlegR6","delllR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character["Left Leg"]:Remove()
			end
		},
		["norightarmR6"] = { 
			["ListName"] = "norightarmR6 / deleteraR6 / delraR6",
			["Description"] = "Removes all presents of right arm",
			["Aliases"] = {"deleteraR6","delraR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character["Right Arm"]:Remove()
			end
		},
		["noleftarmR6"] = {
			["ListName"] = "noleftarmR6 / deleteleftarmR6 / dellaR6",
			["Description"] = "Removes all presents of left arm",
			["Aliases"] = {"deleteleftarmR6","dellaR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character["Left Arm"]:Remove()
			end
		},
		["noblur"] = {
			["ListName"] = "noblur",
			["Description"] = "Deletes Blur on screen",
			["Aliases"] = {"delblur"},
			["Function"] = function(args, speaker)
					game.Lighting.Blur:Remove()
			end
		},
		["noragdoll"] = {
			["ListName"] = "noragdoll",
			["Description"] = "Deletes ragdoll remote in ragdoll engine",
			["Aliases"] = {"delrag"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character["Pushed"]:Remove()
					game.Players.LocalPlayer.Character["RagdollMe"]:Remove()
					game.Players.LocalPlayer.Character["StartRagdoll"]:Remove()
			end
		},
		["invisiblebodyR6"] = {
			["ListName"] = "invisiblebodyR6",
			["Description"] = "Sets body transparency to 1",
			["Aliases"] = {"nvbodyR6","nvbR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.Torso.Transparency = 1
					game.Players.LocalPlayer.Character.RightLeg.Transparency = 1
					game.Players.LocalPlayer.Character.LeftLeg.Transparency = 1
					game.Players.LocalPlayer.Character.RightArm.Transparency = 1
					game.Players.LocalPlayer.Character.LeftLeg.Transparency = 1
					game.Players.LocalPlayer.Character.Head.Transparency = 1
			end
		},
		["invisiblebody"] = {
			["ListName"] = "invisiblebody",
			["Description"] = "Sets body transparency to 1",
			["Aliases"] = {"nvbody","nvb"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.Head.Transparency = 1
					game.Players.LocalPlayer.Character.LeftFoot.Transparency = 1
					game.Players.LocalPlayer.Character.LeftHand.Transparency = 1
					game.Players.LocalPlayer.Character.LeftLowerArm.Transparency = 1
					game.Players.LocalPlayer.Character.LeftLowerLeg.Transparency = 1
					game.Players.LocalPlayer.Character.LeftUpperArm.Transparency = 1
					game.Players.LocalPlayer.Character.LeftUpperLeg.Transparency = 1
					game.Players.LocalPlayer.Character.LowerTorso.Transparency = 1
					game.Players.LocalPlayer.Character.RightFoot.Transparency = 1
					game.Players.LocalPlayer.Character.RightHand.Transparency = 1
					game.Players.LocalPlayer.Character.RightLowerArm.Transparency = 1
					game.Players.LocalPlayer.Character.RightLowerLeg.Transparency = 1
					game.Players.LocalPlayer.Character.RightUpperArm.Transparency = 1
					game.Players.LocalPlayer.Character.RightUpperLeg.Transparency = 1
					game.Players.LocalPlayer.Character.UpperTorso.Transparency = 1
			end
		},
		["visiblebodyR6"] = {
			["ListName"] = "visiblebodyR6",
			["Description"] = "Sets body transparency to 0",
			["Aliases"] = {"nvbodyR6","nvbR6"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.Torso.Transparency = 0
					game.Players.LocalPlayer.Character.RightLeg.Transparency = 0
					game.Players.LocalPlayer.Character.LeftLeg.Transparency = 0
					game.Players.LocalPlayer.Character.RightArm.Transparency = 0
					game.Players.LocalPlayer.Character.LeftLeg.Transparency = 0
					game.Players.LocalPlayer.Character.Head.Transparency = 0
			end
		},
		["visiblebody"] = {
			["ListName"] = "visiblebody",
			["Description"] = "Sets body transparency to 0",
			["Aliases"] = {"nvbody","nvb"},
			["Function"] = function(args, speaker)
					game.Players.LocalPlayer.Character.Head.Transparency = 0
					game.Players.LocalPlayer.Character.LeftFoot.Transparency = 0
					game.Players.LocalPlayer.Character.LeftHand.Transparency = 0
					game.Players.LocalPlayer.Character.LeftLowerArm.Transparency = 0
					game.Players.LocalPlayer.Character.LeftLowerLeg.Transparency = 0
					game.Players.LocalPlayer.Character.LeftUpperArm.Transparency = 0
					game.Players.LocalPlayer.Character.LeftUpperLeg.Transparency = 0
					game.Players.LocalPlayer.Character.LowerTorso.Transparency = 0
					game.Players.LocalPlayer.Character.RightFoot.Transparency = 0
					game.Players.LocalPlayer.Character.RightHand.Transparency = 0
					game.Players.LocalPlayer.Character.RightLowerArm.Transparency = 0
					game.Players.LocalPlayer.Character.RightLowerLeg.Transparency = 0
					game.Players.LocalPlayer.Character.RightUpperArm.Transparency = 0
					game.Players.LocalPlayer.Character.RightUpperLeg.Transparency = 0
					game.Players.LocalPlayer.Character.UpperTorso.Transparency = 0
			end
		},
	},
}

return Plugin
