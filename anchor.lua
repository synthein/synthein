local Part = require("part")

local Anchor = {}
Anchor.__index = Anchor
setmetatable(Anchor, Part)

function Anchor.create()
	local self = Part.create("anchor")
	setmetatable(self, Anchor)

	self.shape = love.physics.newRectangleShape(self.width, self.height)

	return self
end

return Anchor
