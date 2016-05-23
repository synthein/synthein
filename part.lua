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
	self.destroy = false
	self.type = "generic"
	self.health = 10

	return self
end

function Part:loadData(data)
	if data[1] then self.health = data[1] end
end

function Part:takeDamage()
	self.health = self.health - 1
	if self.health <= 0 then
		self.destroy = true
	end
end

function Part:draw(x, y, angle, cameraX, cameraY)
	love.graphics.draw(
		self.image,
		x - cameraX,
		y - cameraY,
		angle, 1, 1, self.width/2, self.height/2)
end

return Part
