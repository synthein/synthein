local Part = require("shipparts/part")

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
