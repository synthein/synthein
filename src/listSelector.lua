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
	
	self.horRef = 0
	self.verRef = 0
	self.horOff = 0
	self.verOff = 0
	
	self.scrollY = 0
	self.scrollTo = 0
	
	local canvas = love.graphics.newCanvas(width, size * #list)

	--self.buttonWidth = size * 90
	--self.buttonHeight = size * 10
	--self.buttonSpacing = size * 5
	--self.buttonMargin = (self.width - self.buttonWidth) / 2
	
	self.setList(list)
	
	return self
end

function ListSelector:setList(list)
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

function ListSelector:draw(viewPort)
	local screenWidth = viewPort.width
	local screenHeight = viewPort.height

	local x = self.x + self.horRef * screenWidth  - self.width  * self.horOff
	local y = self.y + self.verRef * screenHeight - self.height * self.verOff

	love.graphics.rectangle(
		"fill",
		x, y,
		self.width, self.height
	)
--[[
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.mainCanvas, border, border)

	local height = love.graphics.getHeight() - 2 * (bs)
	local width  = love.graphics.getWidth()  - 2 * (bs)

	local canvas = love.graphics.newCanvas(nameWidth, height)
	love.graphics.setCanvas(canvas)

	love.graphics.setColor(0.4, 0.4, 0.4)
	-- When nothing is selected, self.selected == 0.
	local highlightY = nameHeight * (self.selected - 1) - self.scrollY
	love.graphics.rectangle("fill", 0, highlightY, nameWidth, nameHeight)
	love.graphics.draw(self.fileCanvas, 0, - self.scrollY)

	love.graphics.setCanvas()

	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(canvas, bs, bs)

	self.nameBox = {bs, bs, bs + nameWidth, height}

	local nWs = nameWidth + spacing
	local previewX = bs + nWs
	local previewY = bs
	local previewWidth = width - nWs
	local previewHeight = height

	love.graphics.setColor(0, 0, 0)
	love.graphics.print("No Preview", previewX, previewY)
--]]
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

return ListSelector

--[[
function LoadMenu:createMainCanvas()
	self.visibleHeight = love.graphics.getHeight() - 2 * bs
	self.nameBox = {bs, bs, bs + nameWidth, bs + self.visibleHeight}

	local width = love.graphics.getWidth() - 2 * border
	local height = love.graphics.getHeight() - 2 * border

	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas(canvas)

	love.graphics.clear(0.6, 0.6, 0.6)

	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle( "fill",
		spacing, spacing,
		nameWidth, height - 2 * spacing)

	love.graphics.setCanvas()

	self.mainCanvas = canvas
end

function LoadMenu:refreshFiles()
	local filenames = {}
	local files = love.filesystem.getDirectoryItems(self.dir)
	local selected = 0
	for _, fileName in pairs(files) do
		local name = string.gsub(fileName, ".txt", "")
		table.insert(filenames, name)
		selected = 1
	end

	self.filenames = filenames
	self.selected = selected

	-- Canvases must have nonzero dimensions.
	local canvas = love.graphics.newCanvas(200, nameHeight * (#filenames + 1))
	love.graphics.setCanvas(canvas)

	love.graphics.setColor(0, 0, 0)
	for i, name in ipairs(filenames) do
		love.graphics.print(name, 5, nameHeight * (i - 1) + 5)
	end

	love.graphics.setCanvas()

	self.fileCanvas = canvas
	self.scrollMax = canvas:getHeight() - self.visibleHeight
	if self.scrollMax < 0 then
		self.scrollMax = 0
	end
end

--]]
