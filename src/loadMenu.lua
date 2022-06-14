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
	self.selected = 1
	self.scrollY = 0
	self.scrollVelocity = 0
	self.filenames = {"har", "de", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har", "har har"}

	if love.graphics then self.font = love.graphics.newFont(5 * 7) end
	if love.graphics then self.visibleHeight = love.graphics.getHeight() - 2 * bs end
	if love.graphics then self:createMainCanvas() end
	if love.graphics then self:createFileCanvas() end
end

function LoadMenu:createMainCanvas()
	local names = self.filenames
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

function LoadMenu:createFileCanvas()
	local names = self.filenames
	local canvas = love.graphics.newCanvas(200, nameHeight * #names)
	love.graphics.setCanvas(canvas)

	love.graphics.setColor(0, 0, 0)
	for i, name in ipairs(names) do
		love.graphics.print(name, 5, nameHeight * (i - 1) + 5)
	end

	love.graphics.setCanvas()

	self.fileCanvas = canvas
end

function LoadMenu:getButtonAt(x, y)
	local left, top, right, bottom = unpack(self.nameBox)

	local index = 1
	if left < x and x < right and top < y and y < bottom then
		index = math.floor((y - top + self.scrollY) / nameHeight + 1)
	end
	if index > #self.filenames then
		index = 1
	end

	return index
end

function LoadMenu:getHeight()
	return #self.filenames * 5 * 10
		+ (#self.filenames - 1) * 5 * 5
end

function LoadMenu:update(dt)
	self.scrollY = self.scrollY + self.scrollVelocity * dt
	self.scrollVelocity = self.scrollVelocity * 0.98

	local menuHeight = self:getHeight()
	if self.visibleHeight and menuHeight > self.visibleHeight then
		-- Reset scroll position and velocity if we hit the top or bottom of
		-- the menu.
		-- Top of the menu:
		if self.scrollY < 0 then
			self.scrollY = 0
			if self.scrollVelocity < 0 then
				self.scrollVelocity = 0
			end
		end

		-- Bottom of the menu:
		if self.scrollY > menuHeight - self.visibleHeight then
			self.scrollY = menuHeight - self.visibleHeight
			if self.scrollVelocity > menuHeight then
				self.scrollVelocity = 0
			end
		end

		-- Scroll toward the selected button if it is off the screen.
		if self.selected then
			local buttonTopY =
				100
				+ nameHeight * (self.selected - 1) - self.scrollY
			local buttonBottomY =
				100
				+ nameHeight * (self.selected - 1) - self.scrollY

			if buttonTopY < 100 then
				self.scrollVelocity = -scrollSpeed
			elseif buttonBottomY > 100 + self.visibleHeight then
				self.scrollVelocity = scrollSpeed
			end
		end
	end
end

function LoadMenu:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.mainCanvas, border, border)

	local height = love.graphics.getHeight() - 2 * (bs)
	local width  = love.graphics.getWidth()  - 2 * (bs)

	local canvas = love.graphics.newCanvas(nameWidth, height)
	love.graphics.setCanvas(canvas)

	love.graphics.setColor(0.4, 0.4, 0.4)
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

function LoadMenu:resize(_, h) --(w, h)
	self.visibleHeight = h - 100
	self:createMainCanvas()
end

function LoadMenu:keypressed(key)
	if key == "up" then
		if self.selected == nil then
			self.selected = #self.filenames
		elseif self.selected > 1 then
			self.selected = self.selected - 1
		end
	elseif key == "down" then
		if self.selected == nil then
			self.selected = 1
		elseif self.selected < #self.filenames then
			self.selected = self.selected + 1
		end
	elseif key == "return" then
		return self.filenames[self.selected]
	end
end

function LoadMenu:mousemoved(x, y)
	local index = self:getButtonAt(x, y)
	if index == nil then
		return
	end
	self.selected = index
end

function LoadMenu:wheelmoved(_, y) --(x, y)
	--self.selected = nil
	if self:getHeight() > self.visibleHeight then
		if y < 0 then
			--self.scrollVelocity = scrollSpeed
			self.scrollY = self.scrollY + 15
		elseif y > 0 then
			--self.scrollVelocity = -scrollSpeed
			self.scrollY = self.scrollY - 15
		end
	end
end

function LoadMenu:pressed(x, y)
	local index = self:getButtonAt(x, y)
	if index == nil then
		return nil
	end
	return self.filenames[index]
end

return LoadMenu
