local PartRegistry = require("world/shipparts/partRegistry")

local ShipEditor = {}
ShipEditor.__index = ShipEditor

ShipEditor.scrollSpeed = 150

-- Make a ShipEditor in the center of the screen from a list of buttons.
function ShipEditor.create(y)
	local self = {}
	setmetatable(self, ShipEditor)

	local size = 30
	self.size = size
	self.y = y
	self.width = size * 8
	self.height = size * 4
	self.spacing = 10
	self.textHeight = size * 8
	self.scrollY = 0
	self.scrollVelocity = 0
	self.selectedButton = 5
--	if love.graphics then self.font = love.graphics.newFont(size * 7) end
--	if love.graphics then self.visibleHeight = love.graphics.getHeight() - self.y - self.buttonMargin end

	return self
end

function ShipEditor:getButtonAt(x, y)
	local ShipEditorCenter = love.graphics.getWidth() / 2
	if x > ShipEditorCenter - self.buttonWidth / 2
	   and x < ShipEditorCenter + self.buttonWidth / 2
	   and y > self.y then
		local yRef = y - self.y - self.buttonMargin + self.scrollY
		local index = math.floor(yRef/(self.buttonHeight + self.buttonSpacing)) + 1
		local remainder = yRef % (self.buttonHeight + self.buttonSpacing)
		if index > 0 and index <= #self.buttons and
		   remainder < self.buttonHeight then
			return index
		end
	end
	return nil
end

function ShipEditor:getHeight()
--	return self.buttonMargin * 2
--	       + #self.buttons * self.buttonHeight
--	       + (#self.buttons - 1) * self.buttonSpacing
end

function ShipEditor:update(dt)
	self.scrollY = self.scrollY + self.scrollVelocity * dt
	self.scrollVelocity = self.scrollVelocity * 0.98

	local ShipEditorHeight = self:getHeight()
	if self.visibleHeight and ShipEditorHeight > self.visibleHeight then
		-- Reset scroll position and velocity if we hit the top or bottom of
		-- the ShipEditor.
		-- Top of the ShipEditor:
		if self.scrollY < 0 then
			self.scrollY = 0
			if self.scrollVelocity < 0 then
				self.scrollVelocity = 0
			end
		end

		-- Bottom of the ShipEditor:
		if self.scrollY > ShipEditorHeight - self.visibleHeight then
			self.scrollY = ShipEditorHeight - self.visibleHeight
			if self.scrollVelocity > ShipEditorHeight then
				self.scrollVelocity = 0
			end
		end

		-- Scroll toward the selected button if it is off the screen.
		if self.selectedButton then
			local buttonTopY =
				self.y
				+ (self.buttonHeight + self.buttonSpacing) * (self.selectedButton - 1)
				- self.scrollY
			local buttonBottomY =
				self.y
				+ (self.buttonHeight + self.buttonSpacing) * (self.selectedButton - 1)
				+ self.buttonHeight - self.scrollY

			if buttonTopY < self.y then
				self.scrollVelocity = -self.scrollSpeed
			elseif buttonBottomY > self.y + self.visibleHeight then
				self.scrollVelocity = self.scrollSpeed
			end
		end
	end
end

local partsTableAll = {}
local partsTable = {}
local coreParts = {}
coreParts.a = true
coreParts.p = true
coreParts.n = true

for k, v in pairs(PartRegistry.partsList) do
	table.insert(partsTableAll, k)
	if not coreParts[k] then
		table.insert(partsTable, k)
	end
end

function ShipEditor:draw()
	love.graphics.push("all")
	local x = love.graphics.getWidth() / 2 - self.width / 2
	local y = self.y

	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.rectangle(
		"fill",
		x-3, y-3,
		self.width + 6, self.height + 6)

	local stencilFunction = function()
		love.graphics.rectangle(
			"fill",
			x-3, y-3,
			self.width + 6, self.height + 6)
	end

	love.graphics.stencil(stencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)

	for i, k in ipairs(partsTable) do
		im = i-1
		imageX = im % 8
		imageY = (im - imageX) / 8
		imageX = imageX * 30 + x
		imageY = imageY * 30 + y

		love.graphics.setColor(1, 1, 1)
		if i == self.selectedButton then
			love.graphics.rectangle("fill", imageX + 3, imageY + 3, 24, 24)
		end
		love.graphics.draw(PartRegistry.partsList[partsTable[i]].image, imageX + 5, imageY + 5)
	end

	love.graphics.pop()
end

function ShipEditor:resize(_, h) --(w, h)
	self.visibleHeight = h - self.y
end

function ShipEditor:keypressed(key)
	if key == "up" then
		if self.selectedButton > 1 then
			self.selectedButton = self.selectedButton - 1
		end
	elseif key == "down" then
		if self.selectedButton < #self.buttons then
			self.selectedButton = self.selectedButton + 1
		end
	elseif key == "return" then
		return self.buttons[self.selectedButton]
	end
end

function ShipEditor:mousemoved(x, y)
	local index = self:getButtonAt(x, y)
	if index == nil then
		return
	end
	self.selectedButton = index
end

function ShipEditor:wheelmoved(_, y) --(x, y)
	self.selectedButton = nil
	if self:getHeight() > self.visibleHeight then
		if y < 0 then
			self.scrollVelocity = self.scrollSpeed
		elseif y > 0 then
			self.scrollVelocity = -self.scrollSpeed
		end
	end
end

function ShipEditor:pressed(x, y)
	local index = self:getButtonAt(x, y)
	if index == nil then
		return nil
	end
	return self.buttons[index]
end

return ShipEditor
