-- Components
local Hull = require("world/shipparts/hull")

-- Graphics
local Draw = require("world/draw")
local imageFunction = Draw.createDrawBlockFunction("anchor")

-- Class Setup
local Part = require("world/shipparts/part")
local Anchor = class(require("world/shipparts/part"))

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

return Anchor
