local Part = {}
Part.__index = Part

function Part.create(imageName)
	local self = {}
	setmetatable(self, Part)

	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.physicsShape = nil
	self.connectableSides = {true, true, true, true}
	self.thrust = 0
	self.torque = 0
	self.gun = false
	self.type = "generic"

	return self
end

function Part:draw(x, y, angle, globalOffsetX, globalOffsetY)
	love.graphics.draw(
		self.image,
		SCREEN_WIDTH/2 - globalOffsetX + x,
		SCREEN_HEIGHT/2 - globalOffsetY + y,
		angle, 1, 1, self.width/2, self.height/2)
end

return Part
