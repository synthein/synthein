local Anchor = class(require("world/shipparts/part"))

function Anchor:__create()
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
