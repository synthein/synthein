local ListSelector = class()


local scrollSpeed = 150
local border = 100
local spacing = 20
local bs = border + spacing
local nameHeight = 30
local nameWidth = 200


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
	
	self.font = love.graphics.newFont(size * 0.6)

	self:setList(list)
	self.visableCanvas = love.graphics.newCanvas(width, height)

	return self
end

function ListSelector:setList(list)
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

--TODO rename variables
function ListSelector:set_reference_points(horRef, verRef, horOff, verOff)
	if     horRef == "left" then
		self.horRef = 0
	elseif horRef == "center" then
		self.horRef = 0.5
	elseif horRef == "right" then
		self.horRef = 1
	end
	if     verRef == "top" then
		self.verRef = 0
	elseif verRef == "center" then
		self.verRef = 0.5
	elseif verRef == "bottom" then
		self.verRef = 1
	end
	if     horOff == "left" then
		self.horOff = 0
	elseif horOff == "center" then
		self.horOff = 0.5
	elseif horOff == "right" then
		self.horOff = 1
	end
	if     verOff == "top" then
		self.verOff = 0
	elseif verOff == "center" then
		self.verOff = 0.5
	elseif verOff == "bottom" then
		self.verOff = 1
	end
end

--[[

	love.graphics.push("all")
	local x = love.graphics.getWidth() / 2 - self.width / 2
	local y = self.y

	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.rectangle(
		"fill",
		x, y,
		self.width, math.min(self:getHeight(), self.visibleHeight))

	local stencilFunction = function()
		love.graphics.rectangle("fill", x, y,
								self.width, self.visibleHeight)
	end

	love.graphics.stencil(stencilFunction, "replace", 1)
	love.graphics.setStencilTest("greater", 0)

	for i, _ in ipairs(self.buttons) do
		if i == self.selectedButton then
			love.graphics.setColor(0.6, 0.6, 0.6)
		else
			love.graphics.setColor(0.4, 0.4, 0.4)
		end

		love.graphics.rectangle(
			"fill",
			x + self.buttonMargin,
			y + self.buttonMargin + self.buttonHeight * (i - 1)
				+ self.buttonSpacing * (i - 1) - self.scrollY,
			self.buttonWidth, self.buttonHeight
		)
		love.graphics.setColor(1, 1, 1)
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(self.font)
		love.graphics.print(
			self.buttons[i],
			x + self.buttonMargin + 10,
			y + self.buttonMargin + self.buttonHeight * (i - 1)
				+ self.buttonSpacing * (i - 1)
				+ (self.buttonHeight - self.textHeight)/2
				- self.scrollY,
			0, 1, 1, 0, 0, 0, 0
		)
		love.graphics.setFont(previousFont)
	end

	love.graphics.pop()
--]]

function ListSelector:getButtonAt(x, y)
	local left, top, right, bottom = unpack(self.nameBox)

	local index = 1
	if left < x and x < right and top < y and y < bottom then
		index = math.floor((y - top + self.scrollY) / nameHeight + 1)
	end
	if index > #self.filenames then
		index = 0
	end

	return index
end

function ListSelector:keypressed(key)
	local s = self.selected
	local len = #self.filenames
	if not len == 0 then
		if key == "up" then
			s = s - 1
			if s < 1 then s = s + len end
		elseif key == "down" then
			s = s + 1
			if s > len then s = s - len end
		elseif key == "return" then
			return self:loadfile(s)
		end
	end
	self.selected = s
end

function ListSelector:mousemoved(x, y)
	local index = self:getButtonAt(x, y)
	self.selected = index
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

function ListSelector:pressed(x, y)
	local index = self:getButtonAt(x, y)
	if index == 0 then
		return nil
	end
	return self:loadfile(index)
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

function ListSelector:draw(viewPort)
	local screenWidth = viewPort.width
	local screenHeight = viewPort.height

	local size = self.size
	
	love.graphics.setCanvas(self.visableCanvas)

	--TODO delete overiding variables
	self.selected = 1
	
	--TODO add scrool offsets
	love.graphics.draw(self.buttonCanvas, 0, 0)
	love.graphics.setColor(0.6, 0.6, 0.6)
	-- When nothing is selected, self.selected == 0.
	local highlightY = size * (self.selected - 1) - self.scrollY
	local border = size/8
	love.graphics.rectangle(
		"fill",
		border, highlightY + border,
		nameWidth, size - 2 * border)
	
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.textCanvas, 0, -self.scrollY)

	love.graphics.setCanvas()
	
	
	local x = self.x + self.horRef * screenWidth  - self.width  * self.horOff
	local y = self.y + self.verRef * screenHeight - self.height * self.verOff

	love.graphics.draw(self.visableCanvas, x, y)
	
	love.graphics.setColor(1, 1, 1)
end

return ListSelector

