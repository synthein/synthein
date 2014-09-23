local Part = {}
Part.__index = Part

function Part.create(imageName)
	local self = {}
	setmetatable(self, Part)

	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
	self.shape = nil
	self.thrust = 0
	self.torque = 0
	self.type = "generic"

	return self
end

function Part:draw(x, y, angle, globalOffsetX, globalOffsetY)
	love.graphics.draw(
		self.image,
		love.graphics.getWidth()/2 - globalOffsetX + x,
		love.graphics.getHeight()/2 - globalOffsetY + y,
		angle, 1, 1, self.width/2, self.height/2)
end

return Part
