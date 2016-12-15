local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

	self.compass = love.graphics.newImage("res/images/compass.png")
	return self
end

function Camera:getX()
	return self.x
end

function Camera:getY()
	return self.y
end

function Camera:getPosition()
	return self.x, self.y
end

function Camera:setX(newX)
	self.x = newX
end

function Camera:setY(newY)
	self.y = newY
end

function Camera:getCursorCoords(X, Y)
	cursorCoordX =   X - self.scissorWidth /2  + self.x
	cursorCoordY = -(Y - self.scissorHeight/2) + self.y
	return cursorCoordX, cursorCoordY
end

function Camera:setScissor(x, y, width, height)
	self.scissorX = x
	self.scissorY = y
	self.scissorWidth = width
	self.scissorHeight = height
end

function Camera:draw(image, x, y, angle, sx, sy, ox, oy)
    love.graphics.setScissor(self.scissorX, self.scissorY,
							 self.scissorWidth, self.scissorHeight)
	love.graphics.draw(image,
					    (x - self.x) + self.scissorWidth/2,
					   -(y - self.y) + self.scissorHeight/2,
					   -angle, sx, sy, ox, oy)
    love.graphics.setScissor()
end

function Camera:drawExtras()
    love.graphics.setScissor(self.scissorX, self.scissorY,
							 self.scissorWidth, self.scissorHeight)
	love.graphics.draw(
			self.compass,
			self.scissorWidth - 60,
			self.scissorHeight - 60,
			math.atan2(self.x, self.y) + math.pi,
			1, 1, 25, 25)
    love.graphics.setScissor()
end

return Camera
