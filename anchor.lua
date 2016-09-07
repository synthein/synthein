local Part = require("part")

local Anchor = {}
Anchor.__index = Anchor
setmetatable(Anchor, Part)

function Anchor.create()
	local self = Part.create()
	setmetatable(self, Anchor)

	self.image = love.graphics.newImage("res/images/anchor.png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.type = "anchor"

	return self
end

return Anchor
