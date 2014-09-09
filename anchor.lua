local Part = require("part")

local Anchor = {}
Anchor.__index = Anchor
setmetatable(Anchor, Part)

function Anchor.create(world, x, y)
	local self = Part.create("anchor")
	setmetatable(self, Anchor)
	
	self.body = love.physics.newBody(world, x, y, "static")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)

	return self
end

return Anchor
