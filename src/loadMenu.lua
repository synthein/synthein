local LoadMenu = class()

local scrollSpeed = 150
local border = 100
local spacing = 20
local bs = border + spacing
local nameHeight = 30
local nameWidth = 200

-- Make a menu in the center of the screen from a list of buttons.
function LoadMenu:__create(dir)
	self.dir = dir
	self.scrollY = 0
	self.scrollTo = 0

	self:reset()
end

function LoadMenu:reset()
	self:createMainCanvas()
	self:refreshFiles()
end

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

function LoadMenu:getButtonAt(x, y)
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

function LoadMenu:loadfile(index)
	return self.dir .. "/" .. self.filenames[index] .. ".txt"
end

function LoadMenu:update(dt)
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

function LoadMenu:draw()
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
	--[[love.graphics.rectangle(
		"fill",
		previewX, previewY,
		previewWidth, previewHeight)]]
	love.graphics.print("No Preview", previewX, previewY)
end

function LoadMenu:resize(w, h)
	--TODO Add any other items here
	-- visibleHeight and scrollMax need recaculation
	self:createMainCanvas()
end

function LoadMenu:keypressed(key)
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

function LoadMenu:mousemoved(x, y)
	local index = self:getButtonAt(x, y)
	self.selected = index
end

function LoadMenu:wheelmoved(x, y)
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

function LoadMenu:pressed(x, y)
	local index = self:getButtonAt(x, y)
	if index == 0 then
		return nil
	end
	return self:loadfile(index)
end

return LoadMenu
