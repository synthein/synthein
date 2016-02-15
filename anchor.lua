local Part = require("part")

local Anchor = {}
Anchor.__index = Anchor
setmetatable(Anchor, Part)

function Anchor.create()
	local self = Part.create("anchor")
	setmetatable(self, Anchor)

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "anchor"

	return self
end

return Anchor
