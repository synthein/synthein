local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

	return self
end

function Camera.getX()
	return self.x
end

function Camera.getY()
	return self.y
end

function Camera.getPosition()
	return self.x, self.y
end

function Camera.setX(newX)
	self.x = newX
end

function Camera.setY(newY)
	self.y = newY
end

return Camera
