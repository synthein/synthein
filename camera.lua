local Util = require("util")

local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

	self.zoom = 1
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

function Camera:getCursorCoords(x, y)
	cursorX = (x - self.scissorWidth/2 - self.scissorX)/self.zoom + self.x
	cursorY = -(y - self.scissorHeight/2 - self.scissorY)/self.zoom + self.y
	return cursorX, cursorY
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
	x = self.zoom*(x - self.x) + self.scissorX + self.scissorWidth/2
	y = -self.zoom*(y - self.y) + self.scissorY + self.scissorHeight/2
	love.graphics.draw(image, x, y, -angle, self.zoom*sx, self.zoom*sy, ox, oy)
    love.graphics.setScissor()
end

function Camera:drawExtras()
    love.graphics.setScissor(self.scissorX, self.scissorY,
							 self.scissorWidth, self.scissorHeight)
	love.graphics.draw(
			self.compass,
			self.scissorX + self.scissorWidth - 60,
			self.scissorY + self.scissorHeight - 60,
			math.atan2(self.x, self.y) + math.pi,
			1, 1, 25, 25)
    love.graphics.setScissor()
end

function Camera:drawCircleMenu(centerX, centerY, angle, size, strength)
    love.graphics.setScissor(self.scissorX, self.scissorY,
							 self.scissorWidth, self.scissorHeight)
	local x, y
	x =  self.zoom * (centerX - self.x) + self.scissorX + self.scissorWidth/2
	y = -self.zoom * (centerY - self.y) + self.scissorY + self.scissorHeight/2
	Camera.circleMenuX = x
	Camera.circleMenuY = y
	size = self.zoom * size
	Camera.circleMenuAngle = angle
	Camera.circleMenuSize = size
	Camera.circleMenuDivivsion = #strength
	love.graphics.stencil(Camera.circleMenuStencilFunction, "replace", 1)
	love.graphics.setStencilTest("equal", 0)
	love.graphics.setLineWidth(size)
	for i, color in ipairs(strength) do
		if color ~= 0 then
			if color == 1 then
				love.graphics.setColor(32, 64, 144, 192)
			elseif color == 2 then
				love.graphics.setColor(80, 128, 192, 192)
			end
			love.graphics.arc("line", "open", x, y, 
				math.ceil(3.5*size),
				- angle + math.pi * (-0.5 + ((i-1)*2-1)/#strength),
				- angle + math.pi * (-0.5 + ((i)*2-1)/#strength), 5*size)
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setStencilTest()
    love.graphics.setScissor()
end

function Camera:circleMenuStencilFunction()
	love.graphics.setLineWidth(math.ceil(Camera.circleMenuSize/5))
	for i = 1,Camera.circleMenuDivivsion do
		local x, y = Util.vectorComponents(5 * Camera.circleMenuSize,
						- Camera.circleMenuAngle
						+ math.pi * (-0.5 + (i*2-1)/Camera.circleMenuDivivsion))
		x = x + Camera.circleMenuX
		y = y + Camera.circleMenuY
		love.graphics.line(x, y, Camera.circleMenuX, Camera.circleMenuY)
	end
end

return Camera
