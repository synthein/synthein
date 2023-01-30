-- Components
local Hull = require("world/shipparts/hull")
local MissileLauncher = require("synthein").missileLauncher

-- Class Setup
local Part = require("world/shipparts/part")
local MissileLauncherBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
MissileLauncherBlock.image = Draw.loadImage("missileLauncher")
local imageFunction = Draw.createDrawBlockFunction(MissileLauncherBlock.image)

function MissileLauncherBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 10)

	self.modules["missileLuancher"] = MissileLauncher()

	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

return MissileLauncherBlock
