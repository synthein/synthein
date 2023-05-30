-- Components
local Hull = require("world/shipparts/modules/hull")

-- Class Setup
local Part = require("world/shipparts/part")
local ShieldBlock = class(Part)

-- Graphics
local Draw = require("world/draw")
ShieldBlock.image = Draw.loadImage("shield")
local imageFunction = Draw.createDrawBlockFunction(ShieldBlock.image)

function ShieldBlock:__create()
	self.modules["hull"] = Hull(imageFunction, 10)
	self.isShield = true

	return self
end

function ShieldBlock:update(moduleInputs, location)
	local newObject, disconnect = self.modules.hull:update(
		moduleInputs, location)
	
	return newObject, disconnect
end

return ShieldBlock
