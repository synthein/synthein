local Util = require("util")

local Shot = {}
Shot.__index = Shot

function Shot.create(x, y, angle, sourceStructure, sourcePart)
	local self = {}
	setmetatable(self, Shot)
	local imageName = "shot"
	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.physicsShape = love.physics.newRectangleShape(self.width, self.height)
	self.x = x
	self.y = y
	self.angle = angle
	self.time = 0
	self.destroy = false
	self.sourceStructure = sourceStructure
	self.sourcePart = sourcePart
	return self
end

function Shot:update(dt)
	local dx, dy = Util.vectorComponents(500 * dt, self.angle - math.pi/2)
	self.x = self.x + dx
	self.y = self.y + dy
	self.time = self.time + dt
	if self.time > 10 then
		self.destroy = true
	end
	return self.x, self.y, self.time
end

function Shot:draw(globalOffsetX, globalOffsetY)
	love.graphics.draw(
		self.image,
		self.x - globalOffsetX,
		self.y - globalOffsetY,
		self.angle, 1, 1, self.width/2, self.height/2)
end

return Shot
