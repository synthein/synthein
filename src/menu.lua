local Menu = {}
Menu.__index = Menu

function Menu.create(x, y, size, buttons)
	self = {}
	setmetatable(self, Menu)

	self.width = size * 100
	self.height = size * 10
	self.spacing = size * 15
	self.textHeight = size * 8
	self.x = x - self.width/2
	self.y = y
	self.buttons = buttons
	self.font = love.graphics.newFont(size * 7)

	return self
end

function Menu:pressed(x, y)
	if x > self.x and x < self.x + self.width and y > self.y then
		local yRef = y - self.y
		local index = math.floor(yRef/self.spacing) + 1
		local remainder = yRef % self.spacing
		if index > 0 and index <= #self.buttons and
				remainder < self.spacing then
			return self.buttons[index]
		end
	end
	return nil
end

function Menu:draw()
	for i,button in ipairs(self.buttons) do
		love.graphics.setColor(100, 100, 100)
		love.graphics.rectangle("fill", self.x,
								self.y + self.spacing * (i - 1),
							    self.width, self.height)
		love.graphics.setColor(255, 255, 255)
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(self.font)
		love.graphics.print(self.buttons[i], self.x + 10,
							self.y + 75 * (i - 1) +
								(self.height - self.textHeight)/2,
							0, 1, 1, 0, 0, 0, 0)
		love.graphics.setFont(previousFont)
	end
end

return Menu
