local Util = require('util')

local Menu = {}
Menu.__index = Menu

function Menu.create(x, y, size, buttons)
	self = {}
	setmetatable(self, Menu)

	self.buttonWidth = size * 100
	self.buttonHeight = size * 10
	self.buttonSpacing = size * 15
	self.textHeight = size * 8
	self.x = x - self.buttonWidth/2
	self.y = y
	self.buttons = buttons
    self.selectedButton = 1
	self.drawableButtons = love.graphics.getHeight() /
	                       (self.buttonHeight + self.buttonSpacing)
	self.font = love.graphics.newFont(size * 7)

	return self
end

function Menu:resize(w, h)
	self.drawableButtons = h / (self.buttonHeight + self.buttonSpacing)
end

function Menu:pressed(x, y)
	if x > self.x and x < self.x + self.buttonWidth and y > self.y then
		local yRef = y - self.y
		local index = math.floor(yRef/self.buttonSpacing) + self.selectedButton
		local remainder = yRef % self.buttonSpacing
		if index > 0 and index <= #self.buttons and
		   remainder < self.buttonSpacing then
			return self.buttons[index]
		end
	end
	return nil
end

function Menu:draw()
	for i=self.selectedButton,Util.min(#self.buttons, self.drawableButtons) do
		love.graphics.setColor(100, 100, 100)
		love.graphics.rectangle("fill", self.x,
								self.y + self.buttonSpacing * (i - 1),
								self.buttonWidth, self.buttonHeight)
		love.graphics.setColor(255, 255, 255)
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(self.font)
		love.graphics.print(
			self.buttons[i],
			self.x + 10,
			self.y + 75 * (i - 1) + (self.buttonHeight - self.textHeight)/2,
			0, 1, 1, 0, 0, 0, 0
		)
		love.graphics.setFont(previousFont)
	end
end

return Menu
