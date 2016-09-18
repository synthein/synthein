local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

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
	cursorCoordX =   X - SCREEN_WIDTH /2  + self:getX()
	cursorCoordY = -(Y - SCREEN_HEIGHT/2) + self:getY()
	return cursorCoordX, cursorCoordY
end

function Camera:update(width, height)
	self.width = width
	self.height = height
end

function Camera:draw(image, x, y, angle, sx, sy, ox, oy)
	love.graphics.draw(image,
					    (x - self.x) + SCREEN_WIDTH/2,
					   -(y - self.y) + SCREEN_HEIGHT/2,
					   -angle, sx, sy, ox, oy)
end

return Camera
