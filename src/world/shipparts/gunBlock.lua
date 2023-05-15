-- Components
local Hull = require("world/shipparts/hull")
local Gun = require("syntheinrust").gun

-- Class Setup
local Part = require("world/shipparts/part")
local GunBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
GunBlock.image = Draw.loadImage("gun")
local imageFunction = Draw.createDrawBlockFunction(GunBlock.image)

function GunBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 10)

	self.modules["gun"] = Gun()

	-- GunBlocks can only connect to things on their bottom side.
	self.connectableSides[1] = false
	self.connectableSides[2] = false
	self.connectableSides[4] = false

	return self
end

function GunBlock:update(moduleInputs, location)
	local newObject, disconnect
	
	newObject, _ = self.modules.gun:update(moduleInputs, location)
	_, disconnect = self.modules.hull:update(moduleInputs, location)
	
	return newObject, disconnect
end

return GunBlock
