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
	self.visibleHeight = love.graphics.getHeight() - self.y
	self.buttons = buttons
	self.scrollY = 0
	self.scrollVelocity = 0
    self.selectedButton = 0
	self.font = love.graphics.newFont(size * 7)

	return self
end

function Menu:getButtonAt(x, y)
	print(self.scrollY)
	if x > self.x and x < self.x + self.buttonWidth and y > self.y then
		local yRef = y - self.y + self.scrollY
		local index = math.floor(yRef/self.buttonSpacing) + 1
		local remainder = yRef % self.buttonSpacing
		if index > 0 and index <= #self.buttons and
		   remainder < self.buttonSpacing then
		   print(index) --debug
			return index
		end
	end
	return nil
end

function Menu:getHeight()
	return #self.buttons * self.buttonSpacing
end

function Menu:update(dt)
	self.scrollY = self.scrollY + self.scrollVelocity * dt
	self.scrollVelocity = self.scrollVelocity * 0.98

	if self.scrollY < 0 then
		self.scrollY = 0
		if self.scrollVelocity < 0 then
			self.scrollVelocity = 0
		end
	end

	local menuHeight = self:getHeight()
	local visibleHeight = love.graphics.getHeight
	if self.scrollY > menuHeight - self.visibleHeight then
		self.scrollY = 0
		if self.scrollVelocity > menuHeight then
			self.scrollVelocity = 0
		end
	end
end

function Menu:draw()
	for i, button in ipairs(self.buttons) do
		if i == self.selectedButton then
			love.graphics.setColor(180, 180, 180)
		else
			love.graphics.setColor(100, 100, 100)
		end
		love.graphics.rectangle(
			"fill",
			self.x,
			self.y + self.buttonSpacing * (i - 1) - self.scrollY,
			self.buttonWidth, self.buttonHeight
		)
		love.graphics.setColor(255, 255, 255)
		local previousFont = love.graphics.getFont()
		love.graphics.setFont(self.font)
		love.graphics.print(
			self.buttons[i],
			self.x + 10,
			self.y + 75 * (i - 1) + (self.buttonHeight - self.textHeight)/2 - self.scrollY,
			0, 1, 1, 0, 0, 0, 0
		)
		love.graphics.setFont(previousFont)
	end
end

function Menu:resize(w, h)
	self.visibleHeight = h - self.y
end

function Menu:mousemoved(x, y)
	index = self:getButtonAt(x, y)
	if index == nil then
		return
	end
	self.selectedButton = index
end

function Menu:wheelmoved(x, y)
	local scrollSpeed = 150
	if y < 0 then
		self.scrollVelocity = -scrollSpeed
	elseif y > 0 then
		self.scrollVelocity = scrollSpeed
	end
end

function Menu:pressed(x, y)
	index = self:getButtonAt(x, y)
	if index == nil then
		return nil
	end
	return self.buttons[index]
end

return Menu
