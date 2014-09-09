local Part = {}
Part.__index = Part

function Part.create(imageName)
	local self = {}
	setmetatable(self, Part)
	
	self.image = love.graphics.newImage("res/images/"..imageName..".png")
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()

	self.isInStructure = false

	return self
end

function Part:draw(offsetX, offsetY)
	love.graphics.draw(self.image,
	                   love.graphics.getWidth()/2 - offsetX + self.body:getX(),
					   love.graphics.getHeight()/2 - offsetY + self.body:getY(),
					   self.body:getAngle()-math.pi/2, 1, 1,
					   self.width/2, self.height/2)
end

function Part:fly(x, y, angle) -- move the block to a particular location smoothly
	-- right now this is anything but smooth...
	self.body:setPosition(x, y)
	self.body:setAngle(angle)
end

return Part
