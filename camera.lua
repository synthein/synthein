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

function Camera:drawExtras()
	love.graphics.draw(
			self.compass,
			SCREEN_WIDTH-60,
			SCREEN_HEIGHT-60,
			math.atan2(self.x, self.y) + math.pi,
			1, 1, 25, 25)
end

return Camera
