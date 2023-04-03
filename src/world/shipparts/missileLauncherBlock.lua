-- Components
local Hull = require("world/shipparts/hull")
local MissileLauncher = require("syntheinrust").missileLauncher

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

function MissileLauncherBlock:update(moduleInputs, location)
	local newObject, disconnect
	
	newObject, _ = self.modules.missileLuancher:update(moduleInputs, location)
	_, disconnect = self.modules.hull:update(moduleInputs, location)
	
	return newObject, disconnect
end

return MissileLauncherBlock
