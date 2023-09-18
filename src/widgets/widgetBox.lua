local WidgetBox = class()

function WidgetBox:__create(width, height)
	self.canvas = love.graphics.newCanvas(width, height)
	self.widgets = {}
	self.withinIterator	
end

local function gernerateScaleTable(horRef, verRef, horOff, verOff)
	horRef = (horRef == "left") and 0 or (horRef == "right" ) and 1 or 0.5
	verRef = (verRef == "top" ) and 0 or (verRef == "bottom") and 1 or 0.5
	horOff = (horOff == "left") and 0 or (horOff == "right" ) and 1 or 0.5
	verOff = (verOff == "top" ) and 0 or (verOff == "bottom") and 1 or 0.5
	return {horRef, verRef, horOff, verOff}
end


function WidgetBox:keypressed(key)
	
end

function WidgetBox:mousemoved(x, y)

end

function WidgetBox:wheelmoved(x, y)

end

function WidgetBox:update()
end

return WidgetBox







function CanvasUtils.copyCanvas(source, x, y, scaleTable, color, destination)
	local horRef, verRef, horOff, verOff = unpack(scaleTable)
	love.graphics.setColor(unpack(color or {1, 1, 1}))
	
	local srcWidth, srcHeight = source:getDimensions()
	local desWidth, desHeight = (destination or love.window):getDimensions()

	love.graphics.setCanvas(destination)

	local x = x + desWidth  * horRef - srcWidth  * horOff
	local y = y + desHeight * verRef - srcHeight * verOff
	
	love.graphics.draw(source, x, y)
	
	love.graphics.setCanvas()
end

function CanvasUtils.isWithin(curX, curY, canX, canY, source, destination, scaleTable)
	local horRef, verRef, horOff, verOff = unpack(scaleTable)
	local srcWidth, srcHeight = source:getDimensions()
	local desWidth, desHeight = (destination or love.window):getDimensions()

	local x = curX - canX - desWidth  * horRef + srcWidth  * horOff
	local y = curY - canY - desHeight * verRef + srcHeight * verOff
	
	local within = 0 <= x and x <= srcWidth and 0 <= y and y <= srcWidth
	
	return within, x, y
end

function ListSelector:__create(size, x, y, width, height, list)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	
	self.size = size
	
	self.horRef = 0
	self.verRef = 0
	self.horOff = 0
	self.verOff = 0
	
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
	
end
--[[
function ListSelector:toParentCoords(viewPort)
	local screenWidth = viewPort.width
	local screenHeight = viewPort.height

	local x = self.x + self.horRef * screenWidth  - self.width  * self.horOff
	local y = self.y + self.verRef * screenHeight - self.height * self.verOff
	
	return x,y
end
--
function ListSelector:toLocalCoords(viewPort, x, y)
	local screenWidth = viewPort.width
	local screenHeight = viewPort.height

	x = x - self.x - self.horRef * screenWidth + self.width  * self.horOff
	y = y - self.y - self.verRef * screenHeight + self.height * self.verOff
	
	return x, y
end
--]]
function ListSelector:getButtonAt(x, y)
	local width = self.width
	local height = self.height
	local index = 0
	if 0 < x and x < width and 0 < y and y < height then
		index = math.floor((y + self.scrollY) / self.size + 1)
		self.hovering = true
	else
		self.hovering = false
	end
	if index > #self.list then
		index = 0
	end

	return index
end

function ListSelector:mousemoved(x, y)
	local index = self:getButtonAt(x, y)
	self.selected = index
end


function ListSelector:pressed()
	local index = self.selected
	if index ~= 0 and self.hovering then
		return index
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

function ListSelector:cursorHighlight(x, y)
	local index = self:getButtonAt(x, y)
	if index ~=0 then
		self.selected = index
	end
end

function ListSelector:draw(viewPort, cursor)
--[[
	local cx, cy = self:toLocalCoords(viewPort, cursor.x, cursor.y)
	local index = self:getButtonAt(cx, cy)
	if index ~=0 then
		self.selected = index
	end--]]
	
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

