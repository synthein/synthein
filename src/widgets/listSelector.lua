local ListSelector = class()

local scrollSpeed = 150

function ListSelector:__create(size, x, y, width, height, list)
	self.width = width
	self.height = height	
	self.size = size
	
	self.scrollY = 0
	self.scrollTo = 0
	
	self.selected = 0
	
	self.font = love.graphics.newFont(size * 0.6)

	self:setList(list)
	self.visableCanvas = love.graphics.newCanvas(width, height)
	self.highlightCanvas = love.graphics.newCanvas(width, size)
	
	love.graphics.setCanvas(self.highlightCanvas)
	love.graphics.setColor(1, 1, 1, 0.75)
	
	local border = size/8
	love.graphics.rectangle(
		"fill",
		border, border,
		width - 2 * border, size - 2 * border)

	love.graphics.setColor(1, 1, 1)
	love.graphics.setCanvas()

	return self
end

function ListSelector:setList(list)
	self.list = list
	local size = self.size
	local border = size/8
	local doubleBorder = size/4
	
	-- Canvases must have nonzero dimensions.
	self.buttonCanvas = love.graphics.newCanvas(self.width, self.size * #list + 1)
	love.graphics.setCanvas(self.buttonCanvas)

	love.graphics.clear(0.8, 0.8, 0.8)
	love.graphics.setColor(0.4, 0.4, 0.4)
	for i, name in ipairs(list) do
		love.graphics.rectangle(
			"fill",
			border, (i-1) * size + border,
			self.width - size/4, size - doubleBorder)
	end
	
	self.textCanvas = love.graphics.newCanvas(self.width, size * #list + 1)
	love.graphics.setCanvas(self.textCanvas)
	
	local previousFont = love.graphics.getFont()
	love.graphics.setFont(self.font)

	love.graphics.setColor(0, 0, 0)
	for i, name in ipairs(list) do
		love.graphics.print(name, self.size/4, (i-0.8) * self.size)
	end

	love.graphics.setFont(previousFont)
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	
	--TODO do something with this
	--[[
	self.scrollMax = canvas:getHeight() - self.visibleHeight
	if self.scrollMax < 0 then
		self.scrollMax = 0
	end--]]
end

function ListSelector:getButtonAt(x, y)
	local width = self.width
	local height = self.height
	local index = 0
	if 0 < x and x < width and 0 < y and y < height then
		index = math.floor((y + self.scrollY) / self.size + 1)
	end
	if index > #self.list then
		index = 0
	end

	return index
end

function cursorpressed(key, cursor)
	self.selected = self:getButtonAt(cursor.x, cursor.y)
	if key == "confirm" then
		local s = self.selected
		local len = #self.list
		if s <= len and s > 0 then
			return s
		end
	end
end

function cursorreleased(key, cursor)
end

function ListSelector:pressed(control)
	local key = control.menu

	local s = self.selected
	local len = #self.list
	if len ~= 0 then
		if key == "up" then
			s = s - 1
			if s < 1 then s = s + len end
		elseif key == "down" then
			s = s + 1
			if s > len then s = s - len end
		elseif key == "confirm" then
			if s <= len and s > 0 then
				return s
			end
		end
	end
	self.selected = s
end

function ListSelector:released(key)
end

function ListSelector:wheelmoved(x, y)
	if y < 0 then
		self.scrollTo = self.scrollTo + 15
		if self.scrollTo > self.scrollMax then
			self.scrollTo = self.scrollMax
		end
	elseif y > 0 then
		self.scrollTo = self.scrollTo - 15
		if self.scrollTo < 0 then
			self.scrollTo = 0
		end
	end
end

function ListSelector:update(dt)
	if self.scrollY < self.scrollTo then
		self.scrollY = self.scrollY + dt * scrollSpeed
		if self.scrollY > self.scrollTo then
			self.scrollY = self.scrollTo
		end
	elseif self.scrollY > self.scrollTo then
		self.scrollY = self.scrollY - dt * scrollSpeed
		if self.scrollY < self.scrollTo then
			self.scrollY = self.scrollTo
		end
	end

	--TODO add code for handling if the seleted name is off the top or bottom

end

function ListSelector:resize()
end

function ListSelector:draw(viewPort, cursor)
	self.selected = self:getButtonAt(cursor.x, cursor.y)

	local size = self.size
	local selected = self.selected
	local scrollY = self.scrollY

	-- When nothing is selected, self.selected == 0.
	local highlightY = size * (selected - 1) - scrollY
	
	local visableCanvas = self.visableCanvas
	
	love.graphics.setCanvas(visableCanvas)
	love.graphics.setColor(1, 1, 1)

	love.graphics.draw(self.buttonCanvas, 0, 0)
	love.graphics.draw(self.highlightCanvas, 0, highlightY)
	love.graphics.draw(self.textCanvas, 0, -scrollY)

	love.graphics.setCanvas()
	
	return visableCanvas
end

return ListSelector

