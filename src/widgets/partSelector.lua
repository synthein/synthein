local PartRegistry = require("world/shipparts/partRegistry")

local PartSelector = {}
PartSelector.__index = PartSelector

PartSelector.scrollSpeed = 150

local size = 30
local columns = 4
local rows = 4
local width = size * columns
local height = size * rows
local border = 3
local maxParts = #PartRegistry.noncoreParts

-- Make a PartSelector in the center of the screen from a list of buttons.
function PartSelector.create(y)
	local self = {}
	setmetatable(self, PartSelector)

	self.y = y
	self.selectedButton = 5

	return self
end

function PartSelector:getButtonAt(cursor)
	local x = cursor.x
	local y = cursor.y
	local partSelectorCenter = love.graphics.getWidth() / 2
	if x > partSelectorCenter - width / 2 and
		x < partSelectorCenter + width / 2 and
		y > self.y and
		y < self.y + height then
		menuX = x - partSelectorCenter + width / 2
		menuY = y - self.y
		menuX = math.floor(menuX / size)
		menuY = math.floor(menuY / size)

		return menuY * columns + menuX + 1
	end
end

function PartSelector:cursorpressed(cursor, control)
	if control.menu == "confirm" then
		local index = self:getButtonAt(cursor)
		if index then
			return PartRegistry.noncoreParts[index]
		end
	end
end
	
function PartSelector:pressed(control)
	if control.menu == "up" then
		if self.selectedButton > columns then
			self.selectedButton = self.selectedButton - columns
		end
	elseif control.menu == "down"  then
		if self.selectedButton < maxParts + 1 - columns then
			self.selectedButton = self.selectedButton + columns
		end
	elseif control.menu == "left"  then
		if self.selectedButton > 1 then
			self.selectedButton = self.selectedButton - 1
		end
	elseif control.menu == "right"  then
		if self.selectedButton < maxParts then
			self.selectedButton = self.selectedButton + 1
		end
	elseif control.menu == "confirm" then
		return PartRegistry.noncoreParts[self.selectedButton]
	end
end
--[[
function ShipEditor.released(control)
end

function .gamepadpressed(joystick, button)
end

function .gamepadreleased(joystick, button)
end

function .joystickpressed(joystick, button)
end

function .joystickreleased(joystick, button)
end

function .textinput(key)
end

--]]
function PartSelector:mousemoved(cursor)
	local index = self:getButtonAt(cursor)
	if index then
		self.selectedButton = index
	end
end
--[[
function PartSelector:wheelmoved(_, y) --(x, y)
end

function .wheelmoved(cursor, control)
end

--]]

function PartSelector:update(dt)
end

function PartSelector:draw()
	love.graphics.push("all")
	local x = love.graphics.getWidth() / 2 - width / 2
	local y = self.y

	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.rectangle(
		"fill",
		x-border, y-border,
		width + border*2, height + border*2)

	local stencilFunction = function()
		love.graphics.rectangle(
			"fill",
			x-border, y-border,
			width + border*2, height + border*2)
	end

	love.graphics.stencil(stencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)

	for i, k in ipairs(PartRegistry.noncoreParts) do
		im = i-1
		imageX = im % columns
		imageY = (im - imageX) / columns
		imageX = imageX * 30 + x
		imageY = imageY * 30 + y

		love.graphics.setColor(1, 1, 1)
		if i == self.selectedButton then
			love.graphics.rectangle("fill", imageX + 3, imageY + 3, 24, 24)
		end
		love.graphics.draw(PartRegistry.partsList[PartRegistry.noncoreParts[i]].image, imageX + 5, imageY + 5)
	end

	love.graphics.pop()
end

return PartSelector
