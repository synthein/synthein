local Util = require("util")

local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

	self.zoom = 1
	self.zoomInt = 0
	self.compass = love.graphics.newImage("res/images/compass.png")
	return self
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

function Camera:getWorldCoords(cursorX, cursorY)
	x =  (cursorX - self.scissorWidth/2  - self.scissorX) / self.zoom + self.x
	y = -(cursorY - self.scissorHeight/2 - self.scissorY) / self.zoom + self.y
	return x, y
end

function Camera:getScreenCoords(worldX, worldY, a, b)
	x =  self.zoom * (worldX - self.x) + self.scissorX + self.scissorWidth/2
	y = -self.zoom * (worldY - self.y) + self.scissorY + self.scissorHeight/2
	a = self.zoom * a
	b = self.zoom * b
	return x, y, a, b
end

function Camera:adjustZoom(step)

	self.zoomInt = self.zoomInt + step

	local remainder = self.zoomInt%6
	local exponential = (self.zoomInt - remainder)/6

	self.zoom = 10 ^ exponential

	if remainder == 0 then
	elseif remainder == 1 then
		self.zoom = self.zoom * 1.5 --10 ^ (1 / 6) = 1.47
	elseif remainder == 2 then
		self.zoom = self.zoom * 2   --10 ^ (2 / 6) = 2.15
	elseif remainder == 3 then
		self.zoom = self.zoom * 3   --10 ^ (3 / 6) = 3.16
	elseif remainder == 4 then
		self.zoom = self.zoom * 5   --10 ^ (4 / 6) = 4.64
	elseif remainder == 5 then
		self.zoom = self.zoom * 7   --10 ^ (5 / 6) = 6.81
	end
end

function Camera:setScissor(x, y, width, height)
	self.scissorX = x
	self.scissorY = y
	self.scissorWidth = width
	self.scissorHeight = height
end

function Camera:getScissor()
	return self.scissorX, self.scissorY, self.scissorWidth, self.scissorHeight
end

function Camera:draw(image, x, y, angle, sx, sy, ox, oy)
    love.graphics.setScissor(self:getScissor())

	x, y, sx, sy = self:getScreenCoords(x, y, sx, sy)
	love.graphics.draw(image, x, y, -angle, sx, sy, ox, oy)

    love.graphics.setScissor()
end

function Camera:drawExtras()
    love.graphics.setScissor(self:getScissor())
	--draw the compass in the lower right hand coner 60 pixels from the edges
	love.graphics.draw(
			self.compass,
			self.scissorX + self.scissorWidth - 60,
			self.scissorY + self.scissorHeight - 60,
			math.atan2(self.x, self.y) + math.pi,
			1, 1, 25, 25)
    love.graphics.setScissor()
end

function Camera:drawCircleMenu(centerX, centerY, angle, size, strength)
    love.graphics.setScissor(self:getScissor())

	local x, y
	x, y, size = self:getScreenCoords(centerX, centerY, size, 0)
	Camera.circleMenuX = x
	Camera.circleMenuY = y
	Camera.circleMenuAngle = angle
	Camera.circleMenuSize = size
	Camera.circleMenuDivision = #strength
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

	for i = 1,Camera.circleMenuDivision do
		local angle = Camera.indexToAngle(i, Camera.circleMenuDivision,
										  Camera.circleMenuAngle)
		local x, y = Util.vectorComponents(5 * Camera.circleMenuSize, angle)
		x = x + Camera.circleMenuX
		y = y + Camera.circleMenuY
		love.graphics.line(x, y, Camera.circleMenuX, Camera.circleMenuY)
	end
end

function Camera.indexToAngle(index, division, startAngle)
	--This system is layed out like a clock face
	-- -startAngle	converts it from clockwise to counterclockwise
	-- * math.pi	changes 0 to 2 into 0 to 2pi
	-- -0.5			sets index 1 to the noon position
	-- / division	changes 0 to 2division into 0 to 2
	-- -1			causes the center of index 1 to be straight up
	-- * 2 			changes 0 to division into 0 to 2division 
	return - startAngle + math.pi * (-0.5 + ((index) * 2 - 1) / division)
end

return Camera
