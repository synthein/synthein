local Camera = {}
Camera.__index = Camera

function Camera.create()
	local self = {}
	setmetatable(self, Camera)

	self.x = 0
	self.y = 0
	self.zoomInt = 8
	self:adjustZoom(0)
	self.scissorX = 0
	self.scissorY = 0
	self.scissorWidth = 0
	self.scissorHeight = 0

	self.graphics = {}
	setmetatable(self.graphics, self)

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
	local x =  (cursorX - self.scissorWidth/2  - self.scissorX) / self.zoom + self.x
	local y = -(cursorY - self.scissorHeight/2 - self.scissorY) / self.zoom + self.y
	return x, y
end

function Camera:getScreenCoords(worldX, worldY, a, b)
	local x =  self.zoom * (worldX - self.x) + self.scissorX + self.scissorWidth/2
	local y = -self.zoom * (worldY - self.y) + self.scissorY + self.scissorHeight/2
	a = self.zoom * a
	b = self.zoom * b
	return x, y, a, b
end

function Camera:getWorldBorder()
	return self.x - self.scissorWidth /(2 * self.zoom),
		   self.y - self.scissorHeight/(2 * self.zoom),
		   self.x + self.scissorWidth /(2 * self.zoom),
		   self.y + self.scissorHeight/(2 * self.zoom)
end

-- Make sure the correct transforms are active
function Camera:getAllPoints()
	local pointTable = {}
	local table_insert = table.insert
	local inverseTransform = love.graphics.inverseTransformPoint
	for y = 0, self.scissorHeight - 1 do
		local row = {}
		for x = 0, self.scissorWidth - 1 do
			table_insert(row, {inverseTransform(x, y)})
		end
		table_insert(pointTable, row)
	end

	return pointTable
end

function Camera:adjustZoom(step)

	self.zoomInt = self.zoomInt + step

	local remainder = self.zoomInt%6
	local exponential = (self.zoomInt - remainder)/6

	self.zoom = 10 ^ exponential

	if remainder == 1 then
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

function Camera:limitCursor(cursorX, cursorY)
	if cursorX < self.scissorX then
		cursorX = self.scissorX
	elseif cursorX > self.scissorX + self.scissorWidth then
		cursorX = self.scissorX + self.scissorWidth
	end
	if cursorY < self.scissorY then
		cursorY = self.scissorY
	elseif cursorY > self.scissorY + self.scissorHeight then
		cursorY = self.scissorY + self.scissorHeight
	end
	return cursorX, cursorY
end

function Camera:draw(image, x, y, angle, sx, sy, ox, oy)
	love.graphics.setScissor(self:getScissor())

	x, y, sx, sy = self:getScreenCoords(x, y, sx, sy)
	love.graphics.draw(image, x, y, -angle, sx, sy, ox, oy)

	love.graphics.setScissor()
end

function Camera:enable(inWorld)
	love.graphics.setScissor(self:getScissor())
	love.graphics.translate(self.scissorX, self.scissorY)
	if inWorld then
		love.graphics.translate(self.scissorWidth/2, self.scissorHeight/2)
		love.graphics.scale(self.zoom, -self.zoom)
		love.graphics.translate(- self.x, - self.y)
		--x =  self.zoom * (worldX - self.x) + self.scissorX + self.scissorWidth/2
		--y = -self.zoom * (worldY - self.y) + self.scissorY + self.scissorHeight/2
	end
end

function Camera:disable()
	love.graphics.origin()
	love.graphics.setScissor()
end

function Camera:run(f, inWorld)
	self:enable(inWorld)
	f()
	self:disable()
end

function Camera.wrap(f, inWorld)
	return function(self, ...)
		self.camera:enable(inWorld)
		f(self, ...)
		self.camera:disable()
	end
end

function Camera:print(string, x, y)
	x = x or 0
	y = y or 0
	love.graphics.print(string, self.scissorX + x, self.scissorY + y)
end

return Camera
