-- Components
local Hull = require("world/shipparts/modules/hull")

local Anchor = class(require("world/shipparts/part"))

-- Graphics
local Draw = require("world/draw")
Anchor.image = Draw.loadImage("anchor")
local imageFunction = Draw.createDrawBlockFunction(Anchor.image)

function Anchor:__create()
	self.modules["hull"] = Hull(imageFunction, 10)

	self.type = "anchor"
	self.team = 1

	return self
end

function Anchor:getTeam()
	return self.team
end

function Anchor:getOrders()
	return {}
end

function Anchor:update(moduleInputs, location)
	local newObject, disconnect = self.modules.hull:update(
		moduleInputs, location)
	
	return newObject, disconnect
end

return Anchor
